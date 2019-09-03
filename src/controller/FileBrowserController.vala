/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* FileBrowserController.vala - File Browser controller */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class FileBrowserController : Object, IBrickManagerModule {
        const string PARENT_DIRECTORY_TEXT = "../";
        const string INITIAL_DIRECTORY = "/home/robot";
        const string USER_NAME = "robot";
        const string file_attrs = FileAttribute.OWNER_USER
            + "," + FileAttribute.STANDARD_IS_HIDDEN
            + "," + FileAttribute.STANDARD_TYPE
            + "," + FileAttribute.UNIX_UID
            + "," + FileAttribute.UNIX_GID
            + "," + FileAttribute.UNIX_MODE;

        FileBrowserWindow file_browser_window;
        FileMonitor? monitor;
        File initial_directory;

        public string display_name { get { return "File Browser"; } }

        public void show_main_window () {
            if (file_browser_window == null) {
                create_main_window ();
            }
            file_browser_window.show ();
        }

        void create_main_window () {
            file_browser_window = new FileBrowserWindow (display_name) {
                sort_files_func = sort_files
            };
            file_browser_window.file_selected.connect ((represented_object) => {
                try {
                    var file = represented_object as File;
                    var file_info = file.query_info (file_attrs,
                        FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                    var mode = file_info.get_attribute_uint32 (FileAttribute.UNIX_MODE);
                    if (file_info.get_file_type () == FileType.DIRECTORY) {
                        // if the selected file is a directory, then we
                        // open that directory.
                        set_directory.begin (file, (obj, res) => {
                            try {
                                set_directory.end (res);
                            } catch (Error err) {
                                var dialog = new MessageDialog ("Error", err.message);
                                dialog.show ();
                            }
                        });
                    } else if ((mode & Posix.S_IXUSR) == Posix.S_IXUSR) {
                        // If the selected file is executable then we run the
                        // file via brickrun as USER_NAME. brickrun takes
                        // care of switching consoles, stopping motors, etc.
                        try {
                            string[] args = {
                                "/usr/bin/sudo",
                                "--login",
                                "--non-interactive",
                                "--user",
                                USER_NAME,
                                "--",
                                "/usr/bin/brickrun",
                                "--directory",
                                file.get_parent().get_path (),
                                "--",
                                file.get_path ()
                            };
                            var subproc = new Subprocess.newv (args, SubprocessFlags.STDERR_PIPE);
                            try {
                                var err_log_filename = file.get_path () + ".err.log";
                                var err_log = File.new_for_path (err_log_filename);
                                var err_log_out = err_log.replace (null, false, FileCreateFlags.REPLACE_DESTINATION);
                                err_log_out.splice_async.begin (subproc.get_stderr_pipe (),
                                    OutputStreamSpliceFlags.CLOSE_TARGET, Priority.DEFAULT, null, (obj, res) => {
                                        try {
                                            var size = err_log_out.splice_async.end (res);
                                            if (size == 0) {
                                                // delete the file if there was nothing logged.
                                                err_log.delete ();
                                            } else {
                                                // change the owner to match the executable,
                                                // otherwise it is owned by root and can't be deleted
                                                var uid = file_info.get_attribute_uint32 (FileAttribute.UNIX_UID);
                                                var gid = file_info.get_attribute_uint32 (FileAttribute.UNIX_GID);
                                                Posix.chown (err_log_filename, uid, gid);
                                            }
                                        } catch (Error err) {
                                            warning ("Error writing log file: %s", err.message);
                                        }
                                    });
                            } catch (Error err) {
                                warning ("Failed to create error log: %s", err.message);
                            }
                        } catch (SpawnError err) {
                            var dialog = new MessageDialog ("Error", err.message);
                            dialog.show ();
                        }
                    } else {
                        var dialog = new MessageDialog (file.get_basename (),
                            "This file is not a directory or an executable.");
                        dialog.show ();
                    }
                } catch (Error err) {
                    var dialog = new MessageDialog ("Error", err.message);
                    dialog.show ();
                }
            });
            initial_directory = File.new_for_path (INITIAL_DIRECTORY);
            file_browser_window.file_selected (initial_directory);
        }

        async void set_directory (File directory) throws Error {
            file_browser_window.loading = true;
            file_browser_window.clear_files ();
            if (monitor != null)
                monitor.cancel ();
            monitor = directory.monitor_directory (FileMonitorFlags.NONE);
            monitor.changed.connect ((src, dest, event) => {
                switch (event) {
                case FileMonitorEvent.CREATED:
                    try {
                        var file_info = src.query_info (file_attrs,
                            FileQueryInfoFlags.NOFOLLOW_SYMLINKS);

                        // don't show hidden files
                        if (file_info.get_is_hidden ())
                            break;

                        var file_name = src.get_basename ();
                        var mode = file_info.get_attribute_uint32 (FileAttribute.UNIX_MODE);
                        if (file_info.get_file_type ()  == FileType.DIRECTORY) {
                            // add '/' to the end of directories
                            file_name += "/";
                        } else if ((mode & Posix.S_IXUSR) == Posix.S_IXUSR) {
                            // add '*' to the end of executable files
                            file_name += "*";
                        }

                        file_browser_window.add_file (file_name, src);
                    } catch (Error err) {
                        // If file was deleted immediately after creation, no need
                        // to show error message.
                        if (err is IOError.NOT_FOUND)
                            break;
                        critical ("%s", err.message);
                    }
                    break;
                case FileMonitorEvent.DELETED:
                    file_browser_window.remove_file (src);
                    break;
                }
            });
            file_browser_window.current_directory = directory.get_path ();
            // Limit the browser to children of the initial directory.
            // Browsing the entire file system as root is probably a bad idea.
            if (!directory.equal (initial_directory)) {
                var parent = directory.get_parent ();
                if (parent != null)
                    file_browser_window.add_file (PARENT_DIRECTORY_TEXT, parent);
            }
            var enumerator = yield directory.enumerate_children_async ("",
                FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
            FileInfo info;
            // TODO: use next_files_async () instead?
            while ((info = enumerator.next_file ()) != null) {
                monitor.changed (enumerator.get_child (info), null,
                    FileMonitorEvent.CREATED);
            }
            file_browser_window.loading = false;
        }

        static int sort_files (Ui.MenuItem a, Ui.MenuItem b) {
            var a_text = a.label.text;
            var b_text = b.label.text;

            // parent directory text goes first
            if (a_text == PARENT_DIRECTORY_TEXT)
                return -1;
            if (b_text == PARENT_DIRECTORY_TEXT)
                return 1;

            // then directories
            var a_last_char = a_text[a_text.length -1];
            var b_last_char = b_text[b_text.length -1];
            if (a_last_char == '/' && b_last_char != '/')
                return -1;
            if (a_last_char != '/' && b_last_char == '/')
                return 1;

            // then everything else
            return strcmp (a_text, b_text);
        }
    }
}
