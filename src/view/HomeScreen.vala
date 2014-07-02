/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
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
 * HomeScreen.vala:
 *
 * The home screen for brickdm.
 */

using Gee;
using M2tk;

namespace BrickDisplayManager {

    class HomeScreen : Screen {
        HashMap<GStrItem, ScreenInfo?> screen_info_map;

        GStrList _menu_list;

        public signal void menu_item_selected (uint8 index, Object? user_data);

        public HomeScreen() {
            screen_info_map = new HashMap<GStrItem, ScreenInfo?>();
            _menu_list = new GStrList(100) {
                visible_line_count = 5,
                extra_column_size = 12
            };
            child = _menu_list;
        }

        public void add_menu_item(string text, Object? user_data) {
            var item = new GStrItem(text, "*", user_data);
            item.selected.connect(on_menu_item_selected);
            _menu_list.item_list.add(item);
        }

        void on_menu_item_selected(uchar index, GStrItem item) {
            menu_item_selected (index, item.user_data);
        }

        struct ScreenInfo {
            Screen screen;
            uint index;

            public ScreenInfo(Screen screen, uint index) {
                this.screen = screen;
                this.index = index;
            }
        }
    }
}
