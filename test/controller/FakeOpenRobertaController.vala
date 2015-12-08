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

/* FakeOpenRobertaController.vala - Fake OpenRoberta controller for testing */

using Ev3devKit.Ui;

namespace BrickManager {
    public class FakeOpenRobertaController : Object, IBrickManagerModule {
        OpenRobertaWindow open_roberta_window;
        Gtk.RadioButton disconnected_radio_button;
        Gtk.RadioButton connected_radio_button;

        public OpenRobertaStatusBarItem status_bar_item;

        public bool available { get; set; default = false; }

        public string display_name { get { return "Open Roberta Lab"; } }

        public void show_main_window () {
            open_roberta_window.show ();
        }

        public FakeOpenRobertaController (Gtk.Builder builder) throws Error {
            // TODO: defer window creation to show_main_window()
            open_roberta_window = new OpenRobertaWindow (display_name);
            status_bar_item = new OpenRobertaStatusBarItem ();

            bind_property ("available", status_bar_item, "visible", BindingFlags.SYNC_CREATE);
            bind_property ("available", open_roberta_window, "available", BindingFlags.SYNC_CREATE);

            open_roberta_window.connect_selected.connect (on_server_connect);
            open_roberta_window.disconnect_selected.connect (on_server_disconnect);

            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            open_roberta_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.OPEN_ROBERTA);

            var open_roberta_loading_checkbutton = builder.get_object ("openroberta-loading-checkbutton") as Gtk.CheckButton;
            open_roberta_loading_checkbutton.bind_property ("active", open_roberta_window, "loading", BindingFlags.SYNC_CREATE);

            (builder.get_object ("openroberta-available-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", this, "available", BindingFlags.SYNC_CREATE);

            disconnected_radio_button = builder.get_object ("openroberta-status-disconnected-radiobutton") as Gtk.RadioButton;
            disconnected_radio_button.clicked.connect (() => {
                status_bar_item.connected = false;
                open_roberta_window.connected = false;
            });
            connected_radio_button = builder.get_object ("openroberta-status-connected-radiobutton") as Gtk.RadioButton;
            connected_radio_button.clicked.connect (() => {
                status_bar_item.connected = true;
                open_roberta_window.connected = true;
            });

            (builder.get_object ("openroberta-custom-server-entry") as Gtk.Entry)
                .bind_property ("text", open_roberta_window, "custom-server-address",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            (builder.get_object ("openroberta-active-server-entry") as Gtk.Entry)
                .bind_property ("text", open_roberta_window, "selected-server",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

            var pin_code_entry = builder.get_object ("openroberta-pin-code-entry") as Gtk.Entry;
            (builder.get_object ("openroberta-show-pin-dialog-button") as Gtk.Button)
                .clicked.connect (() => {
                    var code = pin_code_entry.text;
                    OpenRobertaWindow.show_pairing_code_dialog (code);
                });
            (builder.get_object ("openroberta-close-pin-dialog-button") as Gtk.Button)
                .clicked.connect (() => OpenRobertaWindow.close_pairing_code_dialog ());
        }

        void on_server_connect (string address) {
            if (address == "") {
                OpenRobertaWindow.show_no_custom_server_address_dialog ();
            } else {
                open_roberta_window.selected_server = address;
                connected_radio_button.clicked ();
            }
        }

        void on_server_disconnect () {
            disconnected_radio_button.clicked ();
        }
    }
}
