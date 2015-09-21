/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* AboutController.vala - Controller for about window */

using Ev3devKit.Ui;

namespace BrickManager {
    public class AboutController : Object, IBrickManagerModule {
        AboutWindow about_window;

        public string display_name { get { return "About"; } }

        public void show_main_window () {
            if (about_window == null) {
                create_about_window ();
            }
            about_window.show ();
        }

        void create_about_window () {
            about_window = new AboutWindow (display_name);
            var i2c_client = new GUdev.Client ({ "i2c"});
            var ev3_eeprom = i2c_client.query_by_subsystem_and_name ("i2c", "1-0050");
            if (ev3_eeprom == null)
                critical ("Could not get EV3 EEPROM device");
            else {
                var path = Path.build_filename (ev3_eeprom.get_sysfs_path (), "eeprom");
                var eeprom_file = File.new_for_path (path);
                try {
                    var eeprom_input_stream = eeprom_file.read ();
                    eeprom_input_stream.seek (0x3f00, SeekType.SET);
                    var version = eeprom_input_stream.read_bytes (1);
                    about_window.eeprom_version = "V%d.%d0".printf (version[0] / 10, version[0] % 10);
                } catch (Error e) {
                    critical ("%s", e.message);
                }
            }
            var utsname = Posix.UTSName ();
            if (Posix.uname (ref utsname) == 0) {
                about_window.kernel_version = utsname.release;
            } else {
                critical ("Failed to get kernel version.");
            }
        }
    }
}