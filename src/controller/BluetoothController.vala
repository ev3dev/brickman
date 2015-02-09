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

/* BluetoothController.vala - Controller for Bluetooth (BlueZ) */

using BlueZ5;
using EV3devKit.UI;

namespace BrickManager {
    public class BluetoothController : Object, IBrickManagerModule {
        BluetoothWindow main_window;
        Manager manager;
        BlueZ5Agent? agent;
        ObjectPath agent_object_path;
        string? built_in_adapter_address;
        Gee.List<Adapter> adapter_list;
        Adapter? selected_adapter;
        Binding? selected_adapter_visible_binding;
        Binding? selected_adapter_scanning_binding;

        public BrickManagerWindow start_window { get { return main_window; } }

        public signal void show_network_requested (string mac_address);

        public BluetoothController () {
            adapter_list = new Gee.LinkedList<Adapter> ();
            main_window = new BluetoothWindow () {
                loading = true
            };
            main_window.scan_selected.connect (on_scan_selected);
            main_window.closed.connect (() => {
                if (selected_adapter != null && selected_adapter.discovering)
                    selected_adapter.stop_discovery.begin ();
            });

            /* Use udev to find the address of the built-in Bluetooth adapter */
            var udev_client = new GUdev.Client (null);
            var udev_devices = udev_client.query_by_subsystem ("bluetooth");
            if (udev_devices != null) {
                foreach (var udev_device in udev_devices) {
                    var parent = udev_device.get_parent ();
                    if (parent != null && parent.get_name () == "ttyS2") {
                        built_in_adapter_address = udev_device.get_sysfs_attr ("address").up ();
                        break;
                    }
                }
            }

            try {
                agent = new BlueZ5Agent ();
                var bus = Bus.get_sync (BusType.SYSTEM);
                agent_object_path = new ObjectPath ("/org/ev3dev/brickman/bluez5_agent");
                bus.register_object<BlueZ5Agent> (agent_object_path, agent);
            } catch (IOError err) {
                critical ("%s", err.message);
            }

            Bus.watch_name (BusType.SYSTEM, Manager.SERVICE_NAME,
                BusNameWatcherFlags.AUTO_START, () => {
                    // Called when the bluez service is registered.
                    init_async.begin ((obj, res) => {
                        try {
                            init_async.end (res);
                            main_window.loading = false;
                        } catch (Error err) {
                            critical ("%s", err.message);
                        }
                    });
                }, () => {
                    // Called when the bluez service is disappears (shutdown or crashed).
                    main_window.loading = true;
                    var devices = manager.get_devices ();
                    foreach (var device in devices) {
                        var menu_item = main_window.menu.find_menu_item<Device> (device,
                            (mi, d) => d == mi.represented_object);
                        main_window.menu.remove_menu_item (menu_item);
                    }
                    set_selected_adapter (null);
                    manager = null;
                });
        }

