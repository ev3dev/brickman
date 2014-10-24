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
 * Device.vala:
 */

namespace BlueZ5 {
    public class Device : Object {
        org.bluez.Device1 dbus_proxy;

        public string object_path { 
            owned get { return ((DBusProxy)dbus_proxy).g_object_path; }
        }

        public string address { owned get { return dbus_proxy.address; } }
        public string name { owned get { return dbus_proxy.name ?? "unknown"; } }
        public string icon { owned get { return dbus_proxy.name ?? "unknown"; } }
        public string alias { owned get { return dbus_proxy.alias; } }
        public uint32 class { get { return dbus_proxy.class; } }
        public string[] uuids { owned get { return dbus_proxy.uuids; } }

        public static async Device new_async (ObjectPath path,
                HashTable<string, Variant> properties) throws IOError
        {
            var device = new Device ();
            weak Device weak_device = device;
            device.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                org.bluez.SERVICE_NAME, path);
            ((DBusProxy)device.dbus_proxy).g_properties_changed.connect (
                weak_device.on_properties_changed);
            return device;
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
            case "Icon":
                notify_property ("icon");
                break;
            case "Class":
                notify_property ("class");
                break;
            case "Appearance":
                notify_property ("appearance");
                break;
            case "UUIDs":
                notify_property ("uuids");
                break;
            case "Paired":
                notify_property ("paired");
                break;
            case "Connected":
                notify_property ("connected");
                break;
            case "Trusted":
                notify_property ("trusted");
                break;
            case "Blocked":
                notify_property ("blocked");
                break;
            case "Alias":
                notify_property ("alias");
                break;
            case "Adapter":
                notify_property ("adapter");
                break;
            case "LegacyPairing":
                notify_property ("legacy-pairing");
                break;
            case "Modalias":
                notify_property ("modalias");
                break;
            case "RSSI":
                notify_property ("rssi");
                break;
            default:
                critical ("Unknown dbus property '%s'", name);
                break;
            }
        }
    }
}

namespace org.bluez {
    [DBus (name = "org.bluez.Device1")]
    public interface Device1 : DBusProxy {
        public abstract async void connect () throws IOError;
        public abstract async void disconnect () throws IOError;
        public abstract async void connect_profile (string uuid) throws IOError;
        public abstract async void disconnect_profile (string uuid) throws IOError;
        public abstract async void pair () throws IOError;
        public abstract async void cancel_pairing () throws IOError;

        public abstract string address { owned get; }
        public abstract string name { owned get; }
        public abstract string icon { owned get; }
        public abstract uint32 class { get; }
        public abstract uint16 appearance { get; }
        [DBus (name = "UUIDs")]
        public abstract string[]? uuids { owned get; }
        public abstract bool paired { get; }
        public abstract bool connected { get; }
        public abstract bool trusted { get; set; }
        public abstract bool blocked { get; set; }
        public abstract string alias { owned get; set; }
        public abstract ObjectPath adapter { owned get; }
        public abstract bool legacy_pairing { get; }
        public abstract string? modalias { owned get; }
        [DBus (name = "RSSI")]
        public abstract int16 rssi { get; }
    }
}
