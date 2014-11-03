/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * BluetoothDeviceInfoWindow.vala:
 */

using EV3devKit;

namespace BrickManager {
    public class BluetoothDeviceInfoWindow : BrickManagerWindow {
        Label address_label;
        Label icon_label;
        Label paired_label;
        Label connected_label;
        Box uuid_vbox; 

        public string address {
            get { return address_label.text; }
            set { address_label.text = value; }
        }

        public string icon {
            get { return icon_label.text; }
            set { icon_label.text = value; }
        }

        bool _paired;
        public bool paired {
            get { return _paired; }
            set {
                 _paired = value;
                 paired_label.text = value ? "paried" : "unparied";
            }
        }

        bool _connected;
        public bool connected {
            get { return _connected; }
            set {
                 _connected = value;
                 connected_label.text = value ? "connected" : "disconnected";
            }
        }

        public BluetoothDeviceInfoWindow () {
            var vscroll = new Scroll.vertical ();
            content_vbox.add (vscroll);
            var scroll_vbox = new Box.vertical ();
            vscroll.add (scroll_vbox);
            address_label = new Label ();
            scroll_vbox.add (address_label);
            icon_label = new Label ();
            scroll_vbox.add (icon_label);
            paired_label = new Label ();
            scroll_vbox.add (paired_label);
            connected_label = new Label ();
            scroll_vbox.add (connected_label);
            uuid_vbox = new Box.vertical ();
            scroll_vbox.add (uuid_vbox);
        }
    }
}
