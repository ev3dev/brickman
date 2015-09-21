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
 * DeviceBrowserWindow.vala: Main Device Browser Menu
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class DeviceBrowserWindow : BrickManagerWindow {
        internal Ui.Menu menu;

        public signal void ports_menu_item_selected ();
        public signal void sensors_menu_item_selected ();
        public signal void motors_menu_item_selected ();

        public DeviceBrowserWindow (string display_name) {
            title = display_name;
            menu = new Ui.Menu ();
            content_vbox.add (menu);
            var ports_menu_item = new Ui.MenuItem.with_right_arrow ("Ports");
            ports_menu_item.button.pressed.connect (() =>
                ports_menu_item_selected ());
            menu.add_menu_item (ports_menu_item);
            var sensors_menu_item = new Ui.MenuItem.with_right_arrow ("Sensors");
            sensors_menu_item.button.pressed.connect (() =>
                sensors_menu_item_selected ());
            menu.add_menu_item (sensors_menu_item);
            var motors_menu_item = new Ui.MenuItem.with_right_arrow ("Motors");
            motors_menu_item.button.pressed.connect (() =>
                motors_menu_item_selected ());
            menu.add_menu_item (motors_menu_item);
        }
    }
}
