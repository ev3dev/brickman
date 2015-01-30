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
 * BluetoothDeviceMenuItem.vala: Custom MenuItem for showing bluetooth device status.
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class BluetoothDeviceMenuItem : UI.MenuItem {
        const string PERCENT = "%";

        CheckButton connected_checkbox;

        public string name {
            get { return label.text; }
            set { label.text = value; }
        }

        public bool connected {
            get { return connected_checkbox.checked; }
            set { connected_checkbox.checked = value; }
        }

        public BluetoothDeviceMenuItem () {
            base.with_button (new Button () { margin_top = 1 }, new Label ());
            var hbox = new Box.horizontal ();
            button.add (hbox);
            hbox.add (label);
            hbox.add (new Spacer ());
            connected_checkbox = new CheckButton.checkbox () {
                can_focus = false
            };
            hbox.add (connected_checkbox);
        }
    }
}
