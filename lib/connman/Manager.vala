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
 * Manager.vala:
 */

namespace Connman {
    public class Manager : Object {
        public const string SERVICE_NAME = "net.connman";

        HashTable<ObjectPath, Technology> technology_map;
        HashTable<ObjectPath, Service> service_map;
        List<weak Service> sorted_service_list;
        HashTable<ObjectPath, Peer> peer_map;
        net.connman.Manager dbus_proxy;
        weak Cancellable? on_services_changed_cancellable;
        weak Cancellable? on_peers_changed_cancellable;

        public ManagerState state {
            get { return dbus_proxy.state; }
        }

        public bool offline_mode {
            get { return dbus_proxy.offline_mode; }
            set {
                if (value == offline_mode)
                    return;
                try {
                    dbus_proxy.set_property_sync ("OfflineMode", value);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }

        public signal void technology_added (Technology technology);
        public signal void services_changed (List<weak Service> changed);
        public signal void peers_changed (List<weak Peer> changed);

        construct {
            technology_map = new HashTable<ObjectPath, Technology> (str_hash, str_equal);
            service_map = new HashTable<ObjectPath, Service> (str_hash, str_equal);
            sorted_service_list = new List<weak Service> ();
            peer_map = new HashTable<ObjectPath, Peer> (str_hash, str_equal);
        }

        public static async Manager new_async () throws DBusError, IOError {
            var manager = new Manager ();
            weak Manager weak_manager = manager;
            manager.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM, SERVICE_NAME,
                net.connman.Manager.OBJECT_PATH);
            manager.dbus_proxy.property_changed.connect (weak_manager.on_property_changed);
            var properties = yield manager.dbus_proxy.get_properties ();
            properties.foreach ((k, v) =>
                ((DBusProxy)manager.dbus_proxy).set_cached_property (k, v));
            manager.dbus_proxy.technology_added.connect (weak_manager.on_technology_added);
            manager.dbus_proxy.technology_removed.connect (weak_manager.on_technology_removed);
            var technologies = yield manager.dbus_proxy.get_technologies ();
            foreach (var tech in technologies)
                yield manager.on_technology_added_async (tech.path);
            manager.dbus_proxy.services_changed.connect (weak_manager.on_services_changed);
            var services = yield manager.dbus_proxy.get_services ();
            yield manager.on_services_changed_async (services);
            manager.dbus_proxy.peers_changed.connect (weak_manager.on_peers_changed);
            var peers = yield manager.dbus_proxy.get_peers ();
            yield manager.on_peers_changed_async (peers);
            return manager;
        }

        public List<weak Technology> get_technologies () {
            return technology_map.get_values ();
        }

        public Technology? get_technology (ObjectPath path) {
            return technology_map[path];
        }

        public Technology? get_technology_by_type (string type) {
            foreach (var technology in technology_map.get_values ()) {
                if (technology.technology_type == type)
                    return technology;
            }
            return null;
        }

        public List<weak Service> get_services () {
            return sorted_service_list.copy ();
        }

        public Service? get_service (ObjectPath path) {
            return service_map[path];
        }

        public Service? get_service_by_name_and_type (string name, string type) {
            foreach (var service in service_map.get_values ()) {
                if (service.name == name && service.service_type == type)
                    return service;
            }
            return null;
        }

        public List<weak Peer> get_peers () {
            return peer_map.get_values ();
        }

        public async void register_agent (ObjectPath path) throws DBusError, IOError {
            yield dbus_proxy.register_agent (path);
        }

        public async void unregister_agent (ObjectPath path) throws DBusError, IOError {
            yield dbus_proxy.unregister_agent (path);
        }

        void on_technology_added (ObjectPath path, HashTable<string, Variant> properties) {
            if (technology_map.contains (path)) {
                critical ("technology '%s' already exists.", path);
            }
            on_technology_added_async.begin (path);
        }

        async void on_technology_added_async (ObjectPath path) {
            try {
                var tech = yield Technology.new_async (path);
                technology_map[path] = tech;
                technology_added (tech);
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }

        void on_technology_removed (ObjectPath path) {
            if (technology_map.contains (path)) {
                technology_map[path].removed ();
                technology_map.remove (path);
            }
        }

        void on_services_changed (net.connman.ManagerObject[] changed, ObjectPath[] removed) {
            foreach (var path in removed) {
                if (service_map.contains (path)) {
                    service_map[path].removed ();
                    service_map.remove (path);
                }
            }
            on_services_changed_async.begin (changed);
        }

        async void on_services_changed_async (net.connman.ManagerObject[] changed) {
            // We have to make this method reentrant since it is async and
            // services can change rapidly. If this method is called a 2nd time
            // before the first has completed, we forget about the current list
            // of signal objects and exit the method before emitting the
            // services-changed signal.
            if (on_services_changed_cancellable != null) {
                on_services_changed_cancellable.cancel ();
            }
            var my_cancellable = new Cancellable ();
            on_services_changed_cancellable = my_cancellable;

            // It is possible that the changed parameter comes from a DBus signal
            // handler. Since this is an async method we need to make our own copy
            // because the DBus signal handler will return and free the array if
            // we yield.
            var changed_copy = new net.connman.ManagerObject[changed.length];
            int i = 0;
            foreach (var c in changed) {
                changed_copy[i++] = c;
            }
            try {
                var services = new List<weak Service> ();
                foreach (var item in changed_copy) {
                    if (service_map.contains (item.path)) {
                        services.append (service_map[item.path]);
                    } else {
                        var service = yield Service.new_async (item.path);
                        if (my_cancellable.is_cancelled ()) {
                            return;
                        }
                        service_map[item.path] = service;
                        services.append (service);
                    }
                }
                sorted_service_list = services.copy ();
                services_changed (services);
            } catch (Error err) {
                critical ("%s", err.message);
            }
            if (on_services_changed_cancellable == my_cancellable) {
                on_services_changed_cancellable = null;
            }
        }

        void on_peers_changed (net.connman.ManagerObject[] changed, ObjectPath[] removed) {
            foreach (var path in removed) {
                if (peer_map.contains (path)) {
                    peer_map[path].removed ();
                    peer_map.remove (path);
                }
            }
            on_peers_changed_async.begin (changed);
        }

        async void on_peers_changed_async (net.connman.ManagerObject[] changed) {
            // See notes in on_services_changed_async about reentrancy and ownership
            // of ``changed`` parameter.
            if (on_peers_changed_cancellable != null)
                on_peers_changed_cancellable.cancel ();
            var my_cancellable = new Cancellable ();
            on_peers_changed_cancellable = my_cancellable;

            var changed_copy = new net.connman.ManagerObject[changed.length];
            int i = 0;
            foreach (var c in changed) {
                changed_copy[i++] = c;
            }
            try {
                var peers = new List<weak Peer> ();
                foreach (var item in changed_copy) {
                    if (peer_map.contains (item.path)) {
                        peers.append (peer_map[item.path]);
                    } else {
                        var peer = yield Peer.new_async (item.path);
                        if (my_cancellable.is_cancelled ()) {
                            return;
                        }
                        peer_map[item.path] = peer;
                        peers.append (peer);
                    }
                }
                peers_changed (peers);
            } catch (Error err) {
                critical ("%s", err.message);
            }
            if (on_peers_changed_cancellable == my_cancellable) {
                on_peers_changed_cancellable = null;
            }
        }

        void on_property_changed (string name, Variant? value) {
            ((DBusProxy)dbus_proxy).set_cached_property (name, value);
            switch (name) {
            case "State":
                notify_property ("state");
                break;
            case "OfflineMode":
                notify_property ("offline-mode");
                break;
            default:
                critical ("Unknown dbus property '%s'", name);
                break;
            }
        }
    }

    [DBus (use_string_marshalling = true)]
    public enum ManagerState {
        [DBus (value = "offline")]
        OFFLINE,
        [DBus (value = "idle")]
        IDLE,
        [DBus (value = "ready")]
        READY,
        [DBus (value = "online")]
        ONLINE;
    }
}

namespace net.connman {
    [DBus (name = "net.connman.Manager")]
    public interface Manager : Object {
        public const string OBJECT_PATH = "/";

