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
 * NetworkStatusWindow.vala:
 *
 * Monitors network status and performs other network related functions
 */

using EV3devKit;

namespace BrickManager {
    public class NetworkStatusWindow : BrickManagerWindow {
        Box state_hbox;
        Label state_label;
        Label state_value_label;
        internal EV3devKit.Menu menu;
        EV3devKit.MenuItem manage_connections_menu_item;
        EV3devKit.CheckboxMenuItem airplane_mode_menu_item;

        public string state {
            get { return state_value_label.text; }
            set { state_value_label.text = value; }
        }

        public bool airplane_mode {
            get { return airplane_mode_menu_item.checkbox.checked; }
            set { airplane_mode_menu_item.checkbox.checked = value; }
        }

        public signal void manage_connections_selected ();

        public NetworkStatusWindow () {
            title ="Networking";
            state_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER
            };
            content_vbox.add (state_hbox);
            state_label = new Label ("Status:");
            state_hbox.add (state_label);
            state_value_label = new Label ("???");
            state_hbox.add (state_value_label);
            menu = new EV3devKit.Menu () {
                min_height = 95
            };
            content_vbox.add (menu);
            manage_connections_menu_item = new EV3devKit.MenuItem ("Manage connections...");
            manage_connections_menu_item.button.pressed.connect (() => manage_connections_selected ());
            manage_connections_menu_item.label.text_horizontal_align = GRX.TextHorizAlign.LEFT;
            menu.add_menu_item (manage_connections_menu_item);
            airplane_mode_menu_item = new EV3devKit.CheckboxMenuItem ("Airplane Mode");
            airplane_mode_menu_item.checkbox.notify["checked"].connect ((s, p) => {
                notify_property ("airplane-mode");
            });
            menu.add_menu_item (airplane_mode_menu_item);
        }
    }
}
