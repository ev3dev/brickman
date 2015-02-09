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
        static Gee.HashMap<string, weak Device> device_map;

        static construct {
            device_map = new Gee.HashMap<string, weak Device> ();
        }

        internal org.bluez.Device1 dbus_proxy;

        public ObjectPath object_path {
            owned get {
                return new ObjectPath (((DBusProxy)dbus_proxy).g_object_path);
            }
        }

        public string address { owned get { return dbus_proxy.address; } }

        public string name { owned get { return dbus_proxy.name; } }

        public string icon { owned get { return dbus_proxy.icon; } }

        public uint32 class { get { return dbus_proxy.class; } }

        public uint16 appearance { get { return dbus_proxy.appearance; } }

        public UUID[] uuids { owned get { return dbus_proxy.uuids; } }

        public bool paired { get { return dbus_proxy.paired; } }

        public bool connected { get { return dbus_proxy.connected; } }

        public bool trusted {
            get { return dbus_proxy.trusted; }
            set { dbus_proxy.trusted = value; }
        }

        public bool blocked {
            get { return dbus_proxy.blocked; }
            set { dbus_proxy.blocked = value; }
        }

        public string alias {
            owned get { return dbus_proxy.alias; }
            set { dbus_proxy.alias = value; }
        }

        public Adapter adapter { owned
            get {
                var path = dbus_proxy.adapter;
                return Adapter.get_for_object_path (path);
            }
        }

        public bool legacy_pairing { get { return dbus_proxy.legacy_pairing; } }

        public string modalias { owned get { return dbus_proxy.modalias; } }

        public int rssi { get { return dbus_proxy.rssi; } }

        internal Device (DBusProxy proxy) {
            dbus_proxy = (org.bluez.Device1)proxy;
            device_map[proxy.g_object_path] = this;
            proxy.g_properties_changed.connect ((changed, invalidated) => {
                var iter = changed.iterator ();
                string? name = null;
                Variant? value = null;
                while (iter.next ("{sv}", &name, &value)) {
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
                        critical ("Unknown d-bus property: %s", name);
                        break;
                    }
                }
            });
        }

        ~Device () {
            device_map.unset (((DBusProxy)dbus_proxy).g_object_path);
        }

        internal static Device get_for_object_path (string path) {
            return device_map[path];
        }

        public async void connect_device () throws IOError {
            yield dbus_proxy.connect ();
        }

        public async void disconnect_device () throws IOError {
            yield dbus_proxy.disconnect ();
        }

        public async void connect_profile (UUID uuid) throws IOError {
            yield dbus_proxy.connect_profile (uuid);
        }

        public async void disconnect_profile (UUID uuid) throws IOError {
            yield dbus_proxy.disconnect_profile (uuid);
        }

        public async void pair () throws IOError {
            yield dbus_proxy.pair ();
        }

        public async void cancel_pairing () throws IOError {
            yield dbus_proxy.cancel_pairing ();
        }
    }
}

namespace org.bluez {
    [DBus (name = "org.bluez.Device1")]
    public interface Device1 : Object {
        public abstract async void connect () throws IOError;
        public abstract async void disconnect () throws IOError;
        public abstract async void connect_profile (BlueZ5.UUID uuid) throws IOError;
        public abstract async void disconnect_profile (BlueZ5.UUID uuid) throws IOError;
        public abstract async void pair () throws IOError;
        public abstract async void cancel_pairing () throws IOError;

        public abstract string address { owned get; }
        public abstract string name { owned get; }
        public abstract string icon { owned get; }
        public abstract uint32 class { get; }
        public abstract uint16 appearance { get; }
        [DBus (name = "UUIDs")]
        public abstract BlueZ5.UUID[] uuids { owned get; }
        public abstract bool paired { get; }
        public abstract bool connected { get; }
        public abstract bool trusted { get; set; }
        public abstract bool blocked { get; set; }
        public abstract string alias { owned get; set; }
        public abstract ObjectPath adapter { owned get; }
        public abstract bool legacy_pairing { get; }
        public abstract string modalias { owned get; }
        [DBus (name = "RSSI")]
        public abstract int16 rssi { get; }
    }
}
