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

/* main.vala - main function */

using Ev3devKit;
using Ev3devKit.Ui;
using Linux.VirtualTerminal;
using Posix;

namespace BrickManager {
    const string SPLASH_PNG = "splash.png";

    // The global_manager is shared by all of the controller objects
    GlobalManager global_manager;

    /**
     * Opens the current virtual terminal.
     *
     * @param vtfd The file descriptor for the new console.
     * @param vtnum The number of the virtual terminal.
     * @throws IOError if we failed to open or activate a new console.
     */
    public void open_vt (out int vtfd, out int vtnum) throws IOError {
        // The compiler complains about unassigned variables if we don't initialize
        vtfd = 0;
        vtnum = 0;

        var tty_fd = open ("/dev/tty", O_RDWR, 0);
        if (tty_fd < 0) {
            throw (IOError) new Error (IOError.quark (), io_error_from_errno (-tty_fd),
                "Failed to open /dev/tty: %s", GLib.strerror (-tty_fd));
        }
        try {
            Linux.VirtualTerminal.Stat vtstat;
            var err = ioctl (tty_fd, VT_GETSTATE, out vtstat);
            if (err < 0) {
                throw (IOError) new Error (IOError.quark (), io_error_from_errno (-err),
                    "Could not get state for /dev/tty: %s", GLib.strerror (-err));
            }
            vtnum = vtstat.v_active;
            var device = "/dev/tty" + vtnum.to_string ();
            err = access (device, (W_OK | R_OK));
            if (err < 0) {
                throw (IOError) new Error (IOError.quark (), io_error_from_errno (-err),
                    "Insufficient permission for %s: %s", device, GLib.strerror (-err));
            }
            vtfd = open (device, O_RDWR, 0);
            if (vtfd < 0) {
                throw (IOError) new Error (IOError.quark (), io_error_from_errno (-vtfd),
                    "Could not open %s: %s", device, GLib.strerror (-vtfd));
            }
        } finally {
            close (tty_fd);
        }
    }

    public static int main (string[] args) {
        int vtfd, vtnum;
        try {
            open_vt (out vtfd, out vtnum);
        } catch (Error err) {
            critical ("%s", err.message);
            Process.exit (err.code);
        }
        try {
            ConsoleApp.init (vtfd);
        } catch (Error err) {
            critical ("%s", err.message);
            close (vtfd);
            Process.exit (err.code);
        }
        // Get something up on the screen ASAP.
        var splash_path_found = true;
        var splash_path = Path.build_filename (Environment.get_current_dir (), SPLASH_PNG);
        if (!FileUtils.test (splash_path, FileTest.EXISTS)) {
            splash_path = Path.build_filename (PKGDATADIR, SPLASH_PNG);;
            if (!FileUtils.test (splash_path, FileTest.EXISTS))
                splash_path_found = false;
        }
        if (!splash_path_found) {
            critical ("Could not find %s", splash_path);
        } else {
            if (Grx.Context.screen.load_from_png (splash_path) != 0)
                critical ("%s", "Could not load splash image.");
        }

        global_manager = new GlobalManager ();

        Screen.get_active_screen ().status_bar.visible = true;

        var home_window = new HomeWindow ();
        var file_browser_controller = new FileBrowserController ();
        home_window.add_controller (file_browser_controller);
        var device_browser_controller = new DeviceBrowserController ();
        home_window.add_controller (device_browser_controller);
        var network_controller = new NetworkController ();
        home_window.add_controller (network_controller);
        var bluetooth_controller = new BluetoothController ();
        network_controller.add_controller (bluetooth_controller);
        network_controller.add_controller (network_controller.wifi_controller);
        var battery_controller = new BatteryController ();
        home_window.add_controller (battery_controller);
        var about_controller = new AboutController ();
        home_window.add_controller (about_controller);

        Screen.get_active_screen ().status_bar.add_left (network_controller.network_status_bar_item);

        Screen.get_active_screen ().status_bar.add_right (battery_controller.battery_status_bar_item);
        Screen.get_active_screen ().status_bar.add_right (network_controller.wifi_status_bar_item);
        Screen.get_active_screen ().status_bar.add_right (bluetooth_controller.status_bar_item);

        global_manager.back_button_long_pressed.connect_after (() =>
            home_window.shutdown_dialog.show ());

        Systemd.Logind.Manager logind_manager = null;
        Systemd.Logind.Manager.get_system_manager.begin ((obj, res) => {
            try {
                logind_manager = Systemd.Logind.Manager.get_system_manager.end (res);
                home_window.shutdown_dialog.power_off_button_pressed.connect (() => {
                    logind_manager.power_off.begin (false, (obj, res) => {
                        try {
                            logind_manager.power_off.end (res);
                            global_manager.set_leds (LedState.BUSY);
                            ConsoleApp.quit ();
                        } catch (IOError err) {
                            var dialog = new MessageDialog ("Error", err.message);
                            dialog.show ();
                        }
                    });
                });
                home_window.shutdown_dialog.reboot_button_pressed.connect (() => {
                    logind_manager.reboot.begin (false, (obj, res) => {
                        try {
                            logind_manager.reboot.end (res);
                            global_manager.set_leds (LedState.BUSY);
                            ConsoleApp.quit ();
                        } catch (IOError err) {
                            var dialog = new MessageDialog ("Error", err.message);
                            dialog.show ();
                        }
                    });
                });
            } catch (IOError err) {
                var dialog = new MessageDialog ("Error", err.message);
                dialog.show ();
            }
        });
        home_window.show ();
        global_manager.set_leds (LedState.NORMAL);

        ConsoleApp.run ();

        close (vtfd);
        return 0;
    }
}
