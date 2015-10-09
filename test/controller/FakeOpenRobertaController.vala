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

/* FakeOpenRobertaController.vala - Fake OpenRoberta controller for testing */

using Ev3devKit.Ui;

namespace BrickManager {
    public class FakeOpenRobertaController : Object, IBrickManagerModule {
        OpenRobertaWindow open_roberta_window;
        public OpenRobertaStatusBarItem status_bar_item;
        MessageDialog pin_dialog;

        public bool available { get; set; default = false; }

        public BrickManagerWindow start_window { get { return open_roberta_window; } }

        public FakeOpenRobertaController (Gtk.Builder builder) throws Error {
            open_roberta_window = new OpenRobertaWindow ();
            status_bar_item = new OpenRobertaStatusBarItem ();

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

            open_roberta_window.public_server.button.pressed.connect (on_server_connect);
            open_roberta_window.local_server.button.pressed.connect (on_server_connect);
            open_roberta_window.custom_server.button.pressed.connect (on_server_connect);

            open_roberta_window.disconnect_server.button.pressed.connect (on_server_disconnect);

            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            open_roberta_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.OPEN_ROBERTA);

            var open_roberta_loading_checkbutton = builder.get_object ("open_roberta_loading_checkbutton1") as Gtk.CheckButton;
            open_roberta_loading_checkbutton.bind_property ("active", open_roberta_window, "loading", BindingFlags.SYNC_CREATE);

            (builder.get_object ("openroberta_available_checkbutton") as Gtk.CheckButton)
                .bind_property ("active", this, "available", BindingFlags.SYNC_CREATE);

            (builder.get_object ("openroberta_status_connencted") as Gtk.Button)
                .clicked.connect (() => {
                    status_bar_item.connected = false;
                    open_roberta_window.connected = false;
                });
            (builder.get_object ("openroberta_status_disconnencted") as Gtk.Button)
                .clicked.connect (() => {
                    status_bar_item.connected = false;
                    open_roberta_window.connected = false;
                });

            (builder.get_object ("openroberta_status_registered") as Gtk.Button)
                .clicked.connect (() => {
                    status_bar_item.connected = true;
                    open_roberta_window.connected = true;
                    if (pin_dialog != null) {
                        pin_dialog.close ();
                    }
                });
            (builder.get_object ("openroberta_status_executing") as Gtk.Button)
                .clicked.connect (() => {
                    status_bar_item.connected = true;
                    open_roberta_window.connected = true;
                });
        }

        void on_server_connect (Button button) {
            var server = (button.child as Label).text;
            if ( server == "" || server == "custom server") {
                // TODO: enter the new address
            } else {
                var code = "1234abcd";
                var label = new Label (code) {
                    margin_top = 12,
                    font = BrickManagerWindow.big_font
                };
                pin_dialog = new MessageDialog.with_content ("Pairing code", label);
                pin_dialog.closed.connect (() => { pin_dialog = null; });
                pin_dialog.show ();
            }
        }

        void on_server_disconnect () {
            status_bar_item.connected = false;
            open_roberta_window.connected = false;
        }
    }
}
