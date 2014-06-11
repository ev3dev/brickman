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

using M2tk;

namespace BrickDisplayManager {

    class HomeScreen : Screen {

        Power power;

        GButton _battery_menu_item;
        GButton _shutdown_menu_item;
        GVList _menu_list;

        public HomeScreen(Power power) {
            debug("initializing Home");
            this.power = power;

            //Root.create(network.root_element, "Network"),
            _battery_menu_item = new GButton("Battery");
            _battery_menu_item.pressed.connect(on_battery_menu_item_pressed);
            _shutdown_menu_item = new GButton("Shutdown");
            _shutdown_menu_item.pressed.connect(on_shutdown_menu_item_pressed);
            _menu_list = new GVList();
            _menu_list.add(_battery_menu_item);
            _menu_list.add(_shutdown_menu_item);

            child = _menu_list;
        }

        void on_battery_menu_item_pressed() {
            gui.m2tk.set_root(power.battery_info_screen);
        }

        void on_shutdown_menu_item_pressed() {
            gui.m2tk.set_root(power.shutdown_screen, 0, 1);
        }
    }
}
