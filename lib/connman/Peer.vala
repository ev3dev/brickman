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
 * Peer.vala:
 */

namespace Connman {
    public class Peer : Object {
        const string IPV4_ADDRESS_KEY = "Address";
        const string IPV4_NETMASK_KEY = "Netmask";

        internal net.connman.Peer dbus_proxy;

        public ObjectPath object_path { get; private set; }

        public PeerState state { get { return dbus_proxy.state; } }
        public string name { owned get { return dbus_proxy.name; } }
        public string? ipv4_address {
            owned get {
                if (dbus_proxy.ipv4[IPV4_ADDRESS_KEY] == null)
                    return null;
                return dbus_proxy.ipv4[IPV4_ADDRESS_KEY].dup_string ();
            }
        }
        public string? ipv4_netmask {
            owned get {
                if (dbus_proxy.ipv4[IPV4_NETMASK_KEY] == null)
                    return null;
                return dbus_proxy.ipv4[IPV4_NETMASK_KEY].dup_string ();
            }
        }

        public signal void removed ();

        internal static async Peer new_async (ObjectPath path) throws DBusError, IOError {
            var peer = new Peer();
            peer.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                Manager.SERVICE_NAME, path);
            peer.object_path = path;
            peer.dbus_proxy.property_changed.connect (peer.on_property_changed);
            // we are calling the deprecated get_properties_sync method because
            // of a possible race condition where a property_changed signal is
            // sent before the signal handler is connected.
            var properties = yield peer.dbus_proxy.get_properties ();
            properties.foreach ((k, v) => peer.on_property_changed (k, v));
            return peer;
        }

        public async void connect_peer() throws DBusError, IOError {
            yield dbus_proxy.connect ();
        }

        public async void disconnect_peer() throws DBusError, IOError {
            yield dbus_proxy.disconnect ();
        }

        void on_property_changed(string name, Variant? value) {
            ((DBusProxy)dbus_proxy).set_cached_property (name, value);
            switch (name) {
            case "State":
                notify_property ("state");
                break;
            case "Name":
                notify_property ("name");
                break;
            case "IPv4":
                notify_property ("ipv4");
                break;
            default:
                critical ("Unknown dbus property '%s'", name);
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
        // Docs say get_properties is deprecated, but it is needed to avoid race condition
        public abstract async HashTable<string, Variant> get_properties () throws DBusError, IOError;
        public abstract async void connect () throws DBusError, IOError;
        public abstract async void disconnect () throws DBusError, IOError;

        public signal void property_changed (string name, Variant? value);

        public abstract Connman.PeerState state { get; }
        public abstract string name { owned get; }
        [DBus (name = "IPv4")]
        public abstract HashTable<string, Variant> ipv4 { owned get; }
    }
}
