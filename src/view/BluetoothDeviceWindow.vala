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
 * BluetoothDeviceWindow.vala:
 */

using EV3devKit.UI;

namespace BrickManager {
    public class BluetoothDeviceWindow : BrickManagerWindow {
        Label address_label;
        Button network_button;
        Button connect_button;
        Button remove_button;

        public string address {
            get { return address_label.text; }
            set { address_label.text = value; }
        }

        bool _paired;
        public bool paired {
            get { return _paired; }
            set {
                 _paired = value;
                 update_connect_button ();
            }
        }

        bool _connected;
        public bool connected {
            get { return _connected; }
            set {
                 _connected = value;
                 update_connect_button ();
            }
        }

        public bool has_network {
            get { return network_button.visible; }
            set { network_button.visible = value; }
        }

        public signal void network_selected ();
        public signal void connect_selected ();
        public signal void remove_selected ();

        public BluetoothDeviceWindow () {
            address_label = new Label ();
            content_vbox.add (address_label);
            content_vbox.add (new Spacer ());
            network_button = new Button.with_label ("Network Connection") {
                visible = false,
                margin_left = 6,
                margin_right = 6
            };
            network_button.pressed.connect (() => network_selected ());
            content_vbox.add (network_button);
            var button_hbox = new Box.horizontal () {
                margin = 6,
                margin_top = 1
            };
            content_vbox.add (button_hbox);
            connect_button = new Button.with_label ("???");
            connect_button.pressed.connect (() => {
                focus_none ();
                connect_selected ();
            });
            button_hbox.add (connect_button);
            remove_button = new Button.with_label ("Remove");
            remove_button.pressed.connect (() => {
                focus_none ();
                remove_selected ();
            });
            button_hbox.add (remove_button);
        }

        void update_connect_button () {
            ((Label)connect_button.child).text = _paired ?
                (_connected ? "Disconnect" : "Connect") : "Pair";
        }

        void focus_none () {
            do_recursive_children ((widget) => {
                widget.has_focus = false;
                return null;
            });
        }
    }
}
