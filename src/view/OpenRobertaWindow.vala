/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2015 Stefan Sauer <ensonic@google.com>
 * Copyright 2015 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * OpenRobertaWindow.vala - Edit connection status
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class OpenRobertaWindow : BrickManagerWindow {
        const string DEFAULT_SERVER_ADDRESS = "lab.open-roberta.org";
        const string CUSTOM_SERVER_PLACEHOLDER = "<other server>";

        static MessageDialog? pin_dialog;

        Label status_info;
        Stack stack;
        Scroll connect_scroll;
        Box disconnect_vbox;
        Label custom_server_label;
        weak Button weak_default_server_connect_button;
        weak Button weak_custom_server_connect_button;

        public string custom_server_address {
            owned get {
                var address = custom_server_label.text;
                if (address == CUSTOM_SERVER_PLACEHOLDER) {
                    return "";
                }
                return address;
            }
            set {
                if (value == "") {
                    custom_server_label.text = CUSTOM_SERVER_PLACEHOLDER;
                } else {
                    custom_server_label.text = value;
                }
            }
        }

        public bool connected { get; set; }
        public string selected_server { get; set; }

        public signal void connect_selected (string address);
        public signal void disconnect_selected ();

        public OpenRobertaWindow (string display_name) {
            title = display_name;

            status_info = new Label () {
                vertical_align = WidgetAlign.START,
                padding_bottom = 4,
                border_bottom = 1
            };
            content_vbox.add (status_info);

            stack = new Stack ();
            content_vbox.add (stack);

            connect_scroll = new Scroll.vertical () {
                can_focus = false
            };
            weak Scroll weak_connect_scroll = connect_scroll;
            stack.add (connect_scroll);

            var connect_vbox = new Box.vertical ();
            connect_scroll.add (connect_vbox);

            var default_server_label = new Label (DEFAULT_SERVER_ADDRESS);
            connect_vbox.add (default_server_label);
            var default_server_connect_button = new Button.with_label ("Connect") {
                horizontal_align = WidgetAlign.CENTER
            };
            weak_default_server_connect_button = default_server_connect_button;
            default_server_connect_button.notify["has-focus"].connect (() => {
                if (weak_default_server_connect_button.has_focus) {
                    weak_connect_scroll.scroll_to_child (default_server_label);
                }
            });
            default_server_connect_button.pressed.connect ((button) => {
                connect_selected (DEFAULT_SERVER_ADDRESS);
            });
            connect_vbox.add (default_server_connect_button);
            custom_server_label = new Label (CUSTOM_SERVER_PLACEHOLDER) {
                margin_top = 4
            };
            connect_vbox.add (custom_server_label);
            var custom_server_button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER
            };
            weak Box weak_custom_server_button_hbox = custom_server_button_hbox;
            connect_vbox.add (custom_server_button_hbox);
            var custom_server_connect_button = new Button.with_label ("Connect") {
                horizontal_align = WidgetAlign.CENTER
            };
            weak_custom_server_connect_button = custom_server_connect_button;
            custom_server_connect_button.notify["has-focus"].connect (() => {
                if (weak_custom_server_connect_button.has_focus) {
                    weak_connect_scroll.scroll_to_child (weak_custom_server_button_hbox);
                }
            });
            custom_server_connect_button.pressed.connect ((button) => {
                connect_selected (custom_server_address);
            });
            custom_server_button_hbox.add (custom_server_connect_button);
            var custom_server_edit_button = new Button.with_label ("Edit") {
                horizontal_align = WidgetAlign.CENTER
            };
            weak Button weak_custom_server_edit_button = custom_server_edit_button;
            custom_server_edit_button.notify["has-focus"].connect (() => {
                if (weak_custom_server_edit_button.has_focus) {
                    weak_connect_scroll.scroll_to_child (weak_custom_server_button_hbox);
                }
            });
            custom_server_edit_button.pressed.connect (on_edit_selected);
            custom_server_button_hbox.add (custom_server_edit_button);

            disconnect_vbox = new Box.vertical ();
            stack.add (disconnect_vbox);

            var disconnect_button = new Button.with_label ("Disconnect") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.START
            };
            disconnect_button.pressed.connect (() => disconnect_selected ());
            disconnect_vbox.add (disconnect_button);

            shown.connect (() => {
                focus_selected_server ();
            });

            notify["connected"].connect (on_connected_changed);
            on_connected_changed ();

            notify["selected-server"].connect (update_status_info);
        }

        public static void show_no_custom_server_address_dialog () {
            var dialog = new MessageDialog ("No Address",
                "Use the Edit button to enter the name or address of the server.");
            dialog.show ();
        }

        public static void show_connection_dialog (string title, string message) {
            var label = new Label (message) {
                margin_top = 12,
                font = Fonts.get_big ()
            };
            pin_dialog = new MessageDialog.with_content (title, label);
            ulong pin_dialog_closed_id = 0;
            pin_dialog_closed_id = pin_dialog.closed.connect (() => {
                pin_dialog.disconnect (pin_dialog_closed_id);
                pin_dialog = null;
            });
            pin_dialog.show ();
        }

        public static void close_connection_dialog () {
            if (pin_dialog != null) {
                pin_dialog.close ();
            }
        }

        void on_edit_selected (Button button) {
            var dialog = new InputDialog ("Enter server address", custom_server_address);
            weak InputDialog weak_dialog = dialog;
            dialog.responded.connect ((accepted) => {
                if (!accepted) {
                    return;
                }
                custom_server_address = weak_dialog.text_value;
            });
            dialog.show ();
        }

        void on_connected_changed () {
            var new_child = connected ? (Container)disconnect_vbox : connect_scroll;
            stack.active_child = new_child;
            if (connected) {
                new_child.focus_first ();
            } else {
                focus_selected_server ();
            }
            update_status_info ();
        }

        void update_status_info () {
            status_info.text = connected
                ? "Connected to\n%s".printf (_selected_server)
                : "Disconnected";
            focus_selected_server ();
        }

        void focus_selected_server () {
            if (selected_server == custom_server_address) {
                weak_custom_server_connect_button.focus();
            } else {
                weak_default_server_connect_button.focus();
            }
        }
    }
}
