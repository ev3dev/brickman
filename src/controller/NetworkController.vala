/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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
using EV3devKit.UI;

namespace BrickManager {
    public class NetworkController : Object, IBrickManagerModule {
        const string[] TETHRING_TECHNOLOGIES = { "bluetooth", "gadget" };
        const string NET_SUBSYSTEM = "net";
        const string TETHER_DEVICE_NAME = "tether";

        Gee.Map<weak Technology, weak CheckboxMenuItem> technology_map;
        Gee.Map<weak Service, weak NetworkConnectionMenuItem> service_map;
        NetworkStatusWindow status_window;
        NetworkConnectionsWindow connections_window;
        TetheringWindow? tethering_window;
        TetheringInfoWindow? tethering_info_window;
        internal NetworkStatusBarItem network_status_bar_item;
        Binding? status_bar_item_binding;
        bool status_bar_item_binding_is_tether;
        ConnManAgent agent;
        ObjectPath agent_object_path;
        Manager? manager;
        Technology? wifi_technology;
        GUdev.Client udev_client;
        BluetoothController bluetooth_controller;

        public BrickManagerWindow start_window { get { return status_window; } }

        public bool has_tether { get; set; }
        public string tether_address { get; set; }
        public string tether_netmask { get; set; }
        public string tether_interface { get; set; }
        public string tether_mac { get; set; }

        public NetworkController () {
            technology_map = new Gee.HashMap<weak Technology, weak CheckboxMenuItem> ();
            service_map = new Gee.HashMap<weak Service, weak NetworkConnectionMenuItem> ();
            status_window = new NetworkStatusWindow () {
                loading = true
            };
            connections_window = new NetworkConnectionsWindow ();
            status_window.network_connections_selected.connect (() =>
                connections_window.show ());
            connections_window.scan_wifi_selected.connect (() =>
                on_connections_window_scan_wifi_selected.begin ());
            connections_window.connection_selected.connect (
                on_connections_window_connection_selected);
            network_status_bar_item = new NetworkStatusBarItem ();

            status_window.tethering_selected.connect (() => {
                tethering_window = new TetheringWindow ();
                foreach (var tech in manager.get_technologies ()) {
                    add_tethering_technology (tech);
                }
                tethering_window.tethering_info_selected.connect (() => {
                    tethering_info_window = new TetheringInfoWindow ();
                    bind_property ("has-tether", tethering_info_window, "available",
                        BindingFlags.SYNC_CREATE);
                    bind_property ("tether-address", tethering_info_window, "ipv4-address",
                        BindingFlags.SYNC_CREATE);
                    bind_property ("tether-netmask", tethering_info_window, "ipv4-netmask",
                        BindingFlags.SYNC_CREATE);
                    bind_property ("tether-interface", tethering_info_window, "enet-iface",
                        BindingFlags.SYNC_CREATE);
                    bind_property ("tether-mac", tethering_info_window, "enet-mac",
                        BindingFlags.SYNC_CREATE);
                    tethering_info_window.show ();
                });
                tethering_window.closed.connect (() => tethering_window = null);
                tethering_window.show ();
            });

            try {
                agent = new ConnManAgent ();
                var bus = Bus.get_sync (BusType.SYSTEM);
                agent_object_path = new ObjectPath ("/org/ev3dev/brickman/connman_agent");
                bus.register_object<ConnManAgent> (agent_object_path, agent);
            } catch (IOError err) {
                critical ("%s", err.message);
            }

            Bus.watch_name (BusType.SYSTEM, Manager.SERVICE_NAME,
                BusNameWatcherFlags.AUTO_START, () => {
                    init_async.begin ((obj, res) => {
                        try {
                            init_async.end (res);
                            status_window.loading = false;
                            connections_window.loading = false;
                        } catch (IOError err) {
                            critical ("%s", err.message);
                        }
                    });
                }, () => {
                    status_window.loading = true;
                    connections_window.loading = true;
                    var service_keys = service_map.keys.to_array ();
                    foreach (var key in service_keys) {
                        key.removed ();
                    }
                    var technology_keys = technology_map.keys.to_array ();
                    foreach (var key in technology_keys) {
                        key.removed ();
                    }
                    manager = null;
                });

            // ConnMan does not have a way to get tethering info via DBus, so
            // we have to get it ourselves. ConnMan creates a bridge device
            // named "tether", so we use udev to watch for it.
            udev_client = new GUdev.Client ({ NET_SUBSYSTEM });
            udev_client.uevent.connect (on_udev_event);
            var tether_device = udev_client.query_by_subsystem_and_name (NET_SUBSYSTEM, TETHER_DEVICE_NAME);
            if (tether_device != null)
                on_udev_event ("add", tether_device);
        }

