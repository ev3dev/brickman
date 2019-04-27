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

using Bluez5;
using Ev3devKit.Ui;

namespace BrickManager {
    public class BluetoothController : Object, IBrickManagerModule {
        BluetoothWindow main_window;
        internal BluetoothStatusBarItem status_bar_item;
        Manager manager;
        Bluez5Agent? agent;
        ObjectPath agent_object_path;
        string? built_in_adapter_address;
        List<Adapter> adapter_list;
        Adapter? selected_adapter;
        Binding? selected_adapter_visible_binding;
        Binding? selected_adapter_scanning_binding;
        uint connection_count = 0;

        public string display_name { get { return "Bluetooth"; } }

        public bool connected { get { return connection_count > 0; } }

        public signal void show_network_requested (string mac_address);

        internal uint adapter_count { get; set; default = 0; }

        public void show_main_window () {
            main_window.show ();
        }

        public BluetoothController () {
            adapter_list = new List<Adapter> ();
            main_window = new BluetoothWindow (display_name) {
                loading = true,
                available = false
            };
            main_window.scan_selected.connect (on_scan_selected);
            main_window.closed.connect (() => {
                if (selected_adapter != null && selected_adapter.discovering)
                    selected_adapter.stop_discovery.begin ();
            });

            status_bar_item = new BluetoothStatusBarItem ();
            bind_property ("connected", status_bar_item, "connected");

            /* Use udev to find the address of the built-in Bluetooth adapter */
            var udev_client = new GUdev.Client (null);
            var udev_devices = udev_client.query_by_subsystem ("bluetooth");
            if (udev_devices != null) {
                foreach (var udev_device in udev_devices) {
                    var parent = udev_device.get_parent ();
                    if (parent != null && parent.get_name () == "ttyS2") {
                        // FIXME: there is no such sysfs attr
                        var address = udev_device.get_sysfs_attr ("address");
                        if (address != null) {
                            built_in_adapter_address = address.up ();
                            break;
                        }
                    }
                }
            }

            try {
                agent = new Bluez5Agent ();
                var bus = Bus.get_sync (BusType.SYSTEM);
                agent_object_path = new ObjectPath ("/org/ev3dev/brickman/bluez5_agent");
                bus.register_object<Bluez5Agent> (agent_object_path, agent);
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
                        var menu_item = main_window.find_menu_item (device);
                        main_window.remove_menu_item (menu_item);
                    }
                    set_selected_adapter (null);
                    manager = null;
                });
        }

        public void bind_powered (Object obj, string property) {
            obj.bind_property (property, main_window, "powered",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            obj.bind_property (property, status_bar_item, "visible",
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
            main_window.available = selected_adapter != null;
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
            adapter_list.append (adapter);
            adapter_count++;
            // make the new adapter the selected adapter unless it is the built-in adapter.
            if (selected_adapter == null
                    || selected_adapter.address == built_in_adapter_address)
                set_selected_adapter (adapter);
        }

        void on_adapter_removed (Adapter adapter) {
            // if the selected adapter is removed, replace it with the first adapter
            // that is not the built-in adapter.
            adapter_list.remove (adapter);
            adapter.unref (); // List<G>.remove () does not unref automatically
            adapter_count--;
            if (selected_adapter == adapter) {
                set_selected_adapter (null);
                foreach (var a in adapter_list) {
                    if (a.address != built_in_adapter_address) {
                        set_selected_adapter (a);
                        break;
                    }
                }
                // If the built-in adapter is the only adapter available, then use it.
                if (selected_adapter == null && adapter_list != null) {
                    set_selected_adapter (adapter_list.data);
                }
            }
        }

        void on_device_added (Device device) {
            var menu_item = new BluetoothDeviceMenuItem ();
            device.bind_property ("alias", menu_item, "name",
                BindingFlags.SYNC_CREATE);
            device.bind_property ("connected", menu_item, "connected",
                BindingFlags.SYNC_CREATE);
            device.adapter.bind_property ("alias", menu_item, "adapter",
                BindingFlags.SYNC_CREATE);
            bind_property ("adapter-count", menu_item, "show-adapter",
                BindingFlags.SYNC_CREATE, transform_adapter_count_to_show_adapter);
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
            main_window.add_menu_item (menu_item);

            // Bluez DBus API does not have a global "connected" property so we
            // have to keep track of all of the connections ourselves in order
            // to make the Bluetooth status bar icon work.
            weak Device weak_device = device;
            device.notify["connected"].connect (() => {
                if (weak_device.connected)
                    connection_count++;
                else
                    connection_count--;
                notify_property ("connected");
            });
            if (device.connected) {
                connection_count++;
                notify_property ("connected");
            }
        }

        void on_device_removed (Device device) {
            var menu_item = main_window.find_menu_item (device);
            main_window.remove_menu_item (menu_item);

            if (device.connected) {
                connection_count--;
                notify_property ("connected");
            }
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

        bool transform_adapter_count_to_show_adapter (Binding binding, Value source, ref Value target) {
            target = adapter_count > 1;
            return true;
        }

        bool transform_uuids_to_has_network (Binding binding, Value source, ref Value target) {
            target = false;
            var uuids = (string[])source;
            foreach (var uuid in uuids) {
                if (uuid == Uuid.NAP || uuid == Uuid.GN || uuid == Uuid.PANU) {
                    target = true;
                    break;
                }
            }
            return true;
        }
    }
}