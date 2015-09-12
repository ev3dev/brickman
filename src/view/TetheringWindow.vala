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
 * TetheringWindow.vala:
 *
 * Shows list of types of tethering and allows user to enable/disable them.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class TetheringWindow : BrickManagerWindow {
        Ui.Menu menu;
        Ui.MenuItem tethering_info_menu_item;

        public signal void tethering_info_selected ();

        public TetheringWindow () {
            title = "Tethering";
            menu = new Ui.Menu () {
                margin_top = -3
            };
            content_vbox.add (menu);
            tethering_info_menu_item = new Ui.MenuItem.with_right_arrow ("Network info");
            tethering_info_menu_item.button.pressed.connect (() => tethering_info_selected ());
            tethering_info_menu_item.label.text_horizontal_align = Grx.TextHorizAlign.LEFT;
            menu.add_menu_item (tethering_info_menu_item);
        }

        public CheckboxMenuItem add_menu_item (string name) {
            var menu_item = new CheckboxMenuItem (name);
            menu.insert_menu_item (menu_item, tethering_info_menu_item);
            return menu_item;
        }

        public void remove_menu_item (CheckboxMenuItem menu_item) {
            menu.remove_menu_item (menu_item);
        }
    }
}
