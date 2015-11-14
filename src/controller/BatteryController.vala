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

/* BatteryController.vala - Controller for monitoring battery */

using Ev3devKit.Devices;
using Ev3devKit.Ui;

namespace BrickManager {
    public class BatteryController : Object, IBrickManagerModule {
        BatteryInfoWindow battery_window;
        internal BatteryStatusBarItem battery_status_bar_item;
        PowerSupply? system_power_supply;

        public string display_name { get { return "Battery"; } }

        public void show_main_window () {
            if (battery_window == null) {
                create_battery_window ();
            }
            battery_window.show ();
        }

        public BatteryController () {
            battery_status_bar_item = new BatteryStatusBarItem ();
            system_power_supply = global_manager.device_manager.get_system_power_supply ();
            if (system_power_supply == null) {
                battery_status_bar_item.visible = false;
                warning ("Could not get system power supply.");
            } else {
                update_battery_info ();
                Timeout.add_seconds (5, update_battery_info);
            }
        }

        void create_battery_window () {
            battery_window = new BatteryInfoWindow (display_name);
            if (system_power_supply == null) {
                battery_window.available = false;
            } else {
                battery_window.technology = system_power_supply.technology.to_string ();
                update_battery_info ();
            }
        }

        bool update_battery_info () {
            if (system_power_supply == null) {
                return false;
            }

            var voltage = system_power_supply.voltage;
            battery_status_bar_item.voltage = voltage;

            if (battery_window != null) {
                battery_window.has_voltage = system_power_supply.has_voltage;
                battery_window.voltage = voltage;
                battery_window.has_current = system_power_supply.has_current;
                battery_window.current = system_power_supply.current * 1000;
                battery_window.has_power = system_power_supply.has_power;
                battery_window.power = system_power_supply.power;
            }

            return true;
        }
    }
}
