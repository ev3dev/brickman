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

/* FakeFileBrowserController.vala - File Browser controller for testing */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class FakeFileBrowserController : Object, IBrickManagerModule {
        const string PARENT_DIRECTORY_TEXT = "../";
        const string INITAL_DIRECTORY = "/home";
        const string file_attrs = FileAttribute.STANDARD_IS_HIDDEN
            + "," + FileAttribute.STANDARD_TYPE
            + "," + FileAttribute.OWNER_USER
            + "," + FileAttribute.UNIX_MODE;

        FileBrowserWindow file_browser_window;
        FileMonitor? monitor;
        File initial_directory;

        public BrickManagerWindow start_window { get { return file_browser_window; } }

        public FakeFileBrowserController (Gtk.Builder builder) {
            file_browser_window = new FileBrowserWindow () {
                sort_files_func = sort_files
            };
            file_browser_window.file_selected.connect ((represented_object) => {
                try {
                    var file = represented_object as File;
                    var file_info = file.query_info (file_attrs,
                        FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                    var mode = file_info.get_attribute_uint32 (FileAttribute.UNIX_MODE);
                    if (file_info.get_file_type () == FileType.DIRECTORY) {
                        set_directory.begin (file, (obj, res) => {
                            try {
                                set_directory.end (res);
                            } catch (Error err) {
                                var dialog = new MessageDialog ("Error", err.message);
                                dialog.show ();
                            }
                        });
                    } else if ((mode & Posix.S_IXUSR) == Posix.S_IXUSR) {
                        try {
                            string[] args = { file.get_path () };
                            string[] env = Environ.get ();
                            Pid pid;
                            Process.spawn_async (null, args, env, SpawnFlags.DO_NOT_REAP_CHILD, null, out pid);
                            ChildWatch.add (pid, (p, s) => {
                                Process.close_pid (p);
                                message ("child process done.");
                            });
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
            initial_directory = File.new_for_path (INITAL_DIRECTORY);
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
                        critical ("%s", err.message);
                    }
                    break;
                case FileMonitorEvent.DELETED:
                    file_browser_window.remove_file (src);
                    break;
                }
            });
            file_browser_window.current_directory = directory.get_path ();
            // limit the browser to children of the inital directory
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

        static int sort_files (UI.MenuItem a, UI.MenuItem b) {
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