        public abstract async HashTable<string, Variant> get_properties () throws DBusError, IOError;
        public abstract async void set_property (string name, Variant? value) throws DBusError, IOError;
        [DBus (name = "SetProperty")]
        public abstract void set_property_sync (string name, Variant? value) throws DBusError, IOError;
        public abstract async ManagerObject[] get_technologies () throws DBusError, IOError;
        public abstract async ManagerObject[] get_services () throws DBusError, IOError;
        public abstract async ManagerObject[] get_peers () throws DBusError, IOError;
        // deprecated
        //public abstract async ObjectPath ConnectProvider (HashTable<string, Variant> provider throws DBusError, IOError;
        //public abstract async void remove_provider (ObjectPath path) throws DBusError, IOError;
        public abstract async void register_agent (ObjectPath object) throws DBusError, IOError;
        public abstract async void unregister_agent (ObjectPath object) throws DBusError, IOError;
        public abstract async void register_counter (ObjectPath path, uint accuracy, uint period) throws DBusError, IOError;
        public abstract async void unregister_counter (ObjectPath path) throws DBusError, IOError;
        public abstract async ObjectPath create_session (HashTable<string, Variant> settings, ObjectPath notifier) throws DBusError, IOError;
        public abstract async void destroy_session (ObjectPath session) throws DBusError, IOError;
        public abstract async ObjectPath request_private_network (HashTable<string, Variant> options, out HashTable<string, Variant> fd) throws DBusError, IOError;
        public abstract async void release_private_network (ObjectPath path) throws DBusError, IOError;

        public signal void technology_added (ObjectPath path, HashTable<string, Variant> properties);
        public signal void technology_removed (ObjectPath path);
        public signal void services_changed (ManagerObject[] changed, ObjectPath[] removed);
        public signal void peers_changed (ManagerObject[] changed, ObjectPath[] removed);
        public signal void property_changed (string name, Variant? value);

        public abstract Connman.ManagerState state { get; }
        public abstract bool offline_mode { get; }
        // deprecated
        //public abstract bool session_mode { get; }
    }

    public struct ManagerObject {
        ObjectPath path;
        HashTable<string, Variant> properties;
    }
}