        public void add_controller (IBrickManagerModule controller) {
            status_window.add_controller (controller);
            if (controller is BluetoothController) {
                bluetooth_controller = (BluetoothController)controller;
                if (manager != null) {
                    var bt_tech = manager.get_technology_by_type ("bluetooth");
                    if (bt_tech != null)
                        bind_bluetooth_technology (bt_tech);
                }
                bluetooth_controller.show_network_requested.connect ((name) => {
                    var service = manager.get_service_by_name_and_type (name, "bluetooth");
                    if (service == null) {
                        critical ("Could not find ConnMan service '%s'", name);
                        return;
                    }
                    on_connections_window_connection_selected (service);
                });
            }
        }

        async void init_async () throws IOError {
            manager = yield Manager.new_async ();
            manager.bind_property ("state", status_window, "state",
                BindingFlags.SYNC_CREATE, transform_manager_state_to_string);
            manager.bind_property ("offline-mode", status_window, "offline-mode",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            agent.manager = manager;
            yield manager.register_agent (agent_object_path);
            manager.technology_added.connect (on_technology_added);
            foreach (var technology in manager.get_technologies ())
                on_technology_added (technology);
            manager.services_changed.connect (on_services_changed);
            on_services_changed (manager.get_services ());
        }

        void on_technology_added (Technology technology) {
            // gadget is not powered by default, but we want it to always be powered.
            if (technology.technology_type == "gadget" && !technology.powered) {
                technology.powered = true;
            }

            if (technology.technology_type == "wifi") {
                technology.bind_property ("powered", connections_window,
                    "has-wifi", BindingFlags.SYNC_CREATE);
                wifi_technology = technology;
                technology.removed.connect (() => {
                    connections_window.has_wifi = false;
                    wifi_technology = null;
                });
            }

            if (technology.technology_type == "bluetooth")
                bind_bluetooth_technology (technology);

            add_tethering_technology (technology);
        }

        void on_services_changed (Gee.Collection<Service> changed) {
            unbind_status_bar ();

            foreach (var service in changed) {
                NetworkConnectionMenuItem menu_item;
                if (service_map.has_key (service)) {
                    menu_item = service_map[service];
                    connections_window.menu.remove_menu_item (menu_item);
                } else {
                    var icon_file = service.service_type.replace ("gadget", "usb") + ".png";
                    menu_item = new NetworkConnectionMenuItem (icon_file);
                    menu_item.represented_object = service;
                    service.bind_property ("name", menu_item, "connection-name",
                        BindingFlags.SYNC_CREATE);
                    service.bind_property ("strength", menu_item, "signal-strength",
                        BindingFlags.SYNC_CREATE);
                    service.removed.connect (() => {
                        connections_window.menu.remove_menu_item (menu_item);
                        service_map.unset (service);
                    });
                    service_map[service] = menu_item;
                }
                connections_window.menu.add_menu_item (menu_item);

                // Show the IP address of the primary service in the status bar
                // The list is ordered, so the first one is the one we want
                if (status_bar_item_binding == null
                    && (service.state == ServiceState.READY || service.state == ServiceState.ONLINE))
                {
                    status_bar_item_binding = service.bind_property (
                        "ipv4", network_status_bar_item, "text",
                        BindingFlags.SYNC_CREATE, transform_service_ipv4_to_address_string);
                }
            }

            // If there were no connected services, then we will display the
            // tether bridge address in the status bar if there is one.
            if (status_bar_item_binding == null && has_tether) {
                bind_tether_address_to_status_bar ();
            }
        }

        void unbind_status_bar () {
            if (status_bar_item_binding != null) {
                status_bar_item_binding.unbind ();
                status_bar_item_binding = null;
                status_bar_item_binding_is_tether = false;
            }
        }

        void bind_bluetooth_technology (Technology technology) {
            if (bluetooth_controller == null)
                return;
            bluetooth_controller.bind_powered (technology, "powered");
        }

        void bind_tether_address_to_status_bar () {
            status_bar_item_binding = bind_property ("tether-address",
                network_status_bar_item, "text", BindingFlags.SYNC_CREATE);
            status_bar_item_binding_is_tether = true;
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
            var properties_window = new NetworkPropertiesWindow (service.name ?? "<hidden>");
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
            service.bind_property ("ipv4-configuration", properties_window, "ipv4-config-address",
                BindingFlags.SYNC_CREATE, transform_service_ipv4_to_address_string);
            service.bind_property ("ipv4-configuration", properties_window, "ipv4-config-netmask",
                BindingFlags.SYNC_CREATE, transform_service_ipv4_to_netmask_string);
            service.bind_property ("ipv4-configuration", properties_window, "ipv4-config-gateway",
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
            properties_window.show ();
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
                    dialog.show ();
                    properties_window.is_connect_busy = false;
                }
            } else {
                try {
                    properties_window.is_connect_busy = true;
                    // Do long timeout for WiFi since we have to wait for password entry
                    yield service.connect_service (service.service_type == "wifi");
                } catch (IOError err) {
                    var dialog = new MessageDialog ("Error", err.message);
                    dialog.show ();
                    properties_window.is_connect_busy = false;
                }
            }
        }

