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
 * HomeWindow.vala:
 *
 * The home window for brickman.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {

    class HomeWindow : Window {
        internal ShutdownDialog shutdown_dialog;
        Ui.Menu menu;

        public HomeWindow () {
            shutdown_dialog = new ShutdownDialog ();
            menu = new Ui.Menu ();
            add (menu);
        }

        public void add_controller (IBrickManagerModule controller) {
            var menu_item = new Ui.MenuItem.with_right_arrow (controller.start_window.title) {
                represented_object = controller
            };
            menu_item.button.pressed.connect (() =>
                controller.start_window.show ());
            menu.add_menu_item (menu_item);
        }

        /**
         * Default handler for the key_pressed signal.
         */
        protected override bool key_pressed (uint key_code) {
            if (key_code == Curses.Key.BACKSPACE) {
                shutdown_dialog.show ();
                Signal.stop_emission_by_name (this, "key-pressed");
                return true;
            }
            return false;
        }
    }
}
