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
 * HomeWindow.vala:
 *
 * The home window for brickman.
 */

using EV3devKit;

namespace BrickManager {

    class HomeWindow : Window {
        internal ShutdownDialog shutdown_dialog;
        EV3devKit.Menu menu;

        public HomeWindow () {
            shutdown_dialog = new ShutdownDialog ();
            menu = new EV3devKit.Menu ();
            add (menu);
        }

        public void add_controller (IBrickManagerModule controller) {
            var menu_item = new EV3devKit.MenuItem (controller.menu_item_text) {
                represented_object = controller
            };
            menu_item.button.pressed.connect (() =>
                screen.push_window (controller.start_window));
            menu.add_menu_item (menu_item);
        }

        public override bool key_pressed (uint key_code) {
            if (key_code == Curses.Key.BACKSPACE) {
                screen.push_window (shutdown_dialog);
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return false;
        }
    }
}
