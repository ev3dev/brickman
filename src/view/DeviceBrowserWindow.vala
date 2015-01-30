/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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
 * DeviceBrowserWindow.vala: Main Device Browser Menu
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class DeviceBrowserWindow : BrickManagerWindow {
        internal UI.Menu menu;

        public signal void ports_menu_item_selected ();
        public signal void sensors_menu_item_selected ();

        public DeviceBrowserWindow () {
            title ="Device Browser";
            menu = new UI.Menu () {
                max_preferred_height = 50
            };
            content_vbox.add (menu);
            var ports_menu_item = new UI.MenuItem ("Ports");
            ports_menu_item.button.pressed.connect (() =>
                ports_menu_item_selected ());
            menu.add_menu_item (ports_menu_item);
            var sensors_menu_item = new UI.MenuItem ("Sensors");
            sensors_menu_item.button.pressed.connect (() =>
                sensors_menu_item_selected ());
            menu.add_menu_item (sensors_menu_item);
        }
    }
}
