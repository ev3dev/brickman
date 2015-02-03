/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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

using EV3devKit;
using EV3devKit.UI;
using Linux.VirtualTerminal;
using Posix;

namespace BrickManager {
    const string SPLASH_PNG = "splash.png";

    // The global_manager is shared by all of the controller objects
    GlobalManager global_manager;

    /**
     * Opens the next free virtual terminal and makes it the active console.
     *
     * @param vtfd The file descriptor for the new console.
     * @param new_vt The number of the new virtual terminal.
     * @param old_vt The number of the active virtual terminal.
     * @throws IOError if we failed to open or activate a new console.
     */
    public void open_and_activate_new_vt (out int vtfd, out int new_vt, out int old_vt) throws IOError {
        // The compiler complains about unassigned variables if we don't initialize
        vtfd = 0;
        new_vt = 0;
        old_vt = 0;

        var tty0_fd = open ("/dev/tty0", O_RDWR, 0);
        if (tty0_fd < 0) {
            throw (IOError) new Error (IOError.quark (), io_error_from_errno (-tty0_fd),
                "Failed to open /dev/tty0: %s", GLib.strerror (-tty0_fd));
        }
        try {
            Linux.VirtualTerminal.Stat vtstat;
            var err = ioctl (tty0_fd, VT_GETSTATE, out vtstat);
            if (err < 0) {
                throw (IOError) new Error (IOError.quark (), io_error_from_errno (-err),
                    "Could not get state for /dev/tty0: %s", GLib.strerror (-err));
            }
            old_vt = vtstat.v_active;
            err = ioctl (tty0_fd, VT_OPENQRY, out new_vt);
            if (err < 0) {
                throw (IOError) new Error (IOError.quark (), io_error_from_errno (-err),
                    "Failed to get new VT: %s", GLib.strerror (-err));
            }
            var device = "/dev/tty" + new_vt.to_string ();
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
            try {
                err = ioctl (vtfd, VT_ACTIVATE, new_vt);
                if (err < 0) {
                    throw (IOError) new Error (IOError.quark (), io_error_from_errno (-err),
                        "Failed to activate VT %d: %s", new_vt, GLib.strerror (-err));
                }
                err = ioctl (vtfd, VT_WAITACTIVE, new_vt);
                if (err < 0) {
                    throw (IOError) new Error (IOError.quark (), io_error_from_errno (-err),
                        "Waiting for VT %d to activate failed: %s", new_vt, GLib.strerror (-err));
                }
            } catch (IOError err) {
                close (vtfd);
                throw err;
            }
        } finally {
            close (tty0_fd);
        }
    }

    /**
     * Close a virtual terminal that was opened with open_and_activate_new_vt().
     *
     * If the new virtual terminal is the active console, then the previous
     * console will be activated.
     *
     * @param fd The file descriptor of the new virtual terminal.
     * @param new_vt The number of the new virtual terminal.
     * @param old_vt The state of the previous active console.
     */
    public void close_vt (int fd, int new_vt, int old_vt) {
        Linux.VirtualTerminal.Stat vtstat;
        if (ioctl (fd, VT_GETSTATE, out vtstat) == 0) {
            if (vtstat.v_active == new_vt) {
                ioctl (fd, VT_ACTIVATE, old_vt);
                ioctl (fd, VT_WAITACTIVE, old_vt);
            }
        }
        ioctl (fd, VT_DISALLOCATE, new_vt);
        close (fd);
    }

    public static int main (string[] args) {
        int vtfd, new_vtnum, old_vtnum;
        try {
            open_and_activate_new_vt (out vtfd, out new_vtnum, out old_vtnum);
            ConsoleApp.init (vtfd);
        } catch (IOError err) {
            critical ("%s", err.message);
            Process.exit (err.code);
        } catch (ConsoleApp.ConsoleAppError err) {
            critical ("%s", err.message);
            close_vt (vtfd, new_vtnum, old_vtnum);
            Process.exit (err.code);
        }
        // Get something up on the screen ASAP.
        string splash_path = SPLASH_PNG;
        if (!FileUtils.test (splash_path, FileTest.EXISTS)) {
            splash_path = null;
            foreach (var file in Environment.get_system_data_dirs ()) {
                file = Path.build_filename (file, PROJECT_NAME, SPLASH_PNG);
                if (FileUtils.test (file, FileTest.EXISTS)) {
                    splash_path = file;
                    break;
                }
            }
        }
        if (splash_path == null) {
            critical ("Could not find %s", SPLASH_PNG);
        } else {
            if (GRX.Context.screen.load_from_png (splash_path) != 0)
                critical ("%s", "Could not load splash image.");
        }

        global_manager = new GlobalManager ();
        global_manager.set_leds (LEDState.NORMAL);

        Screen.get_active_screen ().status_bar.visible = true;

        var home_window = new HomeWindow ();
        var file_browser_controller = new FileBrowserController ();
        home_window.add_controller (file_browser_controller);
        var device_browser_controller = new DeviceBrowserController ();
        home_window.add_controller (device_browser_controller);
        var network_controller = new NetworkController ();
        home_window.add_controller (network_controller);
        Screen.get_active_screen ().status_bar.add_left (network_controller.network_status_bar_item);
        var bluetooth_controller = new BluetoothController ();
        home_window.add_controller (bluetooth_controller);
        var usb_controller = new USBController ();
        home_window.add_controller (usb_controller);
        var battery_controller = new BatteryController ();
        home_window.add_controller (battery_controller);
        Screen.get_active_screen ().status_bar.add_right (battery_controller.battery_status_bar_item);
        var about_controller = new AboutController ();
        home_window.add_controller (about_controller);

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
                            global_manager.set_leds (LEDState.BUSY);
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
                            global_manager.set_leds (LEDState.BUSY);
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

        ConsoleApp.run ();

        close_vt (vtfd, new_vtnum, old_vtnum);
        return 0;
    }
}
