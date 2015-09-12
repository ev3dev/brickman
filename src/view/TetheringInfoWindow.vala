/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2015 David Lechner <david@lechnology.com>
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
 * TetheringInfoWindow.vala:
 *
 * Shows network information about tether interface.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class TetheringInfoWindow : BrickManagerWindow {
        Label ipv4_address_value_label;
        Label ipv4_netmask_value_label;
        Label enet_iface_value_label;
        Label enet_mac_value_label;

        public string ipv4_address {
            get { return ipv4_address_value_label.text; }
            set { ipv4_address_value_label.text = value; }
        }

        public string ipv4_netmask {
            get { return ipv4_netmask_value_label.text; }
            set { ipv4_netmask_value_label.text = value; }
        }

        public string enet_iface {
            get { return enet_iface_value_label.text; }
            set { enet_iface_value_label.text = value; }
        }

        public string enet_mac {
            get { return enet_mac_value_label.text; }
            set { enet_mac_value_label.text = value; }
        }

        public TetheringInfoWindow () {
            title = "Tethering Network Info";
            var vscroll = new Scroll.vertical () {
                margin_top = -3
            };
            content_vbox.add (vscroll);
            var scroll_vbox = new Box.vertical ();
            vscroll.add (scroll_vbox);
            var ipv4_label = new Label ("IPV4") {
                border_bottom = 1,
                margin = 3
            };
            scroll_vbox.add (ipv4_label);
            var ipv4_address_label = new Label ("IP Address:");
            scroll_vbox. add (ipv4_address_label);
            ipv4_address_value_label = new Label ("???");
            scroll_vbox. add (ipv4_address_value_label);
            var ipv4_netmask_label = new Label ("Mask:") {
                margin_top = 3
            };
            scroll_vbox. add (ipv4_netmask_label);
            ipv4_netmask_value_label = new Label ("???");
            scroll_vbox. add (ipv4_netmask_value_label);
            var enet_label = new Label ("ENET") {
                border_bottom = 1,
                margin = 3,
                margin_top = 6
            };
            scroll_vbox.add (enet_label);
            var enet_iface_label = new Label ("Interface:");
            scroll_vbox.add (enet_iface_label);
            enet_iface_value_label = new Label ("???");
            scroll_vbox.add (enet_iface_value_label);
            var enet_mac_label = new Label ("MAC:") {
                margin_top = 3
            };
            scroll_vbox.add (enet_mac_label);
            enet_mac_value_label = new Label ("???");
            scroll_vbox.add (enet_mac_value_label);
        }
    }
}
