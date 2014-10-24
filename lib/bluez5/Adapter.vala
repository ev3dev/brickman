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
 * Adapter.vala:
 */

namespace BlueZ5 {
    public class Adapter : Object {
        org.bluez.Adapter1 dbus_proxy;

        public string object_path { 
            owned get { return ((DBusProxy)dbus_proxy).g_object_path; }
        }

        public string address { owned get { return dbus_proxy.address; } }
        public string name { owned get { return dbus_proxy.name; } }
        public string alias { owned get { return dbus_proxy.alias; } }
        public uint32 class { get { return dbus_proxy.class; } }
        public bool powered { get { return dbus_proxy.powered; } }
        public bool discoverable {
            get { return dbus_proxy.discoverable; }
            set { dbus_proxy.discoverable = value; }
        }
        public bool pairable {
            get { return dbus_proxy.pairable; }
            set { dbus_proxy.pairable = value; }
        }
        public uint32 pairable_timeout {
            get { return dbus_proxy.pairable_timeout; }
            set { dbus_proxy.pairable_timeout = value; }
        }
        public uint32 discoverable_timeout {
            get { return dbus_proxy.discoverable_timeout; }
            set { dbus_proxy.discoverable_timeout = value; }
        }
        public bool discovering { get { return dbus_proxy.discovering; } }
        public string[] uuids { owned get { return dbus_proxy.uuids; } }

        public static async Adapter new_async (ObjectPath path,
                HashTable<string, Variant> properties) throws IOError
        {
            var adapter = new Adapter ();
            weak Adapter weak_adapter = adapter;
            adapter.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                org.bluez.SERVICE_NAME, path);
            ((DBusProxy)adapter.dbus_proxy).g_properties_changed.connect (
                weak_adapter.on_properties_changed);
            properties.foreach ((k, v) =>
                ((DBusProxy)adapter.dbus_proxy).set_cached_property (k, v));
            return adapter;
        }

        void on_properties_changed (Variant changed_properties,
                string[] invalidated_properties)
        {
            var iter = changed_properties.iterator ();
            string? key = null;
            Variant? value = null;
            while (iter.next ("{sv}", ref key, ref value))
                on_property_changed (key);
            foreach (var property in invalidated_properties)
                on_property_changed (property);
        }

        void on_property_changed (string name) {
            switch (name) {
            case "Address":
                notify_property ("address");
                break;
            case "Name":
                notify_property ("name");
                break;
            case "Alias":
                notify_property ("alias");
                break;
            case "Class":
                notify_property ("class");
                break;
            case "Powered":
                notify_property ("powered");
                break;
            case "Discoverable":
                notify_property ("discoverable");
                break;
            case "Pairable":
                notify_property ("pairable");
                break;
            case "PairableTimeout":
                notify_property ("pairable-timeout");
                break;
            case "DiscoverableTimeout":
                notify_property ("discoverable-timeout");
                break;
            case "Discovering":
                notify_property ("discovering");
                break;
            case "UUIDs":
                notify_property ("uuids");
                break;
            case "Modalias":
                notify_property ("modalias");
                break;
            default:
                critical ("Unknown dbus property '%s'", name);
                break;
            }
        }
    }
}

namespace org.bluez {
    [DBus (name = "org.bluez.Adapter1")]
    public interface Adapter1 : DBusProxy {
        public abstract async void start_discovery () throws IOError;
        public abstract async void stop_discovery () throws IOError;
        public abstract async void remove_device (ObjectPath device) throws IOError;

        public abstract string address { owned get; }
        public abstract string name { owned get; }
        public abstract string alias { owned get; set; }
        public abstract uint32 class { get; }
        public abstract bool powered { get; set; }
        public abstract bool discoverable { get; set; }
        public abstract bool pairable { get; set; }
        public abstract uint32 pairable_timeout { get; set; }
        public abstract uint32 discoverable_timeout { get; set; }
        public abstract bool discovering { get; }
        [DBus (name = "UUIDs")]
        public abstract string[] uuids { owned get; }
        public abstract string? modalias { owned get; }
    }
}
