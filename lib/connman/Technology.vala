/*
 * connman -- DBus bindings for ConnMan <https://01.org/connman>
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
 * Technology.vala:
 */

using Gee;

namespace ConnMan {
    public class Technology : Object {
        static HashMap<ObjectPath, weak Technology> object_map;

        static construct {
            object_map = new HashMap<ObjectPath, weak Technology>();
        }

        internal net.connman.Technology dbus_proxy;

        public ObjectPath path { get; private set; }

        public bool powered {
            get { return dbus_proxy.powered; }
            set {
                try {
                    dbus_proxy.set_property_sync("Powered", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public bool connected { get { return dbus_proxy.connected; } }
        public string name { owned get { return dbus_proxy.name; } }
        public string technology_type { owned get { return dbus_proxy.type_; } }
        public bool tethering {
            get { return dbus_proxy.tethering; }
            set {
                try {
                    dbus_proxy.set_property_sync("Tethering", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public string tethering_identifier {
            owned get { return dbus_proxy.tethering_identifier; }
            set {
                try {
                    dbus_proxy.set_property_sync("TetheringIdentifier", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public string tethering_passphrase {
            owned get { return dbus_proxy.tethering_passphrase; }
            set {
                try {
                    dbus_proxy.set_property_sync("TetheringPassphrase", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }

        internal static async Technology from_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            var technology = new Technology ();
            technology.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                net.connman.SERVICE_NAME, path);
            technology.path = path;
            technology.dbus_proxy.property_changed.connect (technology.on_property_changed);
            object_map[path] = technology;
            return technology;
        }

        internal static Technology from_path_sync (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            var technology = new Technology ();
            technology.dbus_proxy = Bus.get_proxy_sync (BusType.SYSTEM,
                net.connman.SERVICE_NAME, path);
            technology.path = path;
            technology.dbus_proxy.property_changed.connect (technology.on_property_changed);
            object_map[path] = technology;
            return technology;
        }

        ~Technology() {
            object_map.unset(path);
        }

        public async void scan() throws IOError {
            yield dbus_proxy.scan();
        }

        void on_property_changed(string name, Variant? value) {
            ((DBusProxy)dbus_proxy).set_cached_property(name, value);
            switch (name) {
            case "Powered":
                notify_property("powered");
                break;
            case "Connected":
                notify_property("connected");
                break;
            case "Name":
                notify_property("name");
                break;
            case "Type":
                notify_property("technology-type");
                break;
            case "Tethering":
                notify_property("tethering");
                break;
            case "TetheringIdentifier":
                notify_property("tethering-identifier");
                break;
            case "TetheringPassphrase":
                notify_property("tethering-passphrase");
                break;
            default:
                critical("ConnMan.Manager: unknown dbus property '%s'", name);
                break;
            }
        }
    }
}

namespace net.connman {
    [DBus (name = "net.connman.Technology")]
    public interface Technology : Object {
        // deprecated
        //public abstract async HashTable<string, Variant?> get_properties() throws IOError;
        public abstract async void set_property(string name, Variant? value) throws IOError;
        [DBus (name = "SetProperty")]
        public abstract void set_property_sync(string name, Variant? value) throws IOError;
        public abstract async void scan() throws IOError;

        public signal void property_changed(string name, Variant? value);

        public abstract bool powered { get; }
        public abstract bool connected { get; }
        public abstract string name { owned get; }
        public abstract string type_ { owned get; }
        public abstract bool tethering { get; }
        public abstract string tethering_identifier { owned get; }
        public abstract string tethering_passphrase { owned get; }
    }
}
