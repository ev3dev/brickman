/*
 * bluez5 -- DBus bindings for BlueZ 5 <http://www.bluez.org>
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY throws IOError; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Manager.vala:
 */

namespace BlueZ5 {
    public class Manager : Object {
        org.freedesktop.DBus.ObjectManager dbus_proxy;

        public signal void adapter_added (Adapter adapter);
        public signal void adapter_removed (ObjectPath path);
        public signal void device_added (Device device);
        public signal void device_removed (ObjectPath path);

        public static async Manager new_async () throws IOError {
            var manager = new Manager ();
            weak Manager weak_manager = manager;
            manager.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                org.bluez.SERVICE_NAME, "/");
            var objs = yield manager.dbus_proxy.get_managed_objects ();
            manager.dbus_proxy.interfaces_added.connect (weak_manager.on_interfaces_added);
            manager.dbus_proxy.interfaces_removed.connect (weak_manager.on_interfaces_removed);
            objs.foreach ((path, ifaces) =>
                manager.on_interfaces_added (path, ifaces));
            return manager;
        }

        void on_interfaces_added (ObjectPath object_path,
            HashTable<string, HashTable<string, Variant>> interfaces_and_properties)
        {
            // message ("object_path - %s:", object_path);
            interfaces_and_properties.foreach ((iface, properties) => {
                // message ("\tiface - %s:", iface);
                // properties.foreach ((prop_name, prop_value) => {
                //     message ("\t\tproperty - %s: %s", prop_name, prop_value.print (true));
                // });
                switch (iface) {
                case "org.bluez.Adapter1":
                    // TODO: need to copy parameters since we are sending them to an 
                    // async method or call a sync method instead, because they
                    // will be freed by dbus signal before the async method is complete.
                    Adapter.new_async.begin (object_path, properties, (obj, res) => {
                        try {
                            var adapter = Adapter.new_async.end (res);
                            adapter_added (adapter);
                        } catch (IOError err) {
                            critical ("%s", err.message);
                        }
                    });
                    break;
                case "org.bluez.Device1":
                    // TODO: need to copy parameters since we are sending them to an 
                    // async method or call a sync method instead, because they
                    // will be freed by dbus signal before the async method is complete.
                    Device.new_async.begin (object_path, properties, (obj, res) => {
                        try {
                            var device = Device.new_async.end (res);
                            device_added (device);
                        } catch (IOError err) {
                            critical ("%s", err.message);
                        }
                    });
                    break;
                }
            });
        }

        void on_interfaces_removed (ObjectPath object_path, string[] interfaces) {
            foreach (var iface in interfaces) {
                switch (iface) {
                case "org.bluez.Adapter1":
                    adapter_removed (object_path);
                    break;
                case "org.bluez.Device1":
                    device_removed (object_path);
                    break;
                }
                
            }
        }
    }
}

namespace org.bluez {
    public const string SERVICE_NAME = "org.bluez";
}