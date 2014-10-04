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

/* FakeConnManController.vala - Fake Network (ConnMan) controller for testing */

using EV3devKit;

namespace BrickManager {
    public class FakeNetworkController : Object, IBrickManagerModule {
        const string CONNMAN_SERVICE_IPV4_DIALOG_GLADE_FILE = "ConnManServiceIPv4Dialog.glade";

        public string menu_item_text { get { return "Networking"; } }
        NetworkStatusWindow network_status_window;
        public Window start_window { get { return network_status_window; } }
        NetworkConnectionsWindow network_connections_window;

        protected bool has_wifi { get; set; default = true; }

        public FakeNetworkController (Gtk.Builder builder) throws Error {
            /* NetworkStatusWindow */
            network_status_window = new NetworkStatusWindow ();
            var control_panel_notebook = builder.get_object ("control_panel_notebook") as Gtk.Notebook;
            network_status_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK);

            var networking_loading_checkbutton = builder.get_object ("networking_loading_checkbutton") as Gtk.CheckButton;
            networking_loading_checkbutton.bind_property ("active", network_status_window, "loading", BindingFlags.SYNC_CREATE);
            (builder.get_object ("connman_offline_mode_checkbutton") as Gtk.CheckButton)
                .bind_property ("active", network_status_window, "offline-mode",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            (builder.get_object ("connman_state_comboboxtext") as Gtk.ComboBoxText)
                .bind_property ("active-id", network_status_window, "state", BindingFlags.SYNC_CREATE);
            var connman_technology_liststore = builder.get_object ("connman_technology_liststore") as Gtk.ListStore;
            connman_technology_liststore.foreach ((model, path, iter) => {
                Value name;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.NAME, out name);
                var menu_item = new CheckboxMenuItem (name.dup_string ());
                // there is a reference cycle with menu_item here, but it doesn't matter because we never get rid of it.
                menu_item.checkbox.notify["checked"].connect (() => connman_technology_liststore.set (
                    iter, ControlPanel.NetworkTechnologyColumn.POWERED, menu_item.checkbox.checked));
                network_status_window.menu.add_menu_item (menu_item);
                connman_technology_liststore.set (iter, ControlPanel.NetworkTechnologyColumn.PRESENT, true);
                menu_item.ref (); //liststore USER_DATA is gpointer, so it does not take a ref
                connman_technology_liststore.set (iter, ControlPanel.NetworkTechnologyColumn.USER_DATA, menu_item);
                return false;
            });
            connman_technology_liststore.row_changed.connect ((path, iter) => {
                Value present;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.PRESENT, out present);
                Value type;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.TYPE, out type);
                Value powered;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.POWERED, out powered);
                Value user_data;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.USER_DATA, out user_data);
                var menu_item = (CheckboxMenuItem)user_data.get_pointer ();
                if (type.get_string () == "wifi")
                    has_wifi = present.get_boolean ();
                if (network_status_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    network_status_window.menu.remove_menu_item (menu_item);
                else if (!network_status_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    network_status_window.menu.add_menu_item (menu_item);
                if (menu_item.checkbox.checked != powered.get_boolean ())
                    menu_item.checkbox.checked = powered.get_boolean ();
            });
            (builder.get_object ("connman_technology_present_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_technology_liststore, toggle, path, ControlPanel.NetworkTechnologyColumn.PRESENT));
            (builder.get_object ("connman_technology_powered_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_technology_liststore, toggle, path, ControlPanel.NetworkTechnologyColumn.POWERED));
            (builder.get_object ("connman_technology_connected_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_technology_liststore, toggle, path, ControlPanel.NetworkTechnologyColumn.CONNECTED));

            /* NetworkConnectionsWindow */

            network_connections_window = new NetworkConnectionsWindow ();
            bind_property ("has-wifi", network_connections_window, "has-wifi", BindingFlags.SYNC_CREATE);
            network_connections_window.scan_wifi_selected.connect (() => {
                network_connections_window.scan_wifi_busy = true;
                Timeout.add_seconds (3, () => {
                    network_connections_window.scan_wifi_busy = false;
                    return false;
                });
            });
            network_status_window.manage_connections_selected.connect (() =>
                network_status_window.screen.push_window (network_connections_window));

            networking_loading_checkbutton.bind_property ("active", network_connections_window, "loading", BindingFlags.SYNC_CREATE);
            var connman_service_liststore = builder.get_object ("connman_service_liststore") as Gtk.ListStore;
            connman_service_liststore.foreach ((model, path, iter) => {
                Value name;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.NAME, out name);
                var menu_item = new NetworkConnectionMenuItem () {
                    connection_name = name.dup_string (),
                    represented_object = new NetworkService (iter)
                };
                network_connections_window.menu.add_menu_item (menu_item);
                connman_service_liststore.set (iter, ControlPanel.NetworkServiceColumn.PRESENT, true);
                Value strength;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STRENGTH, out strength);
                menu_item.signal_strength = int.parse (strength.get_string ());
                // liststore USER_DATA is gpointer, so it does not take a ref
                connman_service_liststore.set (iter, ControlPanel.NetworkServiceColumn.USER_DATA, menu_item.ref ());
                // same with IPV4_DATA
                connman_service_liststore.set (iter, ControlPanel.NetworkServiceColumn.IPV4_DATA, new IPv4Info ().ref ());
                // and ENET_DATA
                connman_service_liststore.set (iter, ControlPanel.NetworkServiceColumn.ENET_DATA, new EnetInfo ().ref ());
                return false;
            });
            connman_service_liststore.row_changed.connect ((path, iter) => {
                Value present;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.PRESENT, out present);
                Value state;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STATE, out state);
                Value strength;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STRENGTH, out strength);
                Value user_data;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.USER_DATA, out user_data);
                var menu_item = (NetworkConnectionMenuItem)user_data.get_pointer ();
                if (network_connections_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    network_connections_window.menu.remove_menu_item (menu_item);
                else if (!network_connections_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    network_connections_window.menu.add_menu_item (menu_item);
                if (menu_item.signal_strength != int.parse (strength.get_string ()))
                    menu_item.signal_strength = int.parse (strength.get_string ());
            });
            (builder.get_object ("connman_services_treeview") as Gtk.TreeView).row_activated.connect ((path, column) => {
                Gtk.TreeIter iter;
                connman_service_liststore.get_iter (out iter, path);
                Value name;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.NAME, out name);
                if (column.get_name () == "connman_service_ipv4_treeviewcolumn") {
                    Value ipv4_data;
                    connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.IPV4_DATA, out ipv4_data);
                    var ipv4_info = (IPv4Info)ipv4_data.get_pointer ();
                    var dialog_builder = new Gtk.Builder ();
                    try {
                        dialog_builder.add_from_file (CONNMAN_SERVICE_IPV4_DIALOG_GLADE_FILE);
                        var dialog = dialog_builder.get_object ("dialog") as Gtk.Dialog;
                        (dialog_builder.get_object("name_label") as Gtk.Label)
                            .label = name.dup_string ();
                        var method_comboboxtext = dialog_builder.get_object("method_comboboxtext") as Gtk.ComboBoxText;
                        var ip_address_label = dialog_builder.get_object("ip_address_label") as Gtk.Label;
                        var ip_address_entry = dialog_builder.get_object("ip_address_entry") as Gtk.Entry;
                        var netmask_label = dialog_builder.get_object("netmask_label") as Gtk.Label;
                        var netmask_entry = dialog_builder.get_object("netmask_entry") as Gtk.Entry;
                        var gateway_label = dialog_builder.get_object("gateway_label") as Gtk.Label;
                        var gateway_entry = dialog_builder.get_object("gateway_entry") as Gtk.Entry;

                        var new_ipv4_info = new IPv4Info ();
                        ipv4_info.copy_to (new_ipv4_info);
                        new_ipv4_info.bind_property ("method", method_comboboxtext, "active-id", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                        new_ipv4_info.bind_property ("address", ip_address_entry, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                        new_ipv4_info.bind_property ("netmask", netmask_entry, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                        new_ipv4_info.bind_property ("gateway", gateway_entry, "text", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

                        method_comboboxtext.changed.connect (() => {
                            var sensitive = method_comboboxtext.active_id == "manual";
                            ip_address_label.sensitive = sensitive;
                            ip_address_entry.sensitive = sensitive;
                            netmask_label.sensitive = sensitive;
                            netmask_entry.sensitive = sensitive;
                            gateway_label.sensitive = sensitive;
                            gateway_entry.sensitive = sensitive;
                        });
                        method_comboboxtext.changed ();

                        (dialog_builder.get_object("cancel_button") as Gtk.Button)
                            .clicked.connect (() => dialog.destroy ());
                        (dialog_builder.get_object("save_button") as Gtk.Button)
                            .clicked.connect (() => {
                                new_ipv4_info.copy_to (ipv4_info);
                                dialog.destroy ();
                            });

                        dialog_builder.connect_signals (this);
                        dialog.show_all ();
                    } catch (Error err) {
                        critical ("ControlPanel init failed: %s", err.message);
                    }
                }
            });
            (builder.get_object ("connman_service_present_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_service_liststore, toggle, path, ControlPanel.NetworkServiceColumn.PRESENT));
            (builder.get_object ("connman_service_auto_connect_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_service_liststore, toggle, path, ControlPanel.NetworkServiceColumn.AUTO_CONNECT));
            (builder.get_object ("connman_service_state_cellrenderercombo") as Gtk.CellRendererCombo)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    connman_service_liststore, path, new_text, ControlPanel.NetworkServiceColumn.STATE));
            (builder.get_object ("connman_service_security_cellrenderercombo") as Gtk.CellRendererCombo)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    connman_service_liststore, path, new_text, ControlPanel.NetworkServiceColumn.SECURITY));
            (builder.get_object ("connman_service_strength_cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    connman_service_liststore, path, new_text, ControlPanel.NetworkServiceColumn.STRENGTH));

            network_connections_window.connection_selected.connect ((user_data) => {
                var service = user_data as NetworkService;
                Value name;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.NAME, out name);
                Value auto_connect;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.AUTO_CONNECT, out auto_connect);
                Value state;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.STATE, out state);
                Value security;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.SECURITY, out security);
                Value strength;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.STRENGTH, out strength);
                Value ipv4_data;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.IPV4_DATA, out ipv4_data);
                Value enet_data;
                connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.ENET_DATA, out enet_data);

                var ipv4_info = (IPv4Info)ipv4_data.get_pointer ();
                var network_properties_window = new NetworkPropertiesWindow (name.dup_string ()) {
                    auto_connect = auto_connect.get_boolean (),
                    state = state.get_string (),
                    security = security.get_string (),
                    strength = (uchar)int.parse (strength.get_string())
                };
                ipv4_info.bind_property ("method", network_properties_window, "ipv4-method", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                ipv4_info.bind_property ("address", network_properties_window, "ipv4-address", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                ipv4_info.bind_property ("netmask", network_properties_window, "ipv4-netmask", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                ipv4_info.bind_property ("gateway", network_properties_window, "ipv4-gateway", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

                var enet_info = (EnetInfo)enet_data.get_pointer ();
                enet_info.bind_property ("method", network_properties_window, "enet-method", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                enet_info.bind_property ("interface", network_properties_window, "enet-interface", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                enet_info.bind_property ("address", network_properties_window, "enet-address", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                enet_info.bind_property ("mtu", network_properties_window, "enet-mtu", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);

                networking_loading_checkbutton.bind_property ("active", network_properties_window, "loading", BindingFlags.SYNC_CREATE);
                network_status_window.screen.push_window (network_properties_window);
                weak NetworkPropertiesWindow weak_network_properties_window = network_properties_window;
                network_properties_window.notify["auto-connect"].connect (() => connman_service_liststore.set (
                    service.iter, ControlPanel.NetworkServiceColumn.AUTO_CONNECT,
                    weak_network_properties_window.auto_connect));
                var row_changed_handler_id = connman_service_liststore.row_changed.connect ((path, iter) => {
                    if (service.iter != iter)
                        return;
                    connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.AUTO_CONNECT, out auto_connect);
                    connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STATE, out state);
                    connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.SECURITY, out security);
                    connman_service_liststore.get_value (service.iter, ControlPanel.NetworkServiceColumn.STRENGTH, out strength);
                    if (weak_network_properties_window.auto_connect != auto_connect.get_boolean ())
                        weak_network_properties_window.auto_connect = auto_connect.get_boolean ();
                    if (weak_network_properties_window.state != state.get_string ())
                        weak_network_properties_window.state = state.get_string ();
                    if (weak_network_properties_window.security != security.get_string ())
                        weak_network_properties_window.security = security.get_string ();
                    if (weak_network_properties_window.strength != int.parse (strength.get_string ()))
                        weak_network_properties_window.strength = (uchar)int.parse (strength.get_string ());
                });
                network_properties_window.weak_ref((obj) => {
                    SignalHandler.disconnect (connman_service_liststore, row_changed_handler_id);
                });
                network_properties_window.connect_requested.connect (() => {
                    network_properties_window.is_connect_busy = true;
                    Timeout.add_seconds (2, () => {
                        network_properties_window.is_connected = !network_properties_window.is_connected;
                        network_properties_window.is_connect_busy = false;
                        return false;
                    });
                });
                network_properties_window.ipv4_change_requested.connect ((method, address, netmask, gateway) => {
                    weak_network_properties_window.ipv4_method = method;
                    weak_network_properties_window.ipv4_address = address;
                    weak_network_properties_window.ipv4_netmask = netmask;
                    weak_network_properties_window.ipv4_gateway = gateway;
                });
                network_properties_window.dns_change_requested.connect ((addresses) => {
                    weak_network_properties_window.dns_addresses = addresses;
                });
            });
        }

        class NetworkService : Object {
            public Gtk.TreeIter iter { get; private set; }

            public NetworkService (Gtk.TreeIter iter) {
                this.iter = iter;
            }
        }

        class IPv4Info : Object {
            public string method { get; set; }
            public string address { get; set; }
            public string netmask { get; set; }
            public string gateway { get; set; }

            public IPv4Info () {
                method = "dhcp";
                address = "192.168.3.33";
                netmask = "255.255.255.0";
                gateway = "192.168.3.1";
            }

            public void copy_to (IPv4Info info) {
                info.method = method;
                info.address = address;
                info.netmask = netmask;
                info.gateway = gateway;
            }
        }

        class EnetInfo : Object {
            public string method { get; set; }
            public string interface { get; set; }
            public string address { get; set; }
            public int mtu { get; set; }

            public EnetInfo () {
                method = "auto";
                interface = "eth0";
                address = "00:AA:33:BB:55";
                mtu = 1500;
            }
        }
    }
}