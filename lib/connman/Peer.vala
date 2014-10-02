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
 * Peer.vala:
 */

using Gee;

namespace ConnMan {
    public class Peer : Object {
        static HashMap<ObjectPath, weak Peer> object_map;

        static construct {
            object_map = new HashMap<ObjectPath, weak Peer>();
        }

        const string IPV4_ADDRESS_KEY = "Address";
        const string IPV4_NETMASK_KEY = "Netmask";

        internal net.connman.Peer dbus_proxy;

        public ObjectPath path { get; private set; }

        public PeerState state { get { return dbus_proxy.state; } }
        public string name { owned get { return dbus_proxy.name; } }
        public string? ipv4_address {
            owned get {
                if (dbus_proxy.ipv4[IPV4_ADDRESS_KEY] == null)
                    return null;
                return dbus_proxy.ipv4[IPV4_ADDRESS_KEY].dup_string();
            }
        }
        public string? ipv4_netmask {
            owned get {
                if (dbus_proxy.ipv4[IPV4_NETMASK_KEY] == null)
                    return null;
                return dbus_proxy.ipv4[IPV4_NETMASK_KEY].dup_string();
            }
        }

        internal static async Peer from_path(ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key(path))
                return object_map[path];
            var peer = new Peer();
            peer.dbus_proxy = yield Bus.get_proxy(BusType.SYSTEM,
                net.connman.SERVICE_NAME, path);
            peer.path = path;
            peer.dbus_proxy.property_changed.connect(peer.on_property_changed);
            object_map[path] = peer;
            return peer;
        }

        ~Peer() {
            object_map.unset(path);
        }

        public async void connect_peer() throws IOError {
            yield dbus_proxy.connect();
        }

        public async void disconnect_peer() throws IOError {
            yield dbus_proxy.disconnect();
        }

        void on_property_changed(string name, Variant? value) {
            ((DBusProxy)dbus_proxy).set_cached_property(name, value);
            switch (name) {
            case "State":
                notify_property("state");
                break;
            case "Name":
                notify_property("name");
                break;
            case "IPv4":
                notify_property("ipv4");
                break;
            default:
                critical("ConnMan.Peer: unknown dbus property '%s'", name);
                break;
            }
        }
    }

    [DBus (use_string_marshalling = true)]
    public enum PeerState {
        [DBus (value = "idle")]
        IDLE,
        [DBus (value = "failure")]
        FAILURE,
        [DBus (value = "association")]
        ASSOCIATION,
        [DBus (value = "configuration")]
        CONFIGURATION,
        [DBus (value = "ready")]
        READY,
        [DBus (value = "disconnect")]
        DISCONNECT;
    }
}

namespace net.connman {
    [DBus (name = "net.connman.Peer")]
    public interface Peer : Object {
        // deprecated
        //public abstract async HashTable<string, Variant?> get_properties() throws IOError;
        public abstract async void connect() throws IOError;
        public abstract async void disconnect() throws IOError;

        public signal void property_changed(string name, Variant? value);

        public abstract ConnMan.PeerState state { get; }
        public abstract string name { owned get; }
        [DBus (name = "IPv4")]
        public abstract HashTable<string, Variant?> ipv4 { owned get; }
    }
}
