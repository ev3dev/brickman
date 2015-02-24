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
 * WifiInfoWindow.vala: Displays Wi-Fi connection info.
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class WifiInfoWindow : BrickManagerWindow {
        Label status_value_label;
        Label signal_value_label;
        Label security_value_label;
        Label address_value_label;
        Button action_button;
        Button forget_button;

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

        public string action {
            get { return (action_button.child as Label).text; }
            set { (action_button.child as Label).text = value; }
        }

        public bool can_forget {
            get { return forget_button.visible; }
            set { forget_button.visible = value; }
        }

        public signal void action_selected ();

        public signal void forget_selected ();

        public signal void network_connection_selected ();

        public WifiInfoWindow (string name) {
            title = name;

            var vscroll = new Scroll.vertical () {
                can_focus = false
            };
            content_vbox.add (vscroll);
            var scroll_vbox = new Box.vertical () {
                spacing = 3
            };
            vscroll.add (scroll_vbox);

            var status_hbox = new Box.horizontal ();
            scroll_vbox.add (status_hbox);
            var status_label = new Label ("Status:") {
                horizontal_align = WidgetAlign.START
            };
            status_hbox.add (status_label);
            status_value_label = new Label ("???") {
                text_horizontal_align = GRX.TextHorizAlign.RIGHT
            };
            status_hbox .add (status_value_label);

            var signal_hbox = new Box.horizontal ();
            scroll_vbox.add (signal_hbox);
            var signal_label = new Label ("Signal:") {
                horizontal_align = WidgetAlign.START
            };
            signal_hbox.add (signal_label);
            signal_value_label = new Label ("???") {
                text_horizontal_align = GRX.TextHorizAlign.RIGHT
            };
            signal_hbox .add (signal_value_label);

            var security_hbox = new Box.horizontal ();
            scroll_vbox.add (security_hbox);
            var security_label = new Label ("Security:") {
                horizontal_align = WidgetAlign.START
            };
            security_hbox.add (security_label);
            security_value_label = new Label ("???") {
                text_horizontal_align = GRX.TextHorizAlign.RIGHT
            };
            security_hbox .add (security_value_label);

            var address_hbox = new Box.horizontal ();
            scroll_vbox.add (address_hbox);
            var address_label = new Label ("IP Address:") {
                horizontal_align = WidgetAlign.START
            };
            address_hbox.add (address_label);
            address_value_label = new Label ("???") {
                text_horizontal_align = GRX.TextHorizAlign.RIGHT
            };
            address_hbox .add (address_value_label);

            var button_hbox = new Box.horizontal ();
            scroll_vbox.add (button_hbox);
            action_button = new Button.with_label ("???");
            action_button.pressed.connect (() => action_selected ());
            button_hbox.add (action_button);
            forget_button = new Button.with_label ("Forget");
            forget_button.pressed.connect (() => forget_selected ());
            button_hbox.add (forget_button);

            var network_connection_button = new Button.with_label ("Network Connection");
            network_connection_button.pressed.connect (() => network_connection_selected ());
            scroll_vbox.add (network_connection_button);
        }
    }
}
