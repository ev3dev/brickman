/*
 * connman -- DBus bindings for ConnMan <https://01.org/connman>
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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

namespace Connman {
    public class Technology : Object {
        internal net.connman.Technology dbus_proxy;

        public ObjectPath object_path { get; private set; }

        public bool powered {
            get { return dbus_proxy.powered; }
            set {
                if (value == powered)
                    return;
                try {
                    dbus_proxy.set_property_sync ("Powered", value);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
        public bool connected { get { return dbus_proxy.connected; } }
        public string name { owned get { return dbus_proxy.name; } }
        public string technology_type { owned get { return dbus_proxy.type_; } }
        public bool tethering {
            get { return dbus_proxy.tethering; }
            set {
                if (value == tethering)
                    return;
                try {
                    dbus_proxy.set_property_sync ("Tethering", value);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
        public string tethering_identifier {
            owned get { return dbus_proxy.tethering_identifier; }
            set {
                if (value == tethering_identifier)
                    return;
                try {
                    dbus_proxy.set_property_sync ("TetheringIdentifier", value);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
        public string tethering_passphrase {
            owned get { return dbus_proxy.tethering_passphrase; }
            set {
                if (value == tethering_passphrase)
                    return;
                try {
                    dbus_proxy.set_property_sync ("TetheringPassphrase", value);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }

        public signal void removed ();

        internal static async Technology new_async (ObjectPath path) throws DBusError, IOError {
            var technology = new Technology ();
            technology.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                Manager.SERVICE_NAME, path);
            technology.object_path = path;
            technology.dbus_proxy.property_changed.connect (technology.on_property_changed);
            // we are calling the deprecated get_properties_sync method because
            // of a possible race condition where a property_changed signal is
            // sent before the signal handler is connected.
            var properties = yield technology.dbus_proxy.get_properties ();
            properties.foreach ((k, v) => technology.on_property_changed (k, v));
            return technology;
        }

        public async void scan() throws DBusError, IOError {
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
                critical ("Unknown dbus property '%s'", name);
                break;
            }
        }
    }
}

namespace net.connman {
    [DBus (name = "net.connman.Technology")]
    public interface Technology : Object {
        // Docs say get_properties is deprecated, but it is needed to avoid race condition
        public abstract async HashTable<string, Variant> get_properties () throws DBusError, IOError;
        [DBus (name = "GetProperties")]
        public abstract HashTable<string, Variant> get_properties_sync () throws DBusError, IOError;
        public abstract async void set_property (string name, Variant? value) throws DBusError, IOError;
        [DBus (name = "SetProperty")]
        public abstract void set_property_sync (string name, Variant? value) throws DBusError, IOError;
        public abstract async void scan () throws DBusError, IOError;

        public signal void property_changed (string name, Variant? value);

        public abstract bool powered { get; }
        public abstract bool connected { get; }
        public abstract string name { owned get; }
        public abstract string type_ { owned get; }
        public abstract bool tethering { get; }
        public abstract string tethering_identifier { owned get; }
        public abstract string tethering_passphrase { owned get; }
    }
}
