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
 * BluetoothDeviceMenuItem.vala: Custom MenuItem for showing bluetooth device status.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class BluetoothDeviceMenuItem : Ui.MenuItem {
        const string PERCENT = "%";

        Label adapter_label;
        CheckButton connected_checkbox;

        public string name {
            get { return label.text; }
            set { label.text = value; }
        }

        public string adapter {
            owned get { return adapter_label.text[1:adapter_label.text.length - 1]; }
            set { adapter_label.text = "(%s)".printf (value); }
        }

        public bool show_adapter {
            get { return adapter_label.visible; }
            set { adapter_label.visible = value; }
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
            adapter_label = new Label ("(???)") {
                visible = false
            };
            hbox.add (adapter_label);
            hbox.add (new Spacer ());
            connected_checkbox = new CheckButton.checkbox () {
                can_focus = false
            };
            hbox.add (connected_checkbox);
        }
    }
}
