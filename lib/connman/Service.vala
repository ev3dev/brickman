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
 * Service.vala:
 */

using Gee;

namespace ConnMan {
    public class Service : Object {
        static HashMap<ObjectPath, weak Service> object_map;

        static construct {
            object_map = new HashMap<ObjectPath, weak Service>();
        }

        const string IPV4_METHOD_KEY = "Method";
        const string IPV4_ADDRESS_KEY = "Address";
        const string IPV4_NETMASK_KEY = "Netmask";
        const string IPV4_GATEWAY_KEY = "Gateway";
        const string IPV6_METHOD_KEY = "Method";
        const string IPV6_ADDRESS_KEY = "Address";
        const string IPV6_PREFIX_LENGTH_KEY = "PrefixLength";
        const string IPV6_GATEWAY_KEY = "Gateway";
        const string IPV6_PRIVACY_KEY = "Privacy";
        const string PROXY_METHOD_KEY = "Method";
        const string PROXY_URL_KEY = "URL";
        const string PROXY_SERVERS_KEY = "Servers";
        const string PROXY_EXCLUDES_KEY = "Excludes";
        const string PROVIDER_HOST_KEY = "Host";
        const string PROVIDER_DOMAIN_KEY = "Domain";
        const string PROVIDER_NAME_KEY = "Name";
        const string PROVIDER_TYPE_KEY = "Type";
        const string ETHERENET_METHOD_KEY = "Method";
        const string ETHERENET_INTERFACE_KEY = "Interface";
        const string ETHERENET_ADDRESS_KEY = "Address";
        const string ETHERENET_MTU_KEY = "MTU";

        internal net.connman.Service dbus_proxy;

