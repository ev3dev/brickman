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
 * SelectFromListDialog.vala: Main Device Browser Menu
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class SelectFromListDialog : Dialog {
        public signal void item_selected (string list_item);

        public SelectFromListDialog (string[] list_items) {
            var menu = new UI.Menu () {
                margin = 6,
                spacing = 2
            };
            add (menu);
            foreach (var list_item in list_items) {
                var menu_item = new UI.MenuItem (list_item);
                menu_item.button.border = 1;
                menu_item.button.border_radius = 3;
                var handler_id = menu_item.button.pressed.connect (() => {
                    item_selected (list_item);
                    close ();
                });
                unref ();
                weak_ref (() => {
                    ref ();
                    menu_item.button.disconnect (handler_id);
                });
                menu.add_menu_item (menu_item);
            }
        }
    }
}
