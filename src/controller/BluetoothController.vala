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
        DBusObjectManagerClient manager_client;

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
                    loading = false,
                    address = device.address,
                    icon = device.icon,
                    paired = device.paired,
                    connected = device.connected
                };
                weak BluetoothDeviceInfoWindow weak_info_window = info_window;
                var properties_changed_handler_id =
                    ((DBusProxy)device).g_properties_changed.connect (
                        (changed, invalidated) => {
                            var iter = changed.iterator ();
                            string? name = null;
                            Variant? value = null;
                            while (iter.next ("{sv}", &name, &value)) {
                                switch (name) {
                                case "Address":
                                    weak_info_window.address = device.address;
                                    break;
                                case "Icon":
                                    weak_info_window.icon = device.icon;
                                    break;
                                case "Paired":
                                    weak_info_window.paired = device.paired;
                                    break;
                                case "Connected":
                                    weak_info_window.connected = device.connected;
                                    break;
                                }
                            }
                        });
                info_window.weak_ref (() => {
                    SignalHandler.disconnect (device, properties_changed_handler_id);
                });
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

        delegate Type TypeFunc ();

        async void init_async () throws Error {
            manager_client = yield DBusObjectManagerClient.new_for_bus (
                BusType.SYSTEM, DBusObjectManagerClientFlags.NONE, "org.bluez",
                "/", (manager, object_path, interface_name) => {
                    if (interface_name == null)
                        return typeof (DBusObjectProxy);
                    Type dev_type;
                    switch (interface_name) {
                    case "org.bluez.Adapter1":
                        dev_type = typeof (Adapter);
                        break;
                    case "org.bluez.Device1":
                        dev_type = typeof (Device);
                        break;
                    default:
                        return typeof (DBusProxy);
                    }
                    // quark stuff is workaround for bug 710817
                    var q = Quark.from_string ("vala-dbus-proxy-type");
                    return ((TypeFunc)dev_type.get_qdata (q)) ();
                });
            manager_client.interface_added.connect (on_interface_added);
            manager_client.interface_removed.connect (on_interface_removed);
            foreach (var obj in manager_client.get_objects ()) {
                foreach (var iface in obj.get_interfaces ())
                    on_interface_added (obj, iface);
            }
        }

        void on_interface_added (DBusObject obj, DBusInterface iface) {
            var adapter = iface as Adapter;
            if (adapter != null)
                adapters_window.add_adapter (adapter.name, adapter);
            var device = iface as Device;
            if (device != null)
                devices_window.add_device (device.name, device);
        }

        void on_interface_removed (DBusObject obj, DBusInterface iface) {
            var adapter = iface as Adapter;
            if (adapter != null)
                adapters_window.remove_adapter (adapter);
            var device = iface as Device;
            if (device != null)
                devices_window.remove_device (device);
        }
    }
}