        void add_tethering_technology (Technology technology) {
            if (tethering_window == null)
                return;
            if (technology.technology_type in TETHRING_TECHNOLOGIES) {
                var menu_item = tethering_window.add_menu_item (technology.name);
                technology.bind_property ("tethering", menu_item.checkbox, "checked",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                var handler_id = technology.removed.connect (() =>
                    tethering_window.remove_menu_item (menu_item));
                tethering_window.closed.connect (() =>
                    technology.disconnect (handler_id));
            }
        }

        /**
         * Handle add/remove of "tether" network bridge device.
         *
         * Some info (MAC address) is available via sysfs, but we have to use
         * getifaddrs to get the IP address info.
         */
        void on_udev_event (string action, GUdev.Device device) {
            if (device.get_name () != TETHER_DEVICE_NAME)
                return;
            switch (action) {
            case "add":
            case "change":
                Linux.Network.IfAddrs if_addrs;
                unowned Linux.Network.IfAddrs current;
                if (Linux.Network.getifaddrs (out if_addrs) == 0) {
                    current = if_addrs;
                    while (current != null) {
                        if (current.ifa_name == TETHER_DEVICE_NAME && current.ifa_addr != null) {
                            // Get the IPv4 address/netmask
                            if (current.ifa_addr.sa_family == Posix.AF_INET) {
                                has_tether = true;
                                // the first 2 bytes of sa_data are the port, so we are skipping them.
                                tether_address = "%d.%d.%d.%d".printf (
                                    current.ifa_addr.sa_data[2],
                                    current.ifa_addr.sa_data[3],
                                    current.ifa_addr.sa_data[4],
                                    current.ifa_addr.sa_data[5]);
                                if (current.ifa_netmask != null && current.ifa_addr.sa_family == Posix.AF_INET) {
                                    tether_netmask = "%d.%d.%d.%d".printf (
                                        current.ifa_netmask.sa_data[2],
                                        current.ifa_netmask.sa_data[3],
                                        current.ifa_netmask.sa_data[4],
                                        current.ifa_netmask.sa_data[5]);
                                } else {
                                    tether_netmask = "<unknown>";
                                }
                                tether_interface = device.get_name ();
                                tether_mac = device.get_sysfs_attr ("address");
                                if (status_bar_item_binding == null) {
                                    bind_tether_address_to_status_bar ();
                                }
                                break;
                            }
                        }
                        current = current.ifa_next;
                    }
                } else {
                    critical ("getifaddrs failed.");
                }
                break;
            case "remove":
                has_tether = false;
                if (status_bar_item_binding_is_tether)
                    unbind_status_bar ();
                break;
            }
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
