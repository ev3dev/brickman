/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * based in part on GNOME Power Manager:
 * Copyright (C) 2008-2011 Richard Hughes <richard@hughsie.com>
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
 * Power.vala:
 *
 * Monitors battery status and performs other power related functions
 */

using M2tk;
using Up;

namespace BrickDisplayManager {

    class Power {
        const string EV3_BATTERY_PATH =
            "/org/freedesktop/UPower/devices/battery_legoev3_battery";

        double battery_hist_data[100];
        Device ev3_battery;

        public BatteryInfoScreen battery_info_screen { get; private set; }
        public ShutdownScreen shutdown_screen { get; private set; }
        public BatteryStatusBarItem battery_status_bar_item { get; private set; }

        public Power() {
            battery_info_screen = new BatteryInfoScreen();
            shutdown_screen = new ShutdownScreen();
            battery_status_bar_item = new BatteryStatusBarItem();

            try {
                ev3_battery = new Device();
                ev3_battery.set_object_path_sync(EV3_BATTERY_PATH);
                ev3_battery.changed.connect(on_ev3_battery_changed);
                ev3_battery.changed();
            } catch (Error err) {
                warning("%s", err.message);
            }
        }

        void on_ev3_battery_changed() {
            battery_info_screen.technology = Device.technology_to_string(ev3_battery.technology);
            battery_info_screen.voltage = ev3_battery.voltage;
            battery_info_screen.power = ev3_battery.energy_rate;

            battery_status_bar_item.voltage = ev3_battery.voltage;
        }
/*
        void update_battery_hist_data(Device device)
        {
            debug("Getting history.");
            try {
                var items = device.get_history_sync("rate", 3600, battery_hist_data.length);
                items.foreach((item) => {
                    //battery_hist_data[i] = item.get_value();
                    debug("time: %ud, state: %d, value: %.2f", item.get_time(),
                        item.get_state (), item.get_value());
                });
            } catch (Error err) {
                warning("%s", err.message);
                // TODO: show error message
            }
        }

        void on_battery_hist_button(ElementFuncArgs arg)
        {
            try {
                Device device = new Device();
                device.set_object_path_sync(EV3_BATTERY_PATH);
                update_battery_hist_data(device);
                //gui.set_root(_battery_hist_root);
            } catch (Error err) {
                warning("%s", err.message);
                //TODO: show error message
            }
        }

        void battery_hist_graph_callback(ElementFuncArgs arg)
        {
            unowned U8g.Graphics u8g = gui.m2tk.graphics;

            debug("Drawing graph.");
            for (ushort i = 0; i < battery_hist_data.length; i++)
                u8g.draw_pixel(i, (ushort)(battery_hist_data[i]*20));
        }
    }
*/
}
