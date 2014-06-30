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
 * BrickDisplayManager.vala:
 *
 * Version of Brick Display Manager that runs if GTK for testing.
 */

using Gtk;

namespace BrickDisplayManager {

    static int main (string[] args)
    {
        Gtk.init (ref args);

        var main_window = new Window ();
        main_window.title = "Brick Display Manager Test";
        main_window.window_position = WindowPosition.CENTER;
        main_window.destroy.connect (Gtk.main_quit);

        var gui = new GUI ();
        main_window.add (gui.lcd);

        main_window.show_all ();
        Gtk.main ();
        return 0;
    }
}
