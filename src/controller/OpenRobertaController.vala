/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2015 Stefan Sauer <ensonic@google.com>
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

/* OpenRobertaController.vala - Controller for openroberta lab service */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    // TODO: move to lib/openroberta/Manager.vala
    [DBus (name = "org.openroberta.lab")]
    interface OpenRobertaLab : Object {
        [DBus (name = "status")]
        public signal void status (string message);

        [DBus (name = "connect")]
        public abstract string connect (string address) throws DBusError, IOError;
        [DBus (name = "disconnect")]
        public abstract void disconnect () throws DBusError, IOError;
    }

    public class OpenRobertaController : Object, IBrickManagerModule {
        const string SERVICE_NAME = "org.openroberta.lab";
        const string CONFIG = "/etc/openroberta.conf";
        const int OPEN_ROBERTA_TTY_NUM = 2;

        OpenRobertaWindow open_roberta_window;
        internal OpenRobertaStatusBarItem status_bar_item;
        OpenRobertaLab service;
        KeyFile config;
        bool executing_user_code;

        public bool available { get; set; }

        public string display_name { get { return "Open Roberta Lab"; } }

        public OpenRobertaController () {
            status_bar_item = new OpenRobertaStatusBarItem ();
            config = new KeyFile ();

            bind_property ("available", status_bar_item, "visible",
                BindingFlags.SYNC_CREATE);

            Bus.watch_name (BusType.SYSTEM, SERVICE_NAME,
                BusNameWatcherFlags.NONE, () => {
                    connect_async.begin ((obj, res) => {
                        try {
                            connect_async.end (res);
                            if (open_roberta_window != null) {
                                open_roberta_window.loading = false;
                            }
                            available = true;
                        } catch (IOError err) {
                            warning ("%s", err.message);
                        }
                    });
                }, () => {
                    status_bar_item.connected = false;
                    if (open_roberta_window != null) {
                        open_roberta_window.connected = false;
                    }
                    available = false;
                    service = null;
                    // if the service dies (while running code), definitely
                    // switch back to brickman
                    // FIXME: This should only be called if the current tty is the OpenRoberta tty
                    // FIXME: need to figure out how console switching is going to work with GRX3
                    // chvt (ConsoleApp.get_tty_num ());
                });
        }

        public void show_main_window () {
            if (open_roberta_window == null) {
                init_main_window ();
            }
            open_roberta_window.show ();
        }

        void init_main_window () {
            open_roberta_window = new OpenRobertaWindow (display_name) {
                loading = !available
            };

            bind_property ("available", open_roberta_window, "available",
                BindingFlags.SYNC_CREATE);

            try {
                config.load_from_file (CONFIG, KeyFileFlags.KEEP_COMMENTS);
                open_roberta_window.custom_server_address =
                    config.get_string ("Common", "CustomServer");
                open_roberta_window.selected_server =
                    config.get_string ("Common", "SelectedServer");
            } catch (FileError err) {
                warning ("FileError: %s", err.message);
            } catch (KeyFileError err) {
                warning ("KeyFileError: %s", err.message);
            }

            open_roberta_window.connect_selected.connect (on_server_connect);
            open_roberta_window.disconnect_selected.connect (on_server_disconnect);
            open_roberta_window.notify["custom-server-address"].connect (
                on_custom_server_changed);
        }

        async void connect_async () throws IOError {
            service = yield Bus.get_proxy (BusType.SYSTEM, SERVICE_NAME,
                "/org/openroberta/Lab1");
            service.status.connect (on_status_changed);
            //TODO: DBus service does not provide the inital state of "status".
            //on_status_changed (service.status);
        }

        void on_status_changed (string message) {
            debug ("service status: '%s'", message);
            // connected:    we've started the communication with the server
            // registered:   we're online
            // disconnected: the communication with the server is stopped or has
            //               been terminated
            // executing:    we're online and a program is running
            string[] online = { "registered", "executing" };
            if (message in online) {
                status_bar_item.connected = true;
                open_roberta_window.connected = true;
                if (message == "registered") {
                    if (executing_user_code) {
                        // FIXME: need to figure out how console switching is going to work with GRX3
                        // var tty_num = ConsoleApp.get_tty_num ();
                        // debug ("program done, switching to tty%d", tty_num);
                        // executing_user_code = false;
                        // chvt (tty_num);
                    } else {
                        debug ("connection established, closing the dialog");
                        OpenRobertaWindow.close_pairing_code_dialog ();
                        // remember selected server
                        config.set_string ("Common", "SelectedServer",
                            open_roberta_window.selected_server);
                        try {
                            config.save_to_file (CONFIG);
                        } catch (FileError err) {
                            warning ("FileError: %s", err.message);
                        }
                    }
                }
                if (message == "executing") {
                    debug ("program starts, switching to tty%d", OPEN_ROBERTA_TTY_NUM);
                    executing_user_code = true;
                    chvt (OPEN_ROBERTA_TTY_NUM);
                }
            } else {
                status_bar_item.connected = false;
                open_roberta_window.connected = false;
                if (message == "disconnected") {
                    debug ("connection failed, closing the dialog");
                    OpenRobertaWindow.close_pairing_code_dialog ();
                }
            }
        }

        void on_custom_server_changed () {
            config.set_string ("Common", "CustomServer",
                open_roberta_window.custom_server_address);
            try {
                config.save_to_file (CONFIG);
            } catch (FileError err) {
                warning ("FileError: %s", err.message);
            }
        }

        void on_server_connect (string address) {
            try {
                open_roberta_window.selected_server = address;
                var code = service.connect ("http://" + address);
                OpenRobertaWindow.show_pairing_code_dialog (code);
            } catch (Error err) {
                warning ("%s", err.message);
            }
        }

        void on_server_disconnect () {
            try {
                service.disconnect ();
            } catch (Error err) {
                warning ("%s", err.message);
            }
        }

        void chvt (int num) {
            // TODO: might be better to do this with ioctl
            Posix.system ("/bin/chvt %d".printf (num));
        }
    }
}
