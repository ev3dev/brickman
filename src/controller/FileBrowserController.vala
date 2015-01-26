/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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

using EV3devKit;

namespace BrickManager {
    public class FileBrowserController : Object, IBrickManagerModule {
        const string PARENT_DIRECTORY_TEXT = "../";
        const string INITAL_DIRECTORY = "/home";
        const string file_attrs = FileAttribute.OWNER_USER
            + "," + FileAttribute.STANDARD_IS_HIDDEN
            + "," + FileAttribute.STANDARD_TYPE
            + "," + FileAttribute.UNIX_MODE
            + "," + FileAttribute.UNIX_UID;

        FileBrowserWindow file_browser_window;
        FileMonitor? monitor;
        File initial_directory;

        public string menu_item_text { get { return "File Browser"; } }
        public Window start_window { get { return file_browser_window; } }

        public FileBrowserController () {
            file_browser_window = new FileBrowserWindow () {
                sort_files_func = sort_files
            };
            file_browser_window.file_selected.connect ((represented_object) => {
                try {
                    var file = represented_object as File;
                    var file_info = file.query_info (file_attrs,
                        FileQueryInfoFlags.NOFOLLOW_SYMLINKS);
                    var mode = file_info.get_attribute_uint32 (FileAttribute.UNIX_MODE);
                    var uid = file_info.get_attribute_uint32 (FileAttribute.UNIX_UID);
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
                        // if the selected file is executable and not owned by
                        // a system user then we run the file on a new console
                        // as the owner of the file.
                        if (uid < 1000)
                            throw new IOError.PERMISSION_DENIED ("Cannot run files owned by system users.");
                        try {
                            var owner = file_info.get_attribute_string (FileAttribute.OWNER_USER);
                            string[] args = {
                                "/bin/openvt",
                                "--verbose",
                                "--switch",
                                "--wait",
                                "--",
                                "/usr/bin/sudo",
                                "--login",
                                "--set-home",
                                "--non-interactive",
                                "--user=%s".printf (owner),
                                "--",
                                file.get_path ()
                            };
                            var subproc = new Subprocess.newv (args, SubprocessFlags.STDERR_PIPE);
                            global_manager.set_leds (LEDState.USER);
                            // openvt outputs something like "openvt: Using VT /dev/tty8"
                            // on stderr when the --version option is used, so we use
                            // that to get the tty that our user program is running on.
                            var stderr = new DataInputStream (subproc.get_stderr_pipe ());
                            var line = stderr.read_line ();
                            var tty = int.parse (line[line.last_index_of_char ('y') + 1:line.length]);
                            // If user presses the back button, kill all processes
                            // running on the new VT.
                            uint timeout_id = 0;
                            var button_down_handler_id = global_manager.ev3_button_down.connect ((button) => {
                                if (button == EV3Button.BACK) {
                                    timeout_id = Timeout.add (1000, () => {
                                        // Use pkill to find all processes on the tty opened
                                        // by openvt and send them SIGTERM.
                                        try {
                                            string[] args2 = {
                                                "pkill",
                                                "--terminal",
                                                "tty%d".printf (tty)
                                            };
                                            new Subprocess.newv (args2, SubprocessFlags.NONE);
                                        } catch (Error err) {
                                            critical ("%s", err.message);
                                        }
                                        timeout_id = 0;
                                        return Source.REMOVE;
                                    });
                                }
                            });
                            var button_up_handler_id = global_manager.ev3_button_up.connect ((button) => {
                                if (button == EV3Button.BACK && timeout_id != 0) {
                                    Source.remove (timeout_id);
                                }
                            });
                            // Wait for the openvt process to end, then clean up
                            // output devices in case the use program didn't
                            subproc.wait_async.begin (null, (obj, res) => {
                                try {
                                    subproc.wait_async.end (res);
                                } catch (Error err) {
                                    // shouldn't happen since it is not cancellable
                                }
                                global_manager.disconnect (button_down_handler_id);
                                global_manager.disconnect (button_up_handler_id);
                                global_manager.set_leds (LEDState.NORMAL);
                                global_manager.stop_all_motors ();
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
                        // If file was deleted immediatly after creation, no need
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

        static int sort_files (EV3devKit.MenuItem a, EV3devKit.MenuItem b) {
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