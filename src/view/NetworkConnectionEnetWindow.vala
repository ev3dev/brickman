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
 * NetworkConnectionEnetWindow.vala:
 *
 * Displays ENET properties of a network connection.
 */

using Ev3devKit.Ui;

namespace BrickManager {
    class NetworkConnectionEnetWindow : BrickManagerWindow {
        Label method_label;
        Label interface_label;
        Label address_label;
        Label mtu_label;

        public string method {
            get { return method_label.text; }
            set { method_label.text = value; }
        }

        public string interface {
            get { return interface_label.text; }
            set { interface_label.text = value; }
        }

        public string address {
            get { return address_label.text; }
            set { address_label.text = value; }
        }

        int _mtu;
        public int mtu {
            get { return _mtu; }
            set {
                _mtu = value;
                mtu_label.text = "%d".printf (value);
            }
        }

        public NetworkConnectionEnetWindow (string title) {
            this.title = title;

            var scroll = new Scroll.vertical ();
            content_vbox.add (scroll);
            var vbox = new Box.vertical ();
            scroll.add (vbox);

            vbox.add (new Label ("Interface:") {
                margin_top = 6
            });
            interface_label = new Label ();
            vbox.add (interface_label);

            vbox.add (new Label ("MAC address:") {
                margin_top = 6
            });
            address_label = new Label ();
            vbox.add (address_label);

            vbox.add (new Label ("MTU:") {
                margin_top = 6
            });
            mtu_label = new Label ();
            vbox.add (mtu_label);

            vbox.add (new Label ("Method:") {
                margin_top = 6
            });
            method_label = new Label ();
            vbox.add (method_label);
        }
    }
}