        public void bind_powered (Object obj, string property) {
            obj.bind_property (property, main_window, "powered",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
        }

        async void init_async () throws Error {
            manager = yield Manager.new_async ();
            manager.adapter_added.connect (on_adapter_added);
            manager.adapter_removed.connect (on_adapter_removed);
            manager.device_added.connect (on_device_added);
            manager.device_removed.connect (on_device_removed);
            foreach (var adapter in manager.get_adapters ())
                on_adapter_added (adapter);
            foreach (var device in manager.get_devices ())
                on_device_added (device);
            try {
                yield manager.agent_manager.register_agent (agent_object_path,
                    AgentManagerCapability.KEYBOARD_DISPLAY);
                yield manager.agent_manager.request_default_agent (agent_object_path);
            } catch (BlueZError err) {
                critical ("%s", err.message);
            }
        }

        void set_selected_adapter (Adapter? new_adapter) {
            if (selected_adapter != null) {
                if (selected_adapter.discovering)
                    selected_adapter.stop_discovery.begin ();
                selected_adapter_visible_binding.unbind ();
                selected_adapter_visible_binding = null;
                selected_adapter_scanning_binding.unbind ();
                selected_adapter_scanning_binding = null;
            }
            selected_adapter = new_adapter;
            if (selected_adapter != null) {
                selected_adapter_visible_binding = selected_adapter.bind_property (
                    "discoverable", main_window, "bt-visible",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                selected_adapter_scanning_binding = selected_adapter.bind_property (
                    "discovering", main_window, "scanning", BindingFlags.SYNC_CREATE);
            }
        }

        void on_scan_selected () {
            if (selected_adapter == null) {
                critical ("No adapter is selected.");
                return;
            }

            if (selected_adapter.discovering) {
                selected_adapter.stop_discovery.begin ((obj, res) => {
                    try {
                        selected_adapter.stop_discovery.end (res);
                    } catch (IOError err) {
                        critical ("%s", err.message);
                    }
                });
            } else {
                selected_adapter.start_discovery.begin ((obj, res) => {
                    try {
                        selected_adapter.start_discovery.end (res);
                    } catch (IOError err) {
                        critical ("%s", err.message);
                    }
                });
            }
        }

        void on_adapter_added (Adapter adapter) {
            adapter_list.add (adapter);
            // make the new adapter the selected adapter unless it is the built-in adapter.
            if (selected_adapter == null
                    || selected_adapter.address == built_in_adapter_address)
                set_selected_adapter (adapter);
        }

        void on_adapter_removed (Adapter adapter) {
            // if the selected adapter is removed, replace it with the first adapter
            // that is not the built-in adapter.
            adapter_list.remove (adapter);
            if (selected_adapter == adapter) {
                set_selected_adapter (null);
                foreach (var a in adapter_list) {
                    if (a.address != built_in_adapter_address) {
                        set_selected_adapter (a);
                        break;
                    }
                }
                // If the built-in adapter is the only adapter available, then use it.
                if (selected_adapter == null && adapter_list.size > 0)
                    set_selected_adapter (adapter_list[0]);
            }
        }

        void on_device_added (Device device) {
            var menu_item = new BluetoothDeviceMenuItem ();
            device.bind_property ("alias", menu_item, "name",
                BindingFlags.SYNC_CREATE);
            device.bind_property ("connected", menu_item, "connected",
                BindingFlags.SYNC_CREATE);
            menu_item.represented_object = device;
            menu_item.button.pressed.connect (() => {
                var device_window = new BluetoothDeviceWindow () {
                    loading = false
                };
                weak BluetoothDeviceWindow weak_device_window = device_window;
                device.bind_property ("alias", device_window, "title",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("address", device_window, "address",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("paired", device_window, "paired",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("connected", device_window, "connected",
                    BindingFlags.SYNC_CREATE);
                device.bind_property ("uuids", device_window, "has_network",
                    BindingFlags.SYNC_CREATE, transform_uuids_to_has_network);
                device_window.connect_selected.connect (() => {
                    if (!device.paired)
                        pair_device.begin (device);
                    else if (device.connected)
                        disconnect_device.begin (device);
                    else
                        connect_device.begin (device);
                });
                device_window.remove_selected.connect (() =>
                    remove_device.begin (device));
                device_window.network_selected.connect (() =>
                    show_network_requested (device.alias));
                var handler_id = manager.device_removed.connect (() =>
                    weak_device_window.close ());
                device_window.weak_ref (() =>
                    SignalHandler.disconnect (manager, handler_id));
                device_window.show ();
            });
            main_window.menu.add_menu_item (menu_item);
        }

        void on_device_removed (Device device) {
            var menu_item = main_window.menu.find_menu_item<Device> (device, (mi, d) =>
                d == mi.represented_object);
            main_window.menu.remove_menu_item (menu_item);
        }

        // TODO: some kind of "spinner" to indicate that we are busy would be
        // nice for the next 4 methods

        async void remove_device (Device device) {
            try {
                yield device.adapter.remove_device (device);
            } catch (IOError err) {
                var dialog = new MessageDialog ("Error", err.message);
                dialog.show ();
            }
        }

        async void pair_device (Device device) {
            try {
                yield device.pair ();
                device.trusted = true;
            } catch (IOError err) {
                var dialog = new MessageDialog ("Error", err.message);
                dialog.show ();
            }
        }

        async void disconnect_device (Device device) {
            try {
                yield device.disconnect_device ();
            } catch (IOError err) {
                var dialog = new MessageDialog ("Error", err.message);
                dialog.show ();
            }
        }

        async void connect_device (Device device) {
            try {
                yield device.connect_device ();
            } catch (IOError err) {
                var dialog = new MessageDialog ("Error", err.message);
                dialog.show ();
            }
        }

        bool transform_uuids_to_has_network (Binding binding, Value source, ref Value target) {
            target = false;
            var uuids = (string[])source;
            foreach (var uuid in uuids) {
                if (uuid == UUID.NAP || uuid == UUID.GN || uuid == UUID.PANU) {
                    target = true;
                    break;
                }
            }
            return true;
        }
    }
}