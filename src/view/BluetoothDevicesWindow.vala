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
 * BluetoothDevicesWindow.vala: Main Bluetooth Menu
 */

using EV3devKit;

namespace BrickManager {
    public class BluetoothDevicesWindow : BrickManagerWindow {
        internal EV3devKit.Menu menu;

        public BluetoothDevicesWindow () {
            title ="Devices";
            menu = new EV3devKit.Menu ();
            content_vbox.add (menu);
        }

        public void add_device (string name, Object represented_object) {
            var menu_item = new EV3devKit.MenuItem (name);
            menu_item.represented_object = represented_object;
            menu.add_menu_item (menu_item);
        }
    }
}
