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
 * NetworkStatusWindow.vala:
 *
 * Monitors network status and performs other network related functions
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class NetworkStatusWindow : BrickManagerWindow {
        Box state_hbox;
        Label state_label;
        Label state_value_label;
        UI.Menu menu;
        UI.MenuItem network_connections_menu_item;
        CheckboxMenuItem offline_mode_menu_item;

        public string state {
            get { return state_value_label.text; }
            set { state_value_label.text = value; }
        }

        public bool offline_mode {
            get { return offline_mode_menu_item.checkbox.checked; }
            set { offline_mode_menu_item.checkbox.checked = value; }
        }

        public signal void network_connections_selected ();
        public signal void tethering_selected ();

        public NetworkStatusWindow () {
            title = "Wireless and Networks";
            state_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            content_vbox.add (state_hbox);
            state_label = new Label ("Status:");
            state_hbox.add (state_label);
            state_value_label = new Label ("???");
            state_hbox.add (state_value_label);
            menu = new UI.Menu () {
                border_top = 1
            };
            content_vbox.add (menu);
            network_connections_menu_item = new UI.MenuItem.with_right_arrow ("All Network Connections");
            network_connections_menu_item.button.pressed.connect (() => network_connections_selected ());
            menu.add_menu_item (network_connections_menu_item);
            var tethering_menu_item = new UI.MenuItem.with_right_arrow ("Tethering");
            tethering_menu_item.button.pressed.connect (() => tethering_selected ());
            menu.add_menu_item (tethering_menu_item);
            offline_mode_menu_item = new CheckboxMenuItem ("Offline Mode");
            offline_mode_menu_item.checkbox.notify["checked"].connect ((s, p) => {
                notify_property ("offline-mode");
            });
            menu.add_menu_item (offline_mode_menu_item);
        }

        public void add_technology_window (BrickManagerWindow window) {
            var menu_item = new UI.MenuItem.with_right_arrow (window.title) {
                represented_object = window
            };
            menu_item.button.pressed.connect (() => window.show ());
            menu.insert_menu_item (menu_item, network_connections_menu_item);
        }
    }
}
