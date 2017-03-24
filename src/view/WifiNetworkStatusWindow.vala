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
 * WifiNetworkStatusWindow.vala: View for displaying status of a single Wi-Fi network.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class WifiNetworkStatusWindow : BrickManagerWindow {
        Label status_value_label;
        Label signal_value_label;
        Label security_value_label;
        Label address_value_label;

        public string status {
            get { return status_value_label.text; }
            set { status_value_label.text = value; }
        }

        public string signal_strength {
            owned get { return signal_value_label.text[0:-1]; }
            set { signal_value_label.text = value + "%"; }
        }

        public string security {
            get { return security_value_label.text; }
            set { security_value_label.text = value; }
        }

        public string address {
            get { return address_value_label.text; }
            set { address_value_label.text = value; }
        }

        public WifiNetworkStatusWindow (string name) {
            title = name;

            var status_hbox = new Box.horizontal () {
                padding_top = -6,
                padding_bottom = -3,
                border_bottom = 1
            };
            content_vbox.add (status_hbox);
            var status_label = new Label ("Status:") {
                text_horizontal_align = Grx.TextHAlign.RIGHT
            };
            status_hbox.add (status_label);
            status_value_label = new Label ("???") {
                text_horizontal_align = Grx.TextHAlign.LEFT
            };
            status_hbox .add (status_value_label);

            var vscroll = new Scroll.vertical () {
                can_focus = false
            };
            content_vbox.add (vscroll);
            var scroll_vbox = new Box.vertical () {
                spacing = 3
            };
            vscroll.add (scroll_vbox);

            var signal_hbox = new Box.horizontal ();
            scroll_vbox.add (signal_hbox);
            var signal_label = new Label ("Signal:") {
                horizontal_align = WidgetAlign.START
            };
            signal_hbox.add (signal_label);
            signal_value_label = new Label ("???") {
                text_horizontal_align = Grx.TextHAlign.RIGHT
            };
            signal_hbox .add (signal_value_label);

            var security_hbox = new Box.horizontal ();
            scroll_vbox.add (security_hbox);
            var security_label = new Label ("Security:") {
                horizontal_align = WidgetAlign.START
            };
            security_hbox.add (security_label);
            security_value_label = new Label ("???") {
                text_horizontal_align = Grx.TextHAlign.RIGHT
            };
            security_hbox .add (security_value_label);

            var address_hbox = new Box.horizontal ();
            scroll_vbox.add (address_hbox);
            var address_label = new Label ("IP Address:") {
                horizontal_align = WidgetAlign.START
            };
            address_hbox.add (address_label);
            address_value_label = new Label ("???") {
                text_horizontal_align = Grx.TextHAlign.RIGHT
            };
            address_hbox .add (address_value_label);
        }
    }
}
