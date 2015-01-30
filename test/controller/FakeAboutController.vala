/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* FakeAboutController.vala - Fake About controller for testing */

using EV3devKit.UI;

namespace BrickManager {
    public class FakeAboutController : Object, IBrickManagerModule {
        AboutWindow about_window;

        public string menu_item_text { get { return "About"; } }
        public Window start_window { get { return about_window; } }

        public FakeAboutController (Gtk.Builder builder) {
            about_window = new AboutWindow () {
                loading = false,
                eeprom_version = "V0.00"
            };
            var utsname = Posix.UTSName ();
            if (Posix.uname (ref utsname) == 0) {
                about_window.kernel_version = utsname.release;
            } else {
                critical ("Failed to get kernel version.");
            }
        }
    }
}