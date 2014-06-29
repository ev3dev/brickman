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
        HashMap<GButton, ScreenInfo?> screen_info_map;

        GVList _menu_list;

        public HomeScreen() {
            screen_info_map = new HashMap<GButton, ScreenInfo?>();
            _menu_list = new GVList();

            child = _menu_list;
        }

        public void add_menu_item(string text, Screen screen) {
            var button = new GButton(text);
            var screen_info = ScreenInfo(screen, _menu_list.children.size);
            screen_info_map[button] = screen_info;
            button.pressed.connect(on_menu_item_selected);
            _menu_list.children.add(button);
        }

        void on_menu_item_selected(GButton button) {
            gui.m2tk.set_root(screen_info_map[button].screen,
                0, (uint8)screen_info_map[button].index);
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
