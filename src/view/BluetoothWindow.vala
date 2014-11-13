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
 * BluetoothWindow.vala: Main Bluetooth Menu
 */

using EV3devKit;

namespace BrickManager {
    public class BluetoothWindow : BrickManagerWindow {
        internal EV3devKit.Menu menu;
        CheckboxMenuItem visible_menu_item;
        EV3devKit.MenuItem scan_menu_item;

        public bool bt_visible {
            get { return visible_menu_item.checkbox.checked; }
            set { visible_menu_item.checkbox.checked = value; }
        }

        bool _scanning;
        public bool scanning {
            get { return _scanning; }
            set {
                _scanning = value;
                scan_menu_item.label.text = value ? "Stop Scan" : "Start Scan";
            }
        }

        public signal void scan_selected ();

        public BluetoothWindow () {
            title ="Bluetooth";
            menu = new EV3devKit.Menu () {
                max_preferred_height = 50
            };
            content_vbox.add (menu);
            visible_menu_item = new CheckboxMenuItem ("Visible");
            visible_menu_item.checkbox.notify["checked"].connect (() =>
                notify_property ("bt-visible"));
            menu.add_menu_item (visible_menu_item);
            scan_menu_item = new EV3devKit.MenuItem ("???");
            scan_menu_item.label.horizontal_align = WidgetAlign.START;
            scan_menu_item.button.pressed.connect (() => scan_selected ());
            menu.add_menu_item (scan_menu_item);
            var devices_label_menu_item = new EV3devKit.MenuItem ("Devices");
            devices_label_menu_item.button.border_bottom = 1;
            devices_label_menu_item.button.margin_bottom = 2;
            devices_label_menu_item.button.can_focus = false;
            menu.add_menu_item (devices_label_menu_item);
        }
    }
}
