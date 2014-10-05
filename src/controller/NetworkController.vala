/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* NetworkController.vala - Controller for network connections (ConnMan) */

using ConnMan;
using EV3devKit;

namespace BrickManager {
    public class NetworkController : Object, IBrickManagerModule {
        static Gee.Map<weak Technology, weak CheckboxMenuItem> technology_map;
        static Gee.Map<weak Service, weak NetworkConnectionMenuItem> service_map;

        static construct {
            technology_map = new Gee.HashMap<weak Technology, weak CheckboxMenuItem> ();
            service_map = new Gee.HashMap<weak Service, weak NetworkConnectionMenuItem> ();
        }

        NetworkStatusWindow status_window;
        NetworkConnectionsWindow connections_window;
        ConnManAgent agent;
        Manager manager;
        Technology? wifi_technology;

        public string menu_item_text { get { return "Network"; } }
        public Window start_window { get { return status_window; } }

        public NetworkController () {
            status_window = new NetworkStatusWindow ();
            weak NetworkStatusWindow weak_status_window = status_window;
            connections_window = new NetworkConnectionsWindow ();
            status_window.manage_connections_selected.connect (() =>
                weak_status_window.screen.show_window (connections_window));
            connections_window.scan_wifi_selected.connect (() =>
                on_connections_window_scan_wifi_selected.begin ());
            connections_window.connection_selected.connect (
                on_connections_window_connection_selected);
            init_async.begin ((obj, res) => {
                try {
                    init_async.end (res);
                    status_window.loading = false;
                    connections_window.loading = false;
                } catch (IOError err) {
                    critical ("%s", err.message);
                }
            });
        }

        async void init_async () throws IOError {
            agent = new ConnManAgent (ConsoleApp.screen);
            var bus = yield Bus.get (BusType.SYSTEM);
            var agent_object_path = new ObjectPath ("/org/ev3dev/brickman/connman_agent");
            bus.register_object<ConnManAgent> (agent_object_path, agent);
            manager = yield Manager.new_async ();
            manager.bind_property ("state", status_window, "state",
                BindingFlags.SYNC_CREATE, transform_manager_state_to_string);
            manager.bind_property ("offline-mode", status_window, "offline-mode",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            yield manager.register_agent (agent_object_path);
            manager.technology_added.connect (on_technology_added);
            manager.technology_removed.connect (on_technology_removed);
            foreach (var technology in yield manager.get_technologies ())
                on_technology_added (technology);
            manager.services_changed.connect (on_services_changed);
            on_services_changed (yield manager.get_services (), { });
        }

        bool transform_manager_state_to_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            switch (source_value.get_enum ()) {
            case ManagerState.OFFLINE:
                target_value.set_string ("Offline");
                break;
            case ManagerState.IDLE:
                target_value.set_string ("No connections");
                break;
            case ManagerState.READY:
                target_value.set_string ("Connected");
                break;
            case ManagerState.ONLINE:
                target_value.set_string ("Online");
                break;
            default:
                return false;
            }
            return true;
        }

