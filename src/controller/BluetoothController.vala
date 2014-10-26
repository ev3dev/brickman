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

/* BluetoothController.vala - Controller for Bluetooth (BlueZ) */

using BlueZ5;
using EV3devKit;

namespace BrickManager {
    public class BluetoothController : Object, IBrickManagerModule {
        BluetoothWindow main_window;
        BluetoothDevicesWindow devices_window;
        BluetoothAdaptersWindow adapters_window;
        Manager manager;

        public string menu_item_text { get { return "Bluetooth"; } }
        public Window start_window { get { return main_window; } }

        public BluetoothController () {
            main_window = new BluetoothWindow ();
            weak BluetoothWindow weak_main_window = main_window;
            main_window.devices_selected.connect (() =>
                weak_main_window.screen.show_window (devices_window));
            main_window.adapters_selected.connect (() =>
                weak_main_window.screen.show_window (adapters_window));
            devices_window = new BluetoothDevicesWindow ();
            devices_window.device_selected.connect ((obj) => {
                var device = obj as Device;
                var info_window = new BluetoothDeviceInfoWindow (device.name) {
                    loading = false
                };
                device.bind_property ("address", info_window, "address",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("icon", info_window, "icon",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("paired", info_window, "paired",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("connected", info_window, "connected",
                    BindingFlags.SYNC_CREATE);
                weak_main_window.screen.show_window (info_window);
            });
            adapters_window = new BluetoothAdaptersWindow ();
            adapters_window.adapter_selected.connect ((obj) => {
                var adapter = obj as Adapter;
                var info_window = new BluetoothDeviceInfoWindow (adapter.name) {
                    loading = false
                };
                weak_main_window.screen.show_window (info_window);
            });
            init_async.begin ((obj, res) => {
                try {
                    init_async.end (res);
                    main_window.loading = false;
                    devices_window.loading = false;
                    adapters_window.loading = false;
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            });
        }

        async void init_async () throws Error {
            manager = yield Manager.new_async ();
            manager.adapter_added.connect ((adapter) =>
                adapters_window.add_adapter (adapter.name, adapter));
            manager.adapter_removed.connect ((adapter) =>
                adapters_window.remove_adapter (adapter));
            manager.device_added.connect ((device) =>
                devices_window.add_device (device.name, device));
            manager.device_removed.connect ((device) =>
                devices_window.remove_device (device));
            manager.init ();
        }
    }
}