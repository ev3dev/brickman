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
 * WifiNetworkWindow.vala: View for a single Wi-Fi network.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class WifiNetworkWindow : BrickManagerWindow {
        Label status_value_label;
        Ui.Menu menu;
        Ui.MenuItem action_menu_item;
        Ui.MenuItem forget_menu_item;
        Ui.MenuItem network_connection_menu_item;

        public string status {
            get {
                return status_value_label.text;
            }
            set {
                status_value_label.text = value;
            }
        }

        public string action {
            get {
                return action_menu_item.label.text;
            }
            set {
                action_menu_item.label.text = value;
            }
        }

        bool _can_forget = true;
        public bool can_forget {
            get {
                return _can_forget;
            }
            set {
                if (value == _can_forget) {
                    return;
                }
                if (value) {
                    menu.insert_menu_item (forget_menu_item,
                        network_connection_menu_item);
                } else {
                    menu.remove_menu_item (forget_menu_item);
                }
                _can_forget = value;
            }
        }

        public signal void status_selected ();

        public signal void action_selected ();

        public signal void forget_selected ();

        public signal void network_connection_selected ();

        public WifiNetworkWindow (string name) {
            title = name;

            var status_hbox = new Box.horizontal () {
                padding_top = -6,
                padding_bottom = -3,
                border_bottom = 1
            };
            content_vbox.add (status_hbox);
            var status_label = new Label ("Status:") {
                text_horizontal_align = Grx.TextHorizAlign.RIGHT
            };
            status_hbox.add (status_label);
            status_value_label = new Label ("???") {
                text_horizontal_align = Grx.TextHorizAlign.LEFT
            };
            status_hbox .add (status_value_label);

            menu = new Ui.Menu ();
            content_vbox.add (menu);

            var status_menu_item = new Ui.MenuItem.with_right_arrow ("Status");
            menu.add_menu_item (status_menu_item);
            status_menu_item.button.pressed.connect (() => status_selected ());

            action_menu_item = new Ui.MenuItem ("???");
            menu.add_menu_item (action_menu_item);
            action_menu_item.button.pressed.connect (() => action_selected ());

            forget_menu_item = new Ui.MenuItem ("Forget");
            menu.add_menu_item (forget_menu_item);
            forget_menu_item.button.pressed.connect (() => forget_selected ());

            network_connection_menu_item =
                new Ui.MenuItem.with_right_arrow ("Network Connection");
            menu.add_menu_item (network_connection_menu_item);
            network_connection_menu_item.button.pressed.connect (() =>
                network_connection_selected ());
        }
    }
}
