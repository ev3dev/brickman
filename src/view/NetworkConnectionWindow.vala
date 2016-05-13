/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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
 * NetworkConnectionWindow.vala:
 *
 * Displays properties of a network connection.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    class NetworkConnectionWindow : BrickManagerWindow {
        Label state_label;
        CheckButton auto_connect_checkbox;
        Button connect_button;

        public string state {
            get { return state_label.text; }
            set { state_label.text = value; }
        }

        public bool auto_connect {
            get { return auto_connect_checkbox.checked; }
            set { auto_connect_checkbox.checked = value; }
        }

        bool _is_connected;
        public bool is_connected {
            get { return _is_connected; }
            set {
                _is_connected = value;
                set_connect_button_text ();
            }
        }

        bool _is_connect_busy;
        public bool is_connect_busy {
            get { return _is_connect_busy; }
            set {
                _is_connect_busy = value;
                set_connect_button_text ();
            }
        }

        /**
         * Connect/disconnect requested
         *
         * User pressed the Connect/Disconnect button on the Connection tab
         */
        public signal void connect_requested (bool disconnect);

        public signal void ipv4_button_pressed ();
        public signal void dns_button_pressed ();
        public signal void enet_button_pressed ();

        public NetworkConnectionWindow (string title) {
            this.title = title;

            var state_vbox = new Box.vertical () {
                vertical_align = WidgetAlign.START,
                padding_bottom = 2,
                border_bottom = 1
            };
            content_vbox.add (state_vbox);
            var state_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER
            };
            state_vbox.add (state_hbox);
            state_hbox.add (new Label ("State:") {
                horizontal_align = WidgetAlign.END,
                margin_right = 4
            });
            state_label = new Label () {
                horizontal_align = WidgetAlign.START
            };
            state_hbox.add (state_label);

            var menu = new Ui.Menu ();
            content_vbox.add (menu);

            var connect_menu_item = new Ui.MenuItem ("Connect");
            menu.add_menu_item (connect_menu_item);
            connect_button = connect_menu_item.button;
            connect_button.pressed.connect (on_connect_button_pressed);

            var auto_connect_menu_item = new CheckboxMenuItem ("Connect automatically");
            menu.add_menu_item (auto_connect_menu_item);
            auto_connect_checkbox = auto_connect_menu_item.checkbox;
            auto_connect_checkbox.notify["checked"].connect (() =>
                notify_property ("auto-connect"));

            var ipv4_menu_item = new Ui.MenuItem.with_right_arrow ("IPv4");
            menu.add_menu_item (ipv4_menu_item);
            ipv4_menu_item.button.pressed.connect (on_ipv4_button_pressed);

            var dns_menu_item = new Ui.MenuItem.with_right_arrow ("DNS");
            menu.add_menu_item (dns_menu_item);
            dns_menu_item.button.pressed.connect (on_dns_button_pressed);

            var enet_menu_item = new Ui.MenuItem.with_right_arrow ("ENET");
            menu.add_menu_item (enet_menu_item);
            enet_menu_item.button.pressed.connect (on_enet_button_pressed);
        }

        void set_connect_button_text () {
            if (_is_connect_busy) {
                ((Label)connect_button.child).text = "Cancel";
            } else {
                if (_is_connected) {
                    ((Label)connect_button.child).text = "Disconnect";
                } else {
                    ((Label)connect_button.child).text = "Connect";
                }
            }
        }

        void on_connect_button_pressed () {
            // this has the effect of disconnecting if we are connected
            // or canceling the connect if we are connecting
            connect_requested (_is_connected || _is_connect_busy);
        }

        void on_ipv4_button_pressed () {
            ipv4_button_pressed ();
        }

        void on_dns_button_pressed () {
            dns_button_pressed ();
        }

        void on_enet_button_pressed () {
            enet_button_pressed ();
        }
    }
}
