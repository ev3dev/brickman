/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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
 * main.vala:
 *
 * Version of Brick Manager that runs in GTK for testing.
 */

using EV3devKit;

namespace BrickManager {
    static int main (string[] args)
    {
        DesktopTestApp.init (args);
        DesktopTestApp.main_window.title = "brickman test";
        var control_panel = new ControlPanel ();

        // position the windows nicely. main_window is centered on screen by default.
        int x;
        int y;
        DesktopTestApp.main_window.get_position (out x, out y);
        int width;
        int height;
        DesktopTestApp.main_window.get_size (out width, out height);
        control_panel.window.move (x, y + 20);
        DesktopTestApp.main_window.move (x, y - height);

        var home_window = new HomeWindow ();
        home_window.add_controller (control_panel.device_browser_controller);
        home_window.add_controller (control_panel.network_controller);
        home_window.add_controller (control_panel.bluetooth_controller);
        home_window.add_controller (control_panel.usb_controller);
        home_window.add_controller (control_panel.battery_controller);
        home_window.add_controller (control_panel.about_controller);
        Screen.active_screen.status_bar.add_right (
            control_panel.battery_controller.battery_status_bar_item);
        Screen.active_screen.status_bar.add_left (
            control_panel.network_controller.network_status_bar_item);
        home_window.shutdown_dialog.power_off_button_pressed.connect (() =>
            DesktopTestApp.quit ());
        home_window.shutdown_dialog.reboot_button_pressed.connect (() => {
            var dialog = new Dialog () {
                padding = 10
            };
            var label = new Label ("Reboot is not implemented.");
            dialog.add (label);
            dialog.show ();
        });
        home_window.show ();
        
        DesktopTestApp.run ();

        return 0;
    }
}
