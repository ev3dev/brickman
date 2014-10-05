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

/* main.vala - main function */

using EV3devKit;

namespace BrickManager {

    public static int main (string[] args) {

        ConsoleApp.init ();

        var home_window = new HomeWindow ();
        var network_controller = new NetworkController ();
        home_window.add_controller (network_controller);
        var usb_controller = new USBController ();
        home_window.add_controller (usb_controller);
        var battery_controller = new BatteryController ();
        home_window.add_controller (battery_controller);
        ConsoleApp.screen.status_bar.add_right (battery_controller.battery_status_bar_item);

        Systemd.Logind.Manager logind_manager = null;
        Systemd.Logind.Manager.get_system_manager.begin ((obj, res) => {
            try {
                logind_manager = Systemd.Logind.Manager.get_system_manager.end (res);
                home_window.shutdown_dialog.power_off_button_pressed.connect (() => {
                    logind_manager.power_off.begin (false, (obj, res) => {
                        try {
                            logind_manager.power_off.end (res);
                            ConsoleApp.quit ();
                        } catch (IOError err) {
                            critical (err.message); // TODO show error message on brick
                        }
                    });
                });
                home_window.shutdown_dialog.reboot_button_pressed.connect (() => {
                    logind_manager.reboot.begin (false, (obj, res) => {
                        try {
                            logind_manager.reboot.end (res);
                            ConsoleApp.quit ();
                        } catch (IOError err) {
                            critical (err.message); // TODO show error message on brick
                        }
                    });
                });
            } catch (IOError err) {
                critical (err.message); // TODO show error message on brick
            }
        });
        ConsoleApp.screen.show_window (home_window);

        ConsoleApp.run ();

        return 0;
    }
}