        void on_technology_added (Technology technology) {
            var menu_item = new CheckboxMenuItem (technology.name) {
                represented_object = technology
            };
            technology.bind_property ("powered", menu_item.checkbox, "checked",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            status_window.menu.add_menu_item (menu_item);
            technology_map[technology] = menu_item;

            if (technology.technology_type == "wifi") {
                technology.bind_property ("powered", connections_window,
                    "has-wifi", BindingFlags.SYNC_CREATE);
                wifi_technology = technology;
            }
        }

        void on_technology_removed (ObjectPath path) {
            var iter = technology_map.map_iterator ();
            iter.foreach ((technology, menu_item) => {
                if (technology.path == path) {
                    iter.unset ();
                    if (technology.technology_type == "wifi") {
                        connections_window.has_wifi = false;
                        wifi_technology = null;
                    }
                    status_window.menu.remove_menu_item (menu_item);
                    return false; // break
                }
                return true;
            });
        }

        void on_services_changed (GenericArray<Service> changed, ObjectPath[] removed) {
            if (removed.length > 0) {
                var iter = service_map.map_iterator ();
                iter.foreach ((service, menu_item) => {
                    if (service.path in removed) {
                        iter.unset ();
                        connections_window.menu.remove_menu_item (menu_item);
                    }
                    return true;
                });
            }
            changed.foreach ((service) => {
                NetworkConnectionMenuItem menu_item;
                if (service_map.has_key (service)) {
                    menu_item = service_map[service];
                    connections_window.menu.remove_menu_item (menu_item);
                } else {
                    menu_item = new NetworkConnectionMenuItem ();
                    menu_item.represented_object = service;
                    service.bind_property ("name", menu_item, "connection-name",
                        BindingFlags.SYNC_CREATE);
                    service.bind_property ("strength", menu_item, "signal-strength",
                        BindingFlags.SYNC_CREATE);
                    service_map[service] = menu_item;
                }
                connections_window.menu.add_menu_item (menu_item);
            });
        }

        async void on_connections_window_scan_wifi_selected ()
            requires (wifi_technology != null && wifi_technology.powered)
        {
            connections_window.scan_wifi_busy = true;
            try {
                yield wifi_technology.scan ();
            } catch (IOError err) {
                // TODO: Show error message in UI
                critical ("%s", err.message);
            } finally {
                connections_window.scan_wifi_busy = false;
            }
        }

        void on_connections_window_connection_selected (Object user_data) {
            var service = (Service)user_data;
            var properties_window = new NetworkPropertiesWindow (service.name ?? "<hidden>") {
                loading = false
            };
            service.bind_property ("auto-connect", properties_window, "auto-connect",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            service.bind_property ("state", properties_window, "state",
                BindingFlags.SYNC_CREATE , transform_service_state_to_string);
            service.bind_property ("state", properties_window, "is-connect-busy",
                BindingFlags.SYNC_CREATE , transform_service_state_to_busy_bool);
            service.bind_property ("state", properties_window, "is-connected",
                BindingFlags.SYNC_CREATE , transform_service_state_to_connected_bool);
            service.bind_property ("security", properties_window, "security",
                BindingFlags.SYNC_CREATE, transform_service_security_array_to_string);
            service.bind_property ("strength", properties_window, "strength",
                BindingFlags.SYNC_CREATE);
            service.bind_property ("ipv4", properties_window, "ipv4-method",
                BindingFlags.SYNC_CREATE, transform_service_ipv4_to_method_string);
            service.bind_property ("ipv4", properties_window, "ipv4-address",
                BindingFlags.SYNC_CREATE, transform_service_ipv4_to_address_string);
            service.bind_property ("ipv4", properties_window, "ipv4-netmask",
                BindingFlags.SYNC_CREATE, transform_service_ipv4_to_netmask_string);
            service.bind_property ("ipv4", properties_window, "ipv4-gateway",
                BindingFlags.SYNC_CREATE, transform_service_ipv4_to_gateway_string);
            service.bind_property ("nameservers", properties_window, "dns-addresses",
                BindingFlags.SYNC_CREATE);
            service.bind_property ("ethernet", properties_window, "enet-method",
                BindingFlags.SYNC_CREATE, transform_service_ethernet_to_method_string);
            service.bind_property ("ethernet", properties_window, "enet-interface",
                BindingFlags.SYNC_CREATE, transform_service_ethernet_to_interface_string);
            service.bind_property ("ethernet", properties_window, "enet-address",
                BindingFlags.SYNC_CREATE, transform_service_ethernet_to_address_string);
            service.bind_property ("ethernet", properties_window, "enet-mtu",
                BindingFlags.SYNC_CREATE, transform_service_ethernet_to_mtu_int);
            weak NetworkPropertiesWindow weak_properties_window = properties_window;
            properties_window.connect_requested.connect ((disconnect) =>
                on_properties_window_connect_requested.begin (weak_properties_window, service, disconnect));
            properties_window.dns_change_requested.connect ((addresses) =>
                service.nameservers_configuration = addresses);
            properties_window.ipv4_change_requested.connect ((method, address, netmask, gateway) => {
                try {
                    service.ipv4_configuration = new IPv4Info () {
                        method = IPv4Method.from_string (method),
                        address = address,
                        netmask = netmask,
                        gateway = gateway
                    };
                } catch (DBusError err) {
                    critical ("Failed to convert method '%s' to IPv4Info", method);
                }
            });
            connections_window.screen.show_window (properties_window);
        }

        async void on_properties_window_connect_requested (
            NetworkPropertiesWindow properties_window, Service service, bool disconnect)
        {
            if (disconnect) {
                try {
                    properties_window.is_connect_busy = true;
                    yield service.disconnect_service ();
                } catch (IOError err) {
                    var dialog = new MessageDialog ("Error", err.message);
                    ConsoleApp.screen.show_window (dialog);
                    properties_window.is_connect_busy = false;
                }
            } else {
                try {
                    properties_window.is_connect_busy = true;
                    // Do long timeout for WiFi since we have to wait for password entry
                    yield service.connect_service (service.service_type == "wifi");
                } catch (IOError err) {
                    var dialog = new MessageDialog ("Error", err.message);
                    ConsoleApp.screen.show_window (dialog);
                    properties_window.is_connect_busy = false;
                }
            }
        }


        bool transform_service_state_to_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            switch (source_value.get_enum ()) {
            case ServiceState.IDLE:
                target_value.set_string ("Disconnected");
                break;
            case ServiceState.FAILURE:
                target_value.set_string ("Failed");
                break;
            case ServiceState.ASSOCIATION:
                target_value.set_string ("Associating");
                break;
            case ServiceState.CONFIGURATION:
                target_value.set_string ("Configuring");
                break;
            case ServiceState.READY:
                target_value.set_string ("Connected");
                break;
            case ServiceState.DISCONNECT:
                target_value.set_string ("Disconnecting");
                break;
            case ServiceState.ONLINE:
                target_value.set_string ("Online");
                break;
            default:
                return false;
            }
            return true;
        }

        bool transform_service_state_to_busy_bool (Binding binding,
            Value source_value, ref Value target_value)
        {
            switch (source_value.get_enum ()) {
            case ServiceState.IDLE:
            case ServiceState.FAILURE:
            case ServiceState.READY:
            case ServiceState.ONLINE:
                target_value.set_boolean (false);
                break;
            case ServiceState.ASSOCIATION:
            case ServiceState.CONFIGURATION:
            case ServiceState.DISCONNECT:
                target_value.set_boolean (true);
                break;
            default:
                return false;
            }
            return true;
        }

        bool transform_service_state_to_connected_bool (Binding binding,
            Value source_value, ref Value target_value)
        {
            switch (source_value.get_enum ()) {
            case ServiceState.READY:
            case ServiceState.ONLINE:
            case ServiceState.DISCONNECT:
                target_value.set_boolean (true);
                break;
            case ServiceState.IDLE:
            case ServiceState.FAILURE:
            case ServiceState.ASSOCIATION:
            case ServiceState.CONFIGURATION:
                target_value.set_boolean (false);
                break;
            default:
                return false;
            }
            return true;
        }

        bool transform_service_security_array_to_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            var array = (GenericArray<ServiceSecurity> )source_value.get_boxed ();
            if (array.length == 0) {
                target_value.set_string ("N/A");
                return true;
            }
            var builder = new StringBuilder ();
            var error = false;
            array.foreach ((value) => {
                switch (value) {
                case ServiceSecurity.NONE:
                    builder.append ("None");
                    break;
                case ServiceSecurity.WEP:
                    builder.append ("WEP");
                    break;
                case ServiceSecurity.PSK:
                    builder.append ("WPA/2 PSK");
                    break;
                case ServiceSecurity.IEEE8021X:
                    builder.append ("WPA EAP");
                    break;
                case ServiceSecurity.WPS:
                    builder.append ("WPS");
                    break;
                default:
                    error = true;
                    return;
                }
                builder.append (", ");
            });
            if (error)
                return false;
            builder.truncate (builder.len - 2);
            target_value.set_string (builder.str);
            return true;
        }

