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
        public const string SERVICE_NAME = "org.bluez";

        DBusObjectManagerClient client;

        delegate Type TypeFunc ();

        public signal void adapter_added (Adapter adapter);
        public signal void adapter_removed (Adapter adapter);

        public signal void device_added (Device device);
        public signal void device_removed (Device device);

        public static async Manager new_async () throws Error {
            var manager = new Manager ();
            weak Manager weak_manager = manager;
            manager.client = yield DBusObjectManagerClient.new_for_bus (
                BusType.SYSTEM, DBusObjectManagerClientFlags.NONE, SERVICE_NAME,
                "/", (manager, object_path, interface_name) => {
                    if (interface_name == null)
                        return typeof (DBusObjectProxy);
                    Type dev_type;
                    switch (interface_name) {
                    case "org.bluez.Adapter1":
                        dev_type = typeof (org.bluez.Adapter1);
                        break;
                    case "org.bluez.AgentManager1":
                        dev_type = typeof (org.bluez.AgentManager1);
                        break;
                    case "org.bluez.Device1":
                        dev_type = typeof (org.bluez.Device1);
                        break;
                    default:
                        return typeof (DBusProxy);
                    }
                    // quark stuff is workaround for bug 710817
                    var q = Quark.from_string ("vala-dbus-proxy-type");
                    return ((TypeFunc)dev_type.get_qdata (q)) ();
                });
            manager.client.interface_added.connect (weak_manager.on_interface_added);
            manager.client.interface_removed.connect (weak_manager.on_interface_removed);
            return manager;
        }

        /**
         * Finish initializing.
         *
         * Triggers *_added signals for already existing objects.
         */
        public void init () {
            foreach (var obj in client.get_objects ()) {
                foreach (var iface in obj.get_interfaces ())
                    on_interface_added (obj, iface);
            }
        }

        void on_interface_added (DBusObject obj, DBusInterface iface) {
            var adapter = iface as org.bluez.Adapter1;
            if (adapter != null)
                adapter_added (new Adapter ((DBusProxy)adapter));
            var agent_manager = iface as org.bluez.AgentManager1;
            if (agent_manager != null)
                AgentManager.instance = new AgentManager ((DBusProxy)agent_manager);
            var device = iface as org.bluez.Device1;
            if (device != null)
                device_added (new Device ((DBusProxy)device));
        }

        void on_interface_removed (DBusObject obj, DBusInterface iface) {
            var path = obj.get_object_path ();
            var adapter = iface as org.bluez.Adapter1;
            if (adapter != null)
                adapter_removed (Adapter.get_for_object_path (path));
            var agent_manager = iface as org.bluez.AgentManager1;
            if (agent_manager != null)
                AgentManager.instance = null;
            var device = iface as org.bluez.Device1;
            if (device != null)
                device_removed (Device.get_for_object_path (path));
        }
    }
}