        public ObjectPath path { get; private set; }
        public ServiceState state { get { return dbus_proxy.state; } }
        public string error { owned get { return dbus_proxy.error; } }
        public string name { owned get { return dbus_proxy.name; } }
        public string service_type { owned get { return dbus_proxy.type_; } }
        public GenericArray<ServiceSecurity> security {
            owned get {
                var array = new GenericArray<ServiceSecurity> (dbus_proxy.security.length);
                foreach (var item in dbus_proxy.security)
                    array.add (item);
                return (owned)array;
            }
        }
        public uint8 strength { get { return dbus_proxy.strength; } }
        public bool favorite { get { return dbus_proxy.favorite; } }
        public bool immutable { get { return dbus_proxy.immutable; } }
        public bool auto_connect {
            get { return dbus_proxy.auto_connect; }
            set {
                if (value == auto_connect)
                    return;
                try {
                    dbus_proxy.set_property_sync ("AutoConnect", value);
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
        }
        public bool roaming { get { return dbus_proxy.roaming; } }
        public string[] nameservers {
            owned get { return dbus_proxy.nameservers; }
        }
        public string[] nameservers_configuration {
            owned get { return dbus_proxy.nameservers_configuration; }
            set {
                try {
                    dbus_proxy.set_property_sync("NameserversConfiguration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public string[] timeservers {
            owned get { return dbus_proxy.timeservers; }
        }
        public string[] timeservers_configuration {
            owned get { return dbus_proxy.timeservers_configuration; }
            set {
                try {
                    dbus_proxy.set_property_sync("TimeserversConfiguration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public string[] domains { owned get { return dbus_proxy.domains; } }
        public string[] domains_configuration {
            owned get { return dbus_proxy.domains_configuration; }
            set {
                try {
                    dbus_proxy.set_property_sync("DomainsConfiguration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public IPv4Method? ipv4_method {
            get {
                if (dbus_proxy.ipv4[IPV4_METHOD_KEY] == null)
                    return null;
                try {
                    return IPv4Method.from_string(
                        dbus_proxy.ipv4[IPV4_METHOD_KEY].get_string());
                } catch (Error err) {
                    critical("%s", err.message);
                    return IPv4Method.DHCP;
                }
            }
        }
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
        public string? ipv4_gateway {
            owned get {
                if (dbus_proxy.ipv4[IPV4_GATEWAY_KEY] == null)
                    return null;
                return dbus_proxy.ipv4[IPV4_GATEWAY_KEY].dup_string();
            }
        }
        public HashTable<string, Variant?> ipv4_configuration {
            owned get { return dbus_proxy.ipv4_configuration; }
            set {
                try {
                    dbus_proxy.set_property_sync("IPv4Configuration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public IPv6Method? ipv6_method {
            get {
                if (dbus_proxy.ipv6[IPV6_METHOD_KEY] == null)
                    return null;
                try {
                    return IPv6Method.from_string(
                        dbus_proxy.ipv6[IPV6_METHOD_KEY].get_string());
                } catch (Error err) {
                    critical("%s", err.message);
                    return IPv6Method.DHCP;
                }
            }
        }
        public string? ipv6_address {
            owned get {
                if (dbus_proxy.ipv6[IPV6_ADDRESS_KEY] == null)
                    return null;
                return dbus_proxy.ipv6[IPV6_ADDRESS_KEY].dup_string();
            }
        }
        public uchar ipv6_prefix_length {
            get {
                if (dbus_proxy.ipv6[IPV6_PREFIX_LENGTH_KEY] == null)
                    return 0;
                return dbus_proxy.ipv6[IPV6_PREFIX_LENGTH_KEY].get_byte ();
            }
        }
        public string? ipv6_gateway {
            owned get {
                if (dbus_proxy.ipv6[IPV6_GATEWAY_KEY] == null)
                    return null;
                return dbus_proxy.ipv6[IPV6_GATEWAY_KEY].dup_string();
            }
        }
        public IPv6Privacy? ipv6_privacy {
            get {
                if (dbus_proxy.ipv6[IPV6_PRIVACY_KEY] == null)
                    return null;
                try {
                    return IPv6Privacy.from_string(
                        dbus_proxy.ipv6[IPV6_PRIVACY_KEY].get_string());
                } catch (Error err) {
                    critical("%s", err.message);
                    return IPv6Privacy.DISABLED;
                }
            }
        }
        public HashTable<string, Variant?> ipv6_configuration {
            owned get { return dbus_proxy.ipv6_configuration; }
            set {
                try {
                    dbus_proxy.set_property_sync("IPv6Configuration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public ProxyMethod? proxy_method {
             get {
                 if (dbus_proxy.proxy[PROXY_METHOD_KEY] == null)
                    return null;
                 try {
                    return ProxyMethod.from_string(
                        dbus_proxy.proxy[PROXY_METHOD_KEY].get_string());
                } catch (Error err) {
                    critical("%s", err.message);
                    return ProxyMethod.AUTO;
                }
            }
        }
        public string? proxy_url {
            owned get {
                if (dbus_proxy.proxy[PROXY_URL_KEY] == null)
                    return null;
                return dbus_proxy.proxy[PROXY_URL_KEY].dup_string();
            }
        }
        public string[]? proxy_servers {
            owned get {
                if (dbus_proxy.proxy[PROXY_SERVERS_KEY] == null)
                    return null;
                return dbus_proxy.proxy[PROXY_SERVERS_KEY].dup_strv();
            }
        }
        public string[]? proxy_excludes{
            owned get {
                if (dbus_proxy.proxy[PROXY_EXCLUDES_KEY] == null)
                    return null;
                return dbus_proxy.proxy[PROXY_EXCLUDES_KEY].dup_strv();
            }
        }
        public HashTable<string, Variant?> proxy_configuration {
            owned get { return dbus_proxy.proxy_configuration; }
            set {
                try {
                    dbus_proxy.set_property_sync("ProxyConfiguration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }
        public string? provider_host {
            owned get {
                if (dbus_proxy.provider[PROVIDER_HOST_KEY] == null)
                    return null;
                return dbus_proxy.provider[PROVIDER_HOST_KEY].dup_string();
            }
        }
        public string? provider_domain {
            owned get {
                if (dbus_proxy.provider[PROVIDER_DOMAIN_KEY] == null)
                    return null;
                return dbus_proxy.provider[PROVIDER_DOMAIN_KEY].dup_string();
            }
        }
        public string? provider_name {
            owned get {
                if (dbus_proxy.provider[PROVIDER_NAME_KEY] == null)
                    return null;
                return dbus_proxy.provider[PROVIDER_NAME_KEY].dup_string();
            }
        }
        public string? provider_type {
            owned get {
                if (dbus_proxy.provider[PROVIDER_TYPE_KEY] == null)
                    return null;
                return dbus_proxy.provider[PROVIDER_TYPE_KEY].dup_string();
            }
        }
        public EthernetMethod ethernet_method {
            get {
                try {
                    return EthernetMethod.from_string(
                        dbus_proxy.ethernet[ETHERENET_METHOD_KEY].get_string());
                } catch (Error err) {
                    critical("%s", err.message);
                    return EthernetMethod.AUTO;
                }
            }
        }
        public string? ethernet_interface {
            owned get {
                if (dbus_proxy.ethernet[ETHERENET_INTERFACE_KEY] == null)
                    return null;
                return dbus_proxy.ethernet[ETHERENET_INTERFACE_KEY].dup_string();
            }
        }
        public string? ethernet_mac_address {
            owned get {
                if (dbus_proxy.ethernet[ETHERENET_ADDRESS_KEY] == null)
                    return null;
                return dbus_proxy.ethernet[ETHERENET_ADDRESS_KEY].dup_string();
            }
        }
        public uint ethernet_mtu {
            get {
                if (dbus_proxy.ethernet[ETHERENET_MTU_KEY] == null)
                    return uint.MAX;
                return dbus_proxy.ethernet[ETHERENET_MTU_KEY].get_uint16();
            }
        }

        internal static async Service from_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            var service = new Service ();
            service.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                net.connman.SERVICE_NAME, path);
            service.path = path;
            weak Service weak_service = service;
            service.dbus_proxy.property_changed.connect (weak_service.on_property_changed);
            object_map[path] = service;
            return service;
        }

        internal static Service from_path_sync (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            var service = new Service ();
            service.dbus_proxy = Bus.get_proxy_sync (BusType.SYSTEM,
                net.connman.SERVICE_NAME, path);
            service.path = path;
            weak Service weak_service = service;
            service.dbus_proxy.property_changed.connect (weak_service.on_property_changed);
            object_map[path] = service;
            return service;
        }

        ~Service () {
            object_map.unset (path);
        }

        public async void connect_service() throws IOError {
            yield dbus_proxy.connect();
        }

        public async void disconnect_service() throws IOError {
            yield dbus_proxy.disconnect();
        }

        public async void remove() throws IOError {
            yield dbus_proxy.remove();
        }

        public async void move_before(Service service) throws IOError {
            yield dbus_proxy.move_before(service.path);
        }

        public async void move_after(Service service) throws IOError {
            yield dbus_proxy.move_after(service.path);
        }

        public async void reset_counters() throws IOError {
            yield dbus_proxy.reset_counters();
        }

        internal void on_property_changed (string name, Variant? value) {
            ((DBusProxy)dbus_proxy).set_cached_property(name, value);
            switch (name) {
            case "State":
                notify_property("state");
                break;
            case "Error":
                notify_property("error");
                break;
            case "Name":
                notify_property("name");
                break;
            case "Type":
                notify_property("service-type");
                break;
            case "Security":
                notify_property("security");
                break;
            case "Strength":
                notify_property("strength");
                break;
            case "Favorite":
                notify_property("favorite");
                break;
            case "Immutable":
                notify_property("immutable");
                break;
            case "AutoConnect":
                notify_property("auto-connect");
                break;
            case "Roaming":
                notify_property("roaming");
                break;
            case "Nameservers":
                notify_property("nameservers");
                break;
            case "Nameservers.Configuration":
                notify_property("nameservers-configuration");
                break;
            case "Timeservers":
                notify_property("timeservers");
                break;
            case "Timeservers.Configuration":
                notify_property("timeservers-configuration");
                break;
            case "Domains":
                notify_property("domains");
                break;
            case "Domains.Configuration":
                notify_property("domains-configuration");
                break;
            case "IPv4":
                notify_property ("ipv4-method");
                notify_property ("ipv4-address");
                notify_property ("ipv4-netmask");
                notify_property ("ipv4-gateway");
                break;
            case "IPv4.Configuration":
                notify_property("ipv4-configuration");
                break;
            case "IPv6":
                notify_property ("ipv6-method");
                notify_property ("ipv6-address");
                notify_property ("ipv6-prefix-length");
                notify_property ("ipv6-gateway");
                notify_property ("ipv6-privacy");
                break;
            case "IPv6.Configuration":
                notify_property("ipv6-configuration");
                break;
            case "Proxy":
                notify_property ("proxy-method");
                notify_property ("proxy-url");
                notify_property ("proxy-servers");
                notify_property ("proxy-excludes");
                break;
            case "Proxy.Configuration":
                notify_property("proxy-configuration");
                break;
            case "Provider":
                notify_property ("provider-host");
                notify_property ("provider-domain");
                notify_property ("provider-name");
                notify_property ("provider-type");
                break;
            case "Ethernet":
                notify_property ("ethernet-method");
                notify_property ("ethernet-interface");
                notify_property ("ethernet-mac-address");
                notify_property ("ethernet-mtu");
                break;
            default:
                critical ("Unknown dbus property '%s'", name);
                break;
            }
        }
    }

    [DBus (use_string_marshalling = true)]
    public enum ServiceState {
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
        DISCONNECT,
        [DBus (value = "online")]
        ONLINE;
    }

    [DBus (use_string_marshalling = true)]
    public enum ServiceSecurity {
        [DBus (value = "none")]
        NONE,
        [DBus (value = "wep")]
        WEP,
        [DBus (value = "psk")]
        PSK,
        [DBus (value = "ieee8021x")]
        IEEE8021X,
        [DBus (value = "wps")]
        WPS;
    }

    [DBus (use_string_marshalling = true)]
    public enum IPv4Method {
        [DBus (value = "dhcp")]
        DHCP,
        [DBus (value = "manual")]
        MANUAL,
        [DBus (value = "off")]
        OFF;

        // hack to expose method created by DBus use_string_marshalling
        public static extern IPv4Method from_string(string method) throws Error;
    }

    [DBus (use_string_marshalling = true)]
    public enum IPv6Method {
        [DBus (value = "dhcp")]
        DHCP,
        [DBus (value = "manual")]
        MANUAL,
        [DBus (value = "6to4")]
        V6TOV4,
        [DBus (value = "off")]
        OFF;

        // hack to expose method created by DBus use_string_marshalling
        public static extern IPv6Method from_string(string method) throws Error;
    }

    [DBus (use_string_marshalling = true)]
    public enum IPv6Privacy {
        [DBus (value = "disabled")]
        DISABLED,
        [DBus (value = "enabled")]
        ENABLED,
        [DBus (value = "preferred")]
        PREFERRED;

        // hack to expose method created by DBus use_string_marshalling
        public static extern IPv6Privacy from_string(string method) throws Error;
    }

    [DBus (use_string_marshalling = true)]
    public enum ProxyMethod {
        [DBus (value = "direct")]
        DIRECT,
        [DBus (value = "auto")]
        AUTO,
        [DBus (value = "manual")]
        MANUAL;

        // hack to expose method created by DBus use_string_marshalling
        public static extern ProxyMethod from_string(string method) throws Error;
    }

    [DBus (use_string_marshalling = true)]
    public enum EthernetMethod {
        [DBus (value = "auto")]
        AUTO,
        [DBus (value = "manual")]
        MANUAL;

        // hack to expose method created by DBus use_string_marshalling
        public static extern EthernetMethod from_string(string method) throws Error;
    }
}

namespace net.connman {
    [DBus (name = "net.connman.Service")]
    public interface Service : Object {
        // deprecated
        //public abstract async HashTable<string, Variant?> get_properties() throws IOError;
        public abstract async void set_property(string name, Variant? value) throws IOError;
        [DBus (name = "SetProperty")]
        public abstract void set_property_sync(string name, Variant? value) throws IOError;
        public abstract async void clear_property(string name) throws IOError;
        public abstract async void connect() throws IOError;
        public abstract async void disconnect() throws IOError;
        public abstract async void remove() throws IOError;
        public abstract async void move_before(ObjectPath service) throws IOError;
        public abstract async void move_after(ObjectPath service) throws IOError;
        public abstract async void reset_counters() throws IOError;

        public signal void property_changed(string name, Variant? value);

        public abstract ConnMan.ServiceState state { get; }
        public abstract string error { owned get; }
        public abstract string name { owned get; }
        public abstract string type_ { owned get; }
        public abstract ConnMan.ServiceSecurity[] security { owned get; }
        public abstract uint8 strength { get; }
        public abstract bool favorite { get; }
        public abstract bool immutable { get; }
        public abstract bool auto_connect { get; }
        public abstract bool roaming { get; }
        public abstract string[] nameservers { owned get; }
        [DBus (name = "Nameservers.Configuration")]
        public abstract string[] nameservers_configuration { owned get; }
        public abstract string[] timeservers { owned get; }
        [DBus (name = "Timeservers.Configuration")]
        public abstract string[] timeservers_configuration { owned get; }
        public abstract string[] domains { owned get; }
        [DBus (name = "Domains.Configuration")]
        public abstract string[] domains_configuration { owned get; }
        [DBus (name = "IPv4")]
        public abstract HashTable<string, Variant?> ipv4 { owned get; }
        [DBus (name = "IPv4.Configuration")]
        public abstract HashTable<string, Variant?> ipv4_configuration { owned get; }
        [DBus (name = "IPv6")]
        public abstract HashTable<string, Variant?> ipv6 { owned get; }
        [DBus (name = "IPv6.Configuration")]
        public abstract HashTable<string, Variant?> ipv6_configuration { owned get; }
        public abstract HashTable<string, Variant?> proxy { owned get; }
        [DBus (name = "Proxy.Configuration")]
        public abstract HashTable<string, Variant?> proxy_configuration { owned get; }
        public abstract HashTable<string, Variant?> provider { owned get; }
        public abstract HashTable<string, Variant?> ethernet { owned get; }
    }
}
