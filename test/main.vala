/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2014-2015,2017 David Lechner <david@lechnology.com>
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

using Ev3devKit.Ui;

namespace BrickManager {
    static int main (string[] args)
    {
        try {
            var app = new Ev3devKit.ConsoleApp ();

            var activate_id = app.activate.connect (() => {
                // Ev3devKit.ConsoleApp creates a top level Gtk.Window.
                var main_window = Gtk.Window.list_toplevels ().nth_data (0);
                var control_panel = new ControlPanel ();

                // position the windows nicely. main_window is centered on screen by default.
                int x;
                int y;
                main_window.get_position (out x, out y);
                main_window.move (x, y - Screen.get_active_screen ().height * 2);
                control_panel.window.move (x, y + 20);

                var home_window = new HomeWindow ();
                home_window.add_controller (control_panel.file_browser_controller);
                home_window.add_controller (control_panel.device_browser_controller);
                home_window.add_controller (control_panel.network_controller);
                control_panel.network_controller.add_controller (control_panel.bluetooth_controller);
                control_panel.network_controller.add_controller (control_panel.network_controller.wifi_controller);
                control_panel.bluetooth_controller.show_network_connection_requested.connect ((name) =>
                    control_panel.network_controller.show_connection (name));
                home_window.add_controller (control_panel.battery_controller);
                home_window.add_controller (control_panel.open_roberta_controller);
                home_window.add_controller (control_panel.about_controller);

                Screen.get_active_screen ().status_bar.visible = true;
                Screen.get_active_screen ().status_bar.add_left (control_panel.network_controller.network_status_bar_item);

                Screen.get_active_screen ().status_bar.add_right (control_panel.battery_controller.battery_status_bar_item);
                Screen.get_active_screen ().status_bar.add_right (control_panel.network_controller.wifi_status_bar_item);
                Screen.get_active_screen ().status_bar.add_right (control_panel.bluetooth_controller.bluetooth_status_bar_item);
                Screen.get_active_screen ().status_bar.add_right (control_panel.open_roberta_controller.status_bar_item);

                home_window.shutdown_dialog.power_off_button_pressed.connect (() =>
                    app.quit ());
                home_window.shutdown_dialog.reboot_button_pressed.connect (() => {
                    var dialog = new Dialog () {
                        padding = 10
                    };
                    var label = new Label ("Reboot is not implemented.");
                    dialog.add (label);
                    dialog.show ();
                });
                home_window.show ();
            });

            app.run ();
            app.disconnect (activate_id);

            return 0;
        } catch (GLib.Error err) {
            critical ("%s", err.message);
            return 1;
        }
    }
}
