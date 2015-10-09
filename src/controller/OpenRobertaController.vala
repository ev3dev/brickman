/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2015 Stefan Sauer <ensonic@google.com>
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

using Ev3devKit.Ui;

namespace BrickManager {
    // TODO: move to lib/openroberta/Manager.vala
    [DBus (name = "org.openroberta.lab")]
    interface OpenRobertaLab : Object {
        [DBus (name = "status")]
        public signal void status (string message);

        [DBus (name = "connect")]
        public abstract string connect (string address) throws IOError;
        [DBus (name = "disconnect")]
        public abstract void disconnect () throws IOError;
    }

    public class OpenRobertaController : Object, IBrickManagerModule {
        const string SERVICE_NAME = "org.openroberta.lab";
        const string CONFIG = "/etc/openroberta.conf";

        OpenRobertaWindow open_roberta_window;
        internal OpenRobertaStatusBarItem status_bar_item;
        OpenRobertaLab service;
        KeyFile config;
        MessageDialog pin_dialog;

        public bool available { get; set; default = false; }

        public BrickManagerWindow start_window { get { return open_roberta_window; } }

        public OpenRobertaController () {
            open_roberta_window = new OpenRobertaWindow ();
            status_bar_item = new OpenRobertaStatusBarItem ();
            config = new KeyFile ();

            bind_property ("available", status_bar_item, "visible", BindingFlags.SYNC_CREATE);
            bind_property ("available", open_roberta_window.menu, "visible", BindingFlags.SYNC_CREATE);

            notify["available"].connect (() => {
                if (!available) {
                    open_roberta_window.info.text =
                        "Service openrobertalab is not running.";
                } else {
                  open_roberta_window.notify_property("connected");
                }
            });

            Bus.watch_name (BusType.SYSTEM, SERVICE_NAME,
                BusNameWatcherFlags.AUTO_START, () => {
                    connect_async.begin ((obj, res) => {
                        try {
                            connect_async.end (res);
                            open_roberta_window.loading = false;
                            available = true;
                        } catch (IOError err) {
                            available = false;
                            warning ("%s", err.message);
                        }
                    });
                }, () => {
                    open_roberta_window.loading = true;
                    open_roberta_window.connected = false;
                    status_bar_item.connected = false;
                    available = false;
                    service = null;
                    // if the service dies (while running code), definitely
                    // switch back to brickman
                    Posix.system("/bin/chvt 1");
                });

            try {
                config.load_from_file (CONFIG, KeyFileFlags.KEEP_COMMENTS);
                open_roberta_window.custom_server.label.text =
                    config.get_string ("Common", "CustomServer");
            } catch (FileError err) {
                warning ("FileError: %s", err.message);
            } catch (KeyFileError err) {
                warning ("KeyFileError: %s", err.message);
            }

            open_roberta_window.public_server.button.pressed.connect (on_server_connect);
            open_roberta_window.local_server.button.pressed.connect (on_server_connect);
            open_roberta_window.custom_server.button.pressed.connect (on_server_connect);

            open_roberta_window.config_custom.button.pressed.connect (on_server_edit);

            open_roberta_window.disconnect_server.button.pressed.connect (on_server_disconnect);
        }

        async void connect_async () throws IOError {
            service = yield Bus.get_proxy (BusType.SYSTEM, SERVICE_NAME,
                "/org/openroberta/Lab1");
            service.status.connect (on_status_changed);
        }

        void on_status_changed (string message) {
            debug ("service status: '%s'", message);
            string[] offline = { "connected", "disconnected" };
            if (message in offline) {
                status_bar_item.connected = false;
                open_roberta_window.connected = false;
                if (message == "disconnected") {
                    if (pin_dialog != null) {
                        debug ("connection failed, closing the dialog");
                        pin_dialog.close ();
                    }
                }
            } else {
                status_bar_item.connected = true;
                open_roberta_window.connected = true;
                if (message == "registered") {
                    if (pin_dialog != null) {
                        debug ("connection established, closing the dialog");
                        pin_dialog.close ();
                    } else {
                        debug ("program done, switching to tty1");
                        Posix.system("/bin/chvt 1");
                    }
                }
                if (message == "executing") {
                    debug ("program starts, switching to tty2");
                    Posix.system("/bin/chvt 2");
                }
            }
        }

        void on_server_edit () {
            var  custom_server_address = open_roberta_window.custom_server.label.text;
            if (custom_server_address == "custom server") {
                custom_server_address = "";
            }
            var dialog = new InputDialog (
                "Please enter server address", custom_server_address);
            weak InputDialog weak_dialog = dialog;
            dialog.responded.connect ((accepted) => {
                if (!accepted) {
                    return;
                }
                custom_server_address = weak_dialog.text_value;
                open_roberta_window.custom_server.label.text = custom_server_address;
                config.set_string ("Common", "CustomServer", custom_server_address);
                try {
                    config.save_to_file (CONFIG);
                } catch (FileError err) {
                    warning ("FileError: %s", err.message);
                }
                on_server_connect (open_roberta_window.custom_server.button);
            });
            dialog.show ();
        }

        void on_server_connect (Button button) {
            var server = (button.child as Label).text;
            if ( server == "" || server == "custom server") {
                on_server_edit ();
            } else {
                try {
                    var code = service.connect ("http://" + server);
                    var label = new Label (code) {
                        margin_top = 12,
                        font = BrickManagerWindow.big_font
                    };
                    pin_dialog = new MessageDialog.with_content ("Pairing code", label);
                    pin_dialog.closed.connect (() => { pin_dialog = null; });
                    pin_dialog.show ();
                } catch (IOError err) {
                    warning ("%s", err.message);
                }
            }
        }

        void on_server_disconnect () {
            try {
                service.disconnect ();
            } catch (IOError err) {
                warning ("%s", err.message);
            }
        }
    }
}