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

/* BatteryController.vala - Controller for monitoring battery */

using EV3devKit;

namespace BrickManager {
    public class BatteryController : Object, IBrickManagerModule {
        BatteryInfoWindow battery_window;
        GUdev.Client power_supply_client;
        GUdev.Device ev3_battery;

        public string menu_item_text { get { return "Battery"; } }
        public Window start_window { get { return battery_window; } }

        public BatteryController () {
            battery_window = new BatteryInfoWindow ();
            power_supply_client = new GUdev.Client ({ "power_supply"});
            ev3_battery = power_supply_client.query_by_subsystem_and_name ("power_supply", "legoev3-battery");
            if (ev3_battery == null)
                critical ("Could not get legoev3-battery device");
            else {
                battery_window.technology = ev3_battery.get_sysfs_attr ("technology") ?? "Error";
                update_battery_info ();
                Timeout.add_seconds (10, update_battery_info);
                battery_window.loading = false;
            }
        }

        bool update_battery_info () {
            battery_window.voltage = ev3_battery.get_sysfs_attr_as_int ("voltage_now") / 1000000.0;
            battery_window.current = ev3_battery.get_sysfs_attr_as_int ("current_now") / 1000.0;
            return true;
        }
    }
}