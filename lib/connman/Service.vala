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
 * Service.vala:
 */

using Gee;

namespace ConnMan {
    public class Service : Object {
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
        const string ETHERNET_METHOD_KEY = "Method";
        const string ETHERNET_INTERFACE_KEY = "Interface";
        const string ETHERNET_ADDRESS_KEY = "Address";
        const string ETHERNET_MTU_KEY = "MTU";

        internal net.connman.Service dbus_proxy;

        public ObjectPath object_path { get; private set; }
        public ServiceState state { get { return dbus_proxy.state; } }
        public string? error { owned get { return dbus_proxy.error; } }
        public string? name { owned get { return dbus_proxy.name; } }
        public string service_type { owned get { return dbus_proxy.type_; } }
        public GenericArray<ServiceSecurity> security {
            owned get {
                var array = new GenericArray<ServiceSecurity> ();
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
                    dbus_proxy.set_property_sync ("Nameservers.Configuration", value);
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
                    dbus_proxy.set_property_sync ("Timeservers.Configuration", value);
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
                    dbus_proxy.set_property_sync ("Domains.Configuration", value);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }

        public IPv4Info ipv4 {
            owned get {
                var config = dbus_proxy.ipv4;
                var info = new IPv4Info ();
                if (config[IPV4_METHOD_KEY] != null) {
                    try {
                        info.method = IPv4Method.from_string (
                            config[IPV4_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[IPV4_ADDRESS_KEY] != null)
                    info.address = config[IPV4_ADDRESS_KEY].dup_string ();
                if (config[IPV4_NETMASK_KEY] != null)
                    info.netmask = config[IPV4_NETMASK_KEY].dup_string ();
                if (config[IPV4_GATEWAY_KEY] != null)
                    info.gateway = config[IPV4_GATEWAY_KEY].dup_string ();
                return info;
            }
        }

        public IPv4Info ipv4_configuration {
            owned get {
                var config = dbus_proxy.ipv4_configuration;
                var info = new IPv4Info ();
                    if (config[IPV4_METHOD_KEY] != null) {
                    try {
                        info.method = IPv4Method.from_string (
                            config[IPV4_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[IPV4_ADDRESS_KEY] != null)
                    info.address = config[IPV4_ADDRESS_KEY].dup_string ();
                if (config[IPV4_NETMASK_KEY] != null)
                    info.netmask = config[IPV4_NETMASK_KEY].dup_string ();
                if (config[IPV4_GATEWAY_KEY] != null)
                    info.gateway = config[IPV4_GATEWAY_KEY].dup_string ();
                return info;
            }
            set {
                try {
                    var config = new HashTable<string, Variant> (null, null);
                    if (value.method != null)
                        config[IPV4_METHOD_KEY] = new Variant.string (value.method.to_string ());
                    if (value.address != null)
                        config[IPV4_ADDRESS_KEY] = new Variant.string (value.address);
                    if (value.netmask != null)
                        config[IPV4_NETMASK_KEY] = new Variant.string (value.netmask);
                    if (value.gateway != null)
                        config[IPV4_GATEWAY_KEY] = new Variant.string (value.gateway);
                    dbus_proxy.set_property_sync ("IPv4.Configuration", config);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }

         public IPv6Info ipv6 {
            owned get {
                var config = dbus_proxy.ipv6;
                var info = new IPv6Info ();
                if (config[IPV6_METHOD_KEY] != null) {
                    try {
                        info.method = IPv6Method.from_string (
                            config[IPV6_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[IPV6_ADDRESS_KEY] != null)
                    info.address = config[IPV6_ADDRESS_KEY].dup_string ();
                if (config[IPV6_PREFIX_LENGTH_KEY] != null)
                    info.prefix_length = config[IPV6_PREFIX_LENGTH_KEY].dup_string ();
                if (config[IPV6_GATEWAY_KEY] != null)
                    info.gateway = config[IPV6_GATEWAY_KEY].dup_string ();
                if (config[IPV6_PRIVACY_KEY] != null) {
                    try {
                        info.privacy = IPv6Privacy.from_string (
                            config[IPV6_PRIVACY_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                return info;
            }
        }

        public IPv6Info ipv6_configuration {
            owned get {
                var config = dbus_proxy.ipv6_configuration;
                var info = new IPv6Info ();
                if (config[IPV6_METHOD_KEY] != null) {
                    try {
                        info.method = IPv6Method.from_string (
                            config[IPV6_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[IPV6_ADDRESS_KEY] != null)
                    info.address = config[IPV6_ADDRESS_KEY].dup_string ();
                if (config[IPV6_PREFIX_LENGTH_KEY] != null)
                    info.prefix_length = config[IPV6_PREFIX_LENGTH_KEY].dup_string ();
                if (config[IPV6_GATEWAY_KEY] != null)
                    info.gateway = config[IPV6_GATEWAY_KEY].dup_string ();
                if (config[IPV6_PRIVACY_KEY] != null) {
                    try {
                        info.privacy = IPv6Privacy.from_string (
                            config[IPV6_PRIVACY_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                return info;
            }
            set {
                try {
                    var config = new HashTable<string, Variant> (null, null);
                    if (value.method != null)
                        config[IPV6_METHOD_KEY] = new Variant.string (value.method.to_string ());
                    if (value.address != null)
                        config[IPV6_ADDRESS_KEY] = new Variant.string (value.address);
                    if (value.prefix_length != null)
                        config[IPV6_PREFIX_LENGTH_KEY] = new Variant.string (value.prefix_length);
                    if (value.gateway != null)
                        config[IPV6_GATEWAY_KEY] = new Variant.string (value.gateway);
                    if (value.privacy != null)
                        config[IPV6_PRIVACY_KEY] = new Variant.string (value.privacy.to_string ());
                    dbus_proxy.set_property_sync ("IPv6.Configuration", config);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }

         public ProxyInfo proxy {
            owned get {
                var config = dbus_proxy.proxy;
                var info = new ProxyInfo ();
                if (config[PROXY_METHOD_KEY] != null) {
                    try {
                        info.method = ProxyMethod.from_string (
                            config[PROXY_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[PROXY_URL_KEY] != null)
                    info.url = config[PROXY_URL_KEY].dup_string ();
                if (config[PROXY_SERVERS_KEY] != null)
                    info.servers = config[PROXY_SERVERS_KEY].dup_strv ();
                if (config[PROXY_EXCLUDES_KEY] != null)
                    info.excludes = config[PROXY_EXCLUDES_KEY].dup_strv ();
                return info;
            }
        }

        public ProxyInfo proxy_configuration {
            owned get {
                var config = dbus_proxy.proxy_configuration;
                var info = new ProxyInfo ();
                if (config[PROXY_METHOD_KEY] != null) {
                    try {
                        info.method = ProxyMethod.from_string (
                            config[PROXY_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[PROXY_URL_KEY] != null)
                    info.url = config[PROXY_URL_KEY].dup_string ();
                if (config[PROXY_SERVERS_KEY] != null)
                    info.servers = config[PROXY_SERVERS_KEY].dup_strv ();
                if (config[PROXY_EXCLUDES_KEY] != null)
                    info.excludes = config[PROXY_EXCLUDES_KEY].dup_strv ();
                return info;
            }
            set {
                try {
                    var config = new HashTable<string, Variant> (null, null);
                    if (value.method != null)
                        config[PROXY_METHOD_KEY] = new Variant.string (value.method.to_string ());
                    if (value.url != null)
                        config[PROXY_URL_KEY] = new Variant.string (value.url);
                    if (value.servers != null)
                        config[PROXY_SERVERS_KEY] = new Variant.strv (value.servers);
                    if (value.excludes != null)
                        config[PROXY_EXCLUDES_KEY] = new Variant.strv (value.excludes);
                    dbus_proxy.set_property_sync ("Proxy.Configuration", config);
                } catch (Error err) {
                    critical("%s", err.message);
                }
            }
        }

         public ProviderInfo provider {
            owned get {
                var config = dbus_proxy.provider;
                var info = new ProviderInfo ();
                if (config[PROVIDER_HOST_KEY] != null)
                    info.host = config[PROVIDER_HOST_KEY].dup_string ();
                if (config[PROVIDER_DOMAIN_KEY] != null)
                    info.domain = config[PROVIDER_DOMAIN_KEY].dup_string ();
                if (config[PROVIDER_NAME_KEY] != null)
                    info.name = config[PROVIDER_NAME_KEY].dup_string ();
                if (config[PROVIDER_TYPE_KEY] != null)
                    info.type = config[PROVIDER_TYPE_KEY].dup_string ();
                return info;
            }
        }

         public EthernetInfo ethernet {
            owned get {
                var config = dbus_proxy.ethernet;
                var info = new EthernetInfo ();
                if (config[ETHERNET_METHOD_KEY] != null) {
                    try {
                        info.method = EthernetMethod.from_string (
                            config[ETHERNET_METHOD_KEY].get_string ());
                    } catch (DBusError err) {
                        critical ("%s", err.message);
                    }
                }
                if (config[ETHERNET_INTERFACE_KEY] != null)
                    info.interface = config[ETHERNET_INTERFACE_KEY].dup_string ();
                if (config[ETHERNET_ADDRESS_KEY] != null)
                    info.address = config[ETHERNET_ADDRESS_KEY].dup_string ();
                if (config[ETHERNET_MTU_KEY] != null)
                    info.mtu = config[ETHERNET_MTU_KEY].get_uint16 ();
                return info;
            }
        }

        public signal void removed ();

        internal static async Service new_async (ObjectPath path) throws IOError {
            var service = new Service ();
            service.dbus_proxy = yield Bus.get_proxy (BusType.SYSTEM,
                Manager.SERVICE_NAME, path);
            service.object_path = path;
            weak Service weak_service = service;
            service.dbus_proxy.property_changed.connect (weak_service.on_property_changed);
            // we are calling the deprecated get_properties_sync method because
            // of a possible race condition where a property_changed signal is
            // sent before the signal handler is connected.
            var properties = yield service.dbus_proxy.get_properties ();
            properties.foreach ((k, v) => service.on_property_changed (k, v));
            return service;
        }

        public async void connect_service (bool long_timeout = false) throws IOError {
            if (long_timeout)
                try {
                    yield ((DBusProxy)dbus_proxy).call ("Connect", null,
                        DBusCallFlags.NONE, 120000);
                } catch (IOError ioerr) {
                    throw ioerr;
                } catch (Error err) {
                    // This should only happen if we were using cancellable
                    // but we are not. Just catching it here to prevent compiler
                    // warning.
                    critical ("%s", err.message);
                }
            else
                yield dbus_proxy.connect ();
        }

        public async void disconnect_service () throws IOError {
            yield dbus_proxy.disconnect ();
        }

        public async void remove() throws IOError {
            yield dbus_proxy.remove();
        }

        public async void move_before(Service service) throws IOError {
            yield dbus_proxy.move_before(service.object_path);
        }

        public async void move_after(Service service) throws IOError {
            yield dbus_proxy.move_after(service.object_path);
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
                notify_property ("ipv4");
                break;
            case "IPv4.Configuration":
                notify_property("ipv4-configuration");
                break;
            case "IPv6":
                notify_property ("ipv6");
                break;
            case "IPv6.Configuration":
                notify_property("ipv6-configuration");
                break;
            case "Proxy":
                notify_property ("proxy");
                break;
            case "Proxy.Configuration":
                notify_property("proxy-configuration");
                break;
            case "Provider":
                notify_property ("provider");
                break;
            case "Ethernet":
                notify_property ("ethernet");
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

        // hacks to expose methods created by DBus use_string_marshalling
        [CCode (cname = "conn_man_ipv4_method_to_string (self)")]
        extern const string to_string_hack;
        [CCode (cname = "conn_man_ipv4_method_to_string_wrapper")]
        public string to_string () {
            return to_string_hack;
        }
        public static extern IPv4Method from_string (string method) throws DBusError;
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

        // hacks to expose methods created by DBus use_string_marshalling
        [CCode (cname = "conn_man_ipv6_method_to_string (self)")]
        extern const string to_string_hack;
        [CCode (cname = "conn_man_ipv6_method_to_string_wrapper")]
        public string to_string () {
            return to_string_hack;
        }
        public static extern IPv6Method from_string (string method) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum IPv6Privacy {
        [DBus (value = "disabled")]
        DISABLED,
        [DBus (value = "enabled")]
        ENABLED,
        [DBus (value = "preferred")]
        PREFERRED;

        // hacks to expose methods created by DBus use_string_marshalling
        [CCode (cname = "conn_man_ipv6_privacy_to_string (self)")]
        extern const string to_string_hack;
        [CCode (cname = "conn_man_ipv6_privacy_to_string_wrapper")]
        public string to_string () {
            return to_string_hack;
        }
        public static extern IPv6Privacy from_string (string method) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum ProxyMethod {
        [DBus (value = "direct")]
        DIRECT,
        [DBus (value = "auto")]
        AUTO,
        [DBus (value = "manual")]
        MANUAL;

        // hacks to expose methods created by DBus use_string_marshalling
        [CCode (cname = "conn_man_proxy_method_to_string (self)")]
        extern const string to_string_hack;
        [CCode (cname = "conn_man_proxy_method_to_string_wrapper")]
        public string to_string () {
            return to_string_hack;
        }
        public static extern ProxyMethod from_string (string method) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum EthernetMethod {
        [DBus (value = "auto")]
        AUTO,
        [DBus (value = "manual")]
        MANUAL;

        // hacks to expose methods created by DBus use_string_marshalling
        [CCode (cname = "conn_man_ethernet_method_to_string (self)")]
        extern const string to_string_hack;
        [CCode (cname = "conn_man_ethernet_method_to_string_wrapper")]
        public string to_string () {
            return to_string_hack;
        }
        public static extern EthernetMethod from_string (string method) throws DBusError;
    }

    [Compact]
    public class IPv4Info {
        public IPv4Method? method;
        public string? address;
        public string? netmask;
        public string? gateway;
    }

    [Compact]
    public class IPv6Info {
        public IPv6Method? method;
        public string? address;
        public string? prefix_length;
        public string? gateway;
        public IPv6Privacy? privacy;
    }

    [Compact]
    public class ProxyInfo {
        public ProxyMethod? method;
        public string? url;
        public string[]? servers;
        public string[]? excludes;
    }

    [Compact]
    public class ProviderInfo {
        public string? host;
        public string? domain;
        public string? name;
        public string? type;
    }

    [Compact]
    public class EthernetInfo {
        public EthernetMethod? method;
        public string? interface;
        public string? address;
        public uint16? mtu;
    }
}

namespace net.connman {
    [DBus (name = "net.connman.Service")]
    public interface Service : Object {
        [Deprecated]
        public abstract async HashTable<string, Variant> get_properties() throws IOError;
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
        public abstract string? error { owned get; }
        public abstract string? name { owned get; }
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
        public abstract HashTable<string, Variant> ipv4 { owned get; }
        [DBus (name = "IPv4.Configuration")]
        public abstract HashTable<string, Variant> ipv4_configuration { owned get; }
        [DBus (name = "IPv6")]
        public abstract HashTable<string, Variant> ipv6 { owned get; }
        [DBus (name = "IPv6.Configuration")]
        public abstract HashTable<string, Variant> ipv6_configuration { owned get; }
        public abstract HashTable<string, Variant> proxy { owned get; }
        [DBus (name = "Proxy.Configuration")]
        public abstract HashTable<string, Variant> proxy_configuration { owned get; }
        public abstract HashTable<string, Variant> provider { owned get; }
        public abstract HashTable<string, Variant> ethernet { owned get; }
    }
}