        bool transform_service_ipv4_to_method_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned IPv4Info info = (IPv4Info)source_value.get_pointer ();
            if (info.method == null) {
                target_value.set_string ("");
                return true;
            }
            switch (info.method) {
            case IPv4Method.DHCP:
                target_value.set_string ("DHCP");
                break;
            case IPv4Method.MANUAL:
                target_value.set_string ("Manual");
                break;
            case IPv4Method.OFF:
                target_value.set_string ("Off");
                break;
            default:
                return false;
            }
            return true;
        }

        bool transform_service_ipv4_to_address_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned IPv4Info info = (IPv4Info)source_value.get_pointer ();
            target_value.set_string (info.address ?? "");
            return true;
        }

        bool transform_service_ipv4_to_netmask_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned IPv4Info info = (IPv4Info)source_value.get_pointer ();
            target_value.set_string (info.netmask ?? "");
            return true;
        }

        bool transform_service_ipv4_to_gateway_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned IPv4Info info = (IPv4Info)source_value.get_pointer ();
            target_value.set_string (info.gateway ?? "");
            return true;
        }

        bool transform_service_ethernet_to_method_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned EthernetInfo info = (EthernetInfo)source_value.get_pointer ();
            if (info.method == null) {
                target_value.set_string ("");
                return true;
            }
            switch (info.method) {
            case EthernetMethod.AUTO:
                target_value.set_string ("Automatic");
                break;
            case EthernetMethod.MANUAL:
                target_value.set_string ("Manual");
                break;
            default:
                return false;
            }
            return true;
        }

        bool transform_service_ethernet_to_interface_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned EthernetInfo info = (EthernetInfo)source_value.get_pointer ();
            target_value.set_string (info.interface ?? "");
            return true;
        }

        bool transform_service_ethernet_to_address_string (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned EthernetInfo info = (EthernetInfo)source_value.get_pointer ();
            target_value.set_string (info.address ?? "");
            return true;
        }

        bool transform_service_ethernet_to_mtu_int (Binding binding,
            Value source_value, ref Value target_value)
        {
            unowned EthernetInfo info = (EthernetInfo)source_value.get_pointer ();
            target_value.set_int (info.mtu ?? 0);
            return true;
        }
    }
}