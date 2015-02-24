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

/* FakeConnManController.vala - Fake Network (ConnMan) controller for testing */

using EV3devKit.UI;

namespace BrickManager {
    public class FakeNetworkController : Object, IBrickManagerModule {
        const string CONNMAN_SERVICE_IPV4_DIALOG_GLADE_FILE = "ConnManServiceIPv4Dialog.glade";
        const string CONNMAN_AGENT_REQUEST_INPUT_DIALOG_GLADE_FILE = "ConnManAgentRequestInputDialog.glade";

        NetworkStatusWindow network_status_window;
        NetworkConnectionsWindow network_connections_window;
        public NetworkStatusBarItem network_status_bar_item;
        public WifiStatusBarItem wifi_status_bar_item;
        public WifiController wifi_controller;
        ConnManAgent agent;
        Gtk.Dialog? agent_request_input_dialog;
        Gtk.ListStore network_connections_liststore;

        public class WifiController : Object, IBrickManagerModule {
            public WifiWindow wifi_window;

            public BrickManagerWindow start_window { get { return wifi_window; } }
        }

        public BrickManagerWindow start_window { get { return network_status_window; } }

        public FakeNetworkController (Gtk.Builder builder) throws Error {

            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            var network_notebook = builder.get_object ("network-notebook") as Gtk.Notebook;
            var networking_loading_checkbutton = builder.get_object ("networking-loading-checkbutton") as Gtk.CheckButton;
            var networking_available_checkbutton = builder.get_object ("networking-available-checkbutton") as Gtk.CheckButton;

            /* NetworkStatusBarItem */

            network_status_bar_item = new NetworkStatusBarItem ();
            (builder.get_object ("network-status-bar-entry") as Gtk.Entry)
                .bind_property ("text", network_status_bar_item, "text", BindingFlags.SYNC_CREATE);

            /* NetworkStatusWindow */

            network_status_window = new NetworkStatusWindow ();
            network_status_window.shown.connect (() => {
                control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK;
                network_notebook.page = (int)ControlPanel.NetworkNotebookTab.MAIN;
            });

            networking_loading_checkbutton.bind_property ("active", network_status_window, "loading", BindingFlags.SYNC_CREATE);
            networking_available_checkbutton.bind_property ("active", network_status_window, "available", BindingFlags.SYNC_CREATE);
            (builder.get_object ("connman-offline-mode-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", network_status_window, "offline-mode",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            ((builder.get_object ("connman-state-comboboxtext") as Gtk.ComboBoxText).get_child () as Gtk.Entry)
                .bind_property ("text", network_status_window, "state", BindingFlags.SYNC_CREATE);

            /* NetworkConnectionsWindow */

            network_connections_window = new NetworkConnectionsWindow ();
            networking_loading_checkbutton.bind_property ("active", network_connections_window, "loading", BindingFlags.SYNC_CREATE);
            networking_available_checkbutton.bind_property ("active", network_connections_window, "available", BindingFlags.SYNC_CREATE);

            network_status_window.network_connections_selected.connect (() =>
                network_connections_window.show ());
            network_connections_window.shown.connect (() => {
                control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK;
                network_notebook.page = (int)ControlPanel.NetworkNotebookTab.CONNECTIONS;
            });

            (builder.get_object ("network-connections-has-wifi-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", network_connections_window, "has-wifi", BindingFlags.SYNC_CREATE);
            network_connections_window.scan_wifi_selected.connect (() => {
                network_connections_window.scan_wifi_busy = true;
                Timeout.add_seconds (3, () => {
                    network_connections_window.scan_wifi_busy = false;
                    return false;
                });
            });

            network_connections_liststore = builder.get_object ("network-connections-liststore") as Gtk.ListStore;
            network_connections_liststore.row_changed.connect ((path, iter) => {
                Value present;
                network_connections_liststore.get_value (iter, ControlPanel.NetworkConnectionsColumn.PRESENT, out present);
                Value name;
                network_connections_liststore.get_value (iter, ControlPanel.NetworkConnectionsColumn.NAME, out name);
                Value type;
                network_connections_liststore.get_value (iter, ControlPanel.NetworkConnectionsColumn.TYPE, out type);
                Value strength;
                network_connections_liststore.get_value (iter, ControlPanel.NetworkConnectionsColumn.STRENGTH, out strength);
                Value user_data;
                network_connections_liststore.get_value (iter, ControlPanel.NetworkConnectionsColumn.USER_DATA, out user_data);
                var menu_item = (NetworkConnectionMenuItem?)user_data.get_pointer ();
                if (present.get_boolean () && menu_item == null) {
                    var icon_file = (type.get_string () ?? "wifi").replace ("gadget", "usb") + "12x12.png";
                    menu_item = new NetworkConnectionMenuItem (icon_file);
                    menu_item.button.pressed.connect (() => {

                        /* NetworkPropertiesWindow */

                        var network_connection_info_window = new NetworkPropertiesWindow (name.dup_string ());
                        network_connection_info_window.shown.connect (() => {
                            control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK;
                            network_notebook.page = (int)ControlPanel.NetworkNotebookTab.CONNECTION_INFO;
                        });
                        ((builder.get_object ("network-connection-info-state-comboboxtext") as Gtk.ComboBoxText).get_child () as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "state", BindingFlags.SYNC_CREATE);
                        ((builder.get_object ("network-connection-info-security-comboboxtext") as Gtk.ComboBoxText).get_child () as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "security", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-strength-spinbutton") as Gtk.SpinButton)
                            .bind_property ("value", network_connection_info_window, "strength", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-auto-connect-checkbutton") as Gtk.CheckButton)
                            .bind_property ("active", network_connection_info_window, "auto-connect", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                        (builder.get_object ("network-connection-info-method-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "ipv4-method", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-address-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "ipv4-address", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-netmask-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "ipv4-netmask", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-gateway-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "ipv4-gateway", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-dns-textbuffer") as Gtk.TextBuffer)
                            .bind_property ("text", network_connection_info_window, "dns-addresses", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL,
                                transform_string_to_strv, transform_strv_to_string);
                        (builder.get_object ("network-connection-info-enet-method-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "enet-method", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-enet-iface-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "enet-interface", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-enet-mac-entry") as Gtk.Entry)
                            .bind_property ("text", network_connection_info_window, "enet-address", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-connection-info-enet-mtu-spinbutton") as Gtk.SpinButton)
                            .bind_property ("value", network_connection_info_window, "enet-mtu", BindingFlags.SYNC_CREATE);
                        network_connection_info_window.show ();
                    });

                    network_connections_window.menu.add_menu_item (menu_item);
                    network_connections_liststore.set_value (iter, ControlPanel.NetworkConnectionsColumn.USER_DATA, (void*)menu_item);
                }
                if (!present.get_boolean () && menu_item != null) {
                    network_connections_window.menu.remove_menu_item (menu_item);
                    network_connections_liststore.set_value (iter, ControlPanel.NetworkConnectionsColumn.USER_DATA, (void*)null);
                    menu_item = null;
                }
                if (menu_item == null)
                    return;
                if (menu_item.connection_name != name.get_string ())
                    menu_item.connection_name = name.dup_string ();
                if (menu_item.signal_strength != int.parse (strength.get_string () ?? "0"))
                    menu_item.signal_strength = int.parse (strength.get_string () ?? "0");
            });
            network_connections_liststore.foreach ((model, path, iter) => {
                model.row_changed (path, iter);
                return false;
            });

            (builder.get_object ("network-connections-add-button") as Gtk.Button).clicked.connect (() => {
                Gtk.TreeIter iter;
                network_connections_liststore.append (out iter);
                network_connections_liststore.set_value (iter, ControlPanel.NetworkConnectionsColumn.PRESENT, true);
                network_connections_liststore.set_value (iter, ControlPanel.NetworkConnectionsColumn.NAME, "New Connection");
                network_connections_liststore.set_value (iter, ControlPanel.NetworkConnectionsColumn.TYPE, "wifi");
                network_connections_liststore.set_value (iter, ControlPanel.NetworkConnectionsColumn.STRENGTH, "0");
                network_connections_liststore.row_changed (network_connections_liststore.get_path (iter), iter);
            });
            var network_connections_remove_button = builder.get_object ("network-connections-remove-button") as Gtk.Button;
            var network_connections_treeview_selection = (builder.get_object ("network-connections-treeview") as Gtk.TreeView).get_selection ();
            network_connections_remove_button.clicked.connect (() => {
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                if (network_connections_treeview_selection.get_selected (out model, out iter)) {
                    Value user_data;
                    model.get_value (iter, ControlPanel.NetworkConnectionsColumn.USER_DATA, out user_data);
                    var menu_item = (NetworkConnectionMenuItem?)user_data.get_pointer ();
                    if (menu_item != null)
                        network_connections_window.menu.remove_menu_item (menu_item);
                    network_connections_liststore.remove (iter);
                }
            });
            network_connections_treeview_selection.changed.connect (() => {
                network_connections_remove_button.sensitive = network_connections_treeview_selection.count_selected_rows () > 0;
            });
            network_connections_treeview_selection.changed ();

            (builder.get_object ("network-connections-present-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    network_connections_liststore, toggle, path, ControlPanel.NetworkConnectionsColumn.PRESENT));
            (builder.get_object ("network-connections-name-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    network_connections_liststore, path, new_text, ControlPanel.NetworkConnectionsColumn.NAME));
            (builder.get_object ("network-connections-type-cellrenderercombo") as Gtk.CellRendererCombo)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    network_connections_liststore, path, new_text, ControlPanel.NetworkConnectionsColumn.TYPE));
            (builder.get_object ("network-connections-strength-cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    network_connections_liststore, path, new_text, ControlPanel.NetworkConnectionsColumn.STRENGTH));

            /* WifiWindow */

            var wifi_window = new WifiWindow ();

            networking_loading_checkbutton.bind_property ("active", wifi_window, "loading", BindingFlags.SYNC_CREATE);
            networking_available_checkbutton.bind_property ("active", wifi_window, "available", BindingFlags.SYNC_CREATE);

            wifi_controller = new WifiController ();
            wifi_controller.wifi_window = wifi_window;

            wifi_window.shown.connect (() => {
                control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK;
                network_notebook.page = (int)ControlPanel.NetworkNotebookTab.WIFI;
            });

            (builder.get_object ("network-wifi-powered-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", wifi_window, "powered", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            (builder.get_object ("network-wifi-scanning-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", wifi_window, "scanning", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            wifi_window.scan_selected.connect (() => wifi_window.scanning = !wifi_window.scanning);

            var wifi_liststore = builder.get_object ("network-wifi-liststore") as Gtk.ListStore;
            wifi_liststore.row_changed.connect ((path, iter) => {
                Value present;
                wifi_liststore.get_value (iter, ControlPanel.NetworkWifiColumn.PRESENT, out present);
                Value connected;
                wifi_liststore.get_value (iter, ControlPanel.NetworkWifiColumn.CONNECTED, out connected);
                Value name;
                wifi_liststore.get_value (iter, ControlPanel.NetworkWifiColumn.NAME, out name);
                Value security;
                wifi_liststore.get_value (iter, ControlPanel.NetworkWifiColumn.SECURITY, out security);
                Value strength;
                wifi_liststore.get_value (iter, ControlPanel.NetworkWifiColumn.STRENGTH, out strength);
                Value user_data;
                wifi_liststore.get_value (iter, ControlPanel.NetworkWifiColumn.USER_DATA, out user_data);
                var menu_item = (WifiMenuItem?)user_data.get_pointer ();
                if (present.get_boolean () && menu_item == null) {
                    menu_item = new WifiMenuItem ();
                    menu_item.button.pressed.connect (() => {

                        /* WifiInfoWindow */

                        var wifi_info_window = new WifiInfoWindow (name.dup_string ());
                        wifi_info_window.shown.connect (() => {
                            control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK;
                            network_notebook.page = (int)ControlPanel.NetworkNotebookTab.WIFI_INFO;
                        });

                        ((builder.get_object ("network-wifi-info-status-comboboxtext") as Gtk.ComboBoxText).get_child () as Gtk.Entry)
                            .bind_property ("text", wifi_info_window, "status", BindingFlags.SYNC_CREATE);
                        ((builder.get_object ("network-wifi-info-security-comboboxtext") as Gtk.ComboBoxText).get_child () as Gtk.Entry)
                            .bind_property ("text", wifi_info_window, "security", BindingFlags.SYNC_CREATE);
                        var signal_spinbutton = builder.get_object ("network-wifi-info-signal-spinbutton") as Gtk.SpinButton;
                        signal_spinbutton.text = strength.dup_string ();
                        signal_spinbutton.bind_property ("text", wifi_info_window, "signal-strength", BindingFlags.SYNC_CREATE);
                        (builder.get_object ("network-wifi-info-address-entry") as Gtk.Entry)
                            .bind_property ("text", wifi_info_window, "address", BindingFlags.SYNC_CREATE);
                        ((builder.get_object ("network-wifi-info-action-comboboxtext") as Gtk.ComboBoxText).get_child () as Gtk.Entry)
                            .bind_property ("text", wifi_info_window, "action", BindingFlags.SYNC_CREATE);
                        var can_forget_checkbutton = builder.get_object ("network-wifi-info-can-forget-checkbutton") as Gtk.CheckButton;
                        can_forget_checkbutton.active = connected.get_boolean ();
                        can_forget_checkbutton.bind_property ("active", wifi_info_window, "can-forget", BindingFlags.SYNC_CREATE);

                        wifi_info_window.action_selected.connect (() => message ("action selected"));
                        wifi_info_window.forget_selected.connect (() => can_forget_checkbutton.active = false);
                        wifi_info_window.network_connection_selected.connect (() => message ("network connection selected"));

                        wifi_info_window.show ();
                    });
                    wifi_window.add_menu_item (menu_item);
                    wifi_liststore.set_value (iter, ControlPanel.NetworkWifiColumn.USER_DATA, (void*)menu_item);
                }
                if (!present.get_boolean () && menu_item != null) {
                    wifi_window.remove_menu_item (menu_item);
                    wifi_liststore.set_value (iter, ControlPanel.NetworkWifiColumn.USER_DATA, (void*)null);
                    menu_item = null;
                }
                if (menu_item == null)
                    return;
                if (menu_item.connected != connected.get_boolean ())
                    menu_item.connected = connected.get_boolean ();
                if (menu_item.connection_name != name.get_string ())
                    menu_item.connection_name = name.dup_string ();
                if (menu_item.security.to_string () != security.get_string ()) {
                    var new_security = (WifiSecurity) 0;
                    if (security.get_string () != null) {
                        var enum_class = (EnumClass) typeof (WifiSecurity).class_ref ();
                        var enum_value = enum_class.get_value_by_nick (security.get_string ());
                        if (enum_value != null) {
                            new_security = (WifiSecurity) enum_value.value;
                        }
                    }
                    menu_item.security = new_security;
                }
                if (menu_item.signal_strength != int.parse (strength.get_string () ?? "0"))
                    menu_item.signal_strength = int.parse (strength.get_string () ?? "0");
            });
            wifi_liststore.foreach ((model, path, iter) => {
                model.row_changed (path, iter);
                return false;
            });

            (builder.get_object ("network-wifi-add-button") as Gtk.Button).clicked.connect (() => {
                Gtk.TreeIter iter;
                wifi_liststore.append (out iter);
                wifi_liststore.set_value (iter, ControlPanel.NetworkWifiColumn.PRESENT, true);
                wifi_liststore.set_value (iter, ControlPanel.NetworkWifiColumn.NAME, "New Network");
                wifi_liststore.set_value (iter, ControlPanel.NetworkWifiColumn.SECURITY, "secured");
                wifi_liststore.set_value (iter, ControlPanel.NetworkWifiColumn.STRENGTH, "99");
                wifi_liststore.row_changed (wifi_liststore.get_path (iter), iter);
            });
            var network_wifi_remove_button = builder.get_object ("network-wifi-remove-button") as Gtk.Button;
            var network_wifi_treeview_selection = (builder.get_object ("network-wifi-treeview") as Gtk.TreeView).get_selection ();
            network_wifi_remove_button.clicked.connect (() => {
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                if (network_wifi_treeview_selection.get_selected (out model, out iter)) {
                    Value user_data;
                    model.get_value (iter, ControlPanel.NetworkWifiColumn.USER_DATA, out user_data);
                    var menu_item = (NetworkConnectionMenuItem?)user_data.get_pointer ();
                    if (menu_item != null)
                        wifi_window.remove_menu_item (menu_item);
                    wifi_liststore.remove (iter);
                }
            });
            network_wifi_treeview_selection.changed.connect (() => {
                network_wifi_remove_button.sensitive = network_wifi_treeview_selection.count_selected_rows () > 0;
            });
            network_wifi_treeview_selection.changed ();

            (builder.get_object ("network-wifi-present-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    wifi_liststore, toggle, path, ControlPanel.NetworkWifiColumn.PRESENT));
            (builder.get_object ("network-wifi-connected-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    wifi_liststore, toggle, path, ControlPanel.NetworkWifiColumn.CONNECTED));
            (builder.get_object ("network-wifi-name-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    wifi_liststore, path, new_text, ControlPanel.NetworkWifiColumn.NAME));
            (builder.get_object ("network-wifi-security-cellrenderercombo") as Gtk.CellRendererCombo)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    wifi_liststore, path, new_text, ControlPanel.NetworkWifiColumn.SECURITY));
            (builder.get_object ("network-wifi-strength-cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    wifi_liststore, path, new_text, ControlPanel.NetworkWifiColumn.STRENGTH));

            /* TetheringWindow */

            var network_tether_liststore = builder.get_object ("network-tether-liststore") as Gtk.ListStore;
            var network_tether_ipv4_address_entry = builder.get_object ("network-tether-ipv4-address-entry") as Gtk.Entry;
            var network_tether_ipv4_netmask_entry = builder.get_object ("network-tether-ipv4-netmask-entry") as Gtk.Entry;
            var network_tether_enet_iface_entry = builder.get_object ("network-tether-enet-iface-entry") as Gtk.Entry;
            var network_tether_enet_mac_entry = builder.get_object ("network-tether-enet-mac-entry") as Gtk.Entry;
            network_status_window.tethering_selected.connect (() => {
                var tethering_window = new TetheringWindow ();
                weak TetheringWindow weak_tethering_window = tethering_window;
                networking_loading_checkbutton.bind_property ("active", tethering_window, "loading", BindingFlags.SYNC_CREATE);
                networking_available_checkbutton.bind_property ("active", tethering_window, "available", BindingFlags.SYNC_CREATE);
                tethering_window.shown.connect (() => {
                    control_panel_notebook.page = (int)ControlPanel.Tab.NETWORK;
                    network_notebook.page = (int)ControlPanel.NetworkNotebookTab.TETHERING;
                });
                var handler_id = network_tether_liststore.row_changed.connect ((path, iter) => {
                    Value present;
                    network_tether_liststore.get_value (iter, ControlPanel.NetworkTetherColumn.PRESENT, out present);
                    Value name;
                    network_tether_liststore.get_value (iter, ControlPanel.NetworkTetherColumn.NAME, out name);
                    Value enabled;
                    network_tether_liststore.get_value (iter, ControlPanel.NetworkTetherColumn.ENABLED, out enabled);
                    Value user_data;
                    network_tether_liststore.get_value (iter, ControlPanel.NetworkTetherColumn.USER_DATA, out user_data);
                    var menu_item = (CheckboxMenuItem?)user_data.get_pointer ();
                    if (present.get_boolean () && menu_item == null) {
                        menu_item = weak_tethering_window.add_menu_item (name.dup_string ());
                        weak CheckboxMenuItem weak_menu_item = menu_item;
                        menu_item.checkbox.notify["checked"].connect (() =>
                            network_tether_liststore.set_value (iter, ControlPanel.NetworkTetherColumn.ENABLED, weak_menu_item.checkbox.checked));
                        network_tether_liststore.set_value (iter, ControlPanel.NetworkTetherColumn.USER_DATA, (void*)menu_item);
                    }
                    if (!present.get_boolean () && menu_item != null) {
                        weak_tethering_window.remove_menu_item (menu_item);
                        network_tether_liststore.set_value (iter, ControlPanel.NetworkTetherColumn.USER_DATA, (void*)null);
                        menu_item = null;
                    }
                    if (menu_item == null)
                        return;
                    if (menu_item.checkbox.checked != enabled.get_boolean ())
                        menu_item.checkbox.checked = enabled.get_boolean ();
                });
                network_tether_liststore.foreach ((model, path, iter) => {
                    model.row_changed (path, iter);
                    return false;
                });
                tethering_window.weak_ref (() => {
                    network_tether_liststore.disconnect (handler_id);
                    network_tether_liststore.foreach ((model, path, iter) => {
                        network_tether_liststore.set_value (iter, ControlPanel.NetworkTetherColumn.USER_DATA, (void*)null);
                        return false;
                    });
                });

                /* TetheringInfoWindow */

                tethering_window.tethering_info_selected.connect (() => {
                    var tethering_info_window = new TetheringInfoWindow ();
                    networking_loading_checkbutton.bind_property ("active", tethering_info_window, "loading", BindingFlags.SYNC_CREATE);
                    networking_available_checkbutton.bind_property ("active", tethering_info_window, "available", BindingFlags.SYNC_CREATE);
                    network_tether_ipv4_address_entry.bind_property ("text", tethering_info_window, "ipv4-address", BindingFlags.SYNC_CREATE);
                    network_tether_ipv4_netmask_entry.bind_property ("text", tethering_info_window, "ipv4-netmask", BindingFlags.SYNC_CREATE);
                    network_tether_enet_iface_entry.bind_property ("text", tethering_info_window, "enet-iface", BindingFlags.SYNC_CREATE);
                    network_tether_enet_mac_entry.bind_property ("text", tethering_info_window, "enet-mac", BindingFlags.SYNC_CREATE);
                    tethering_info_window.show ();
                });

                tethering_window.show ();
            });
            (builder.get_object ("network-tether-present-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    network_tether_liststore, toggle, path, ControlPanel.NetworkTetherColumn.PRESENT));
            (builder.get_object ("network-tether-enabled-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    network_tether_liststore, toggle, path, ControlPanel.NetworkTetherColumn.ENABLED));

            /* WifiStatusBarItem */

            wifi_status_bar_item = new WifiStatusBarItem ();
            (builder.get_object ("network-status-bar-wifi-powered-checkbutton") as Gtk.CheckButton)
                .bind_property("active", wifi_status_bar_item, "visible", BindingFlags.SYNC_CREATE);
            (builder.get_object ("network-status-bar-wifi-connected-checkbutton") as Gtk.CheckButton)
                .bind_property("active", wifi_status_bar_item, "connected", BindingFlags.SYNC_CREATE);

            /* Agent */

            agent = new ConnManAgent ();
            agent.manager = new ConnMan.Manager ();
            // (builder.get_object ("connman_agent_release_button") as Gtk.Button)
            //     .clicked.connect (() => agent.release ());
            (builder.get_object ("connman_agent_report_error_button") as Gtk.Button)
                .clicked.connect (() => {
                    agent.report_error.begin (new ObjectPath ("/service/path"),
                            "Service error message.", (obj, res) => {
                                try {
                                    agent.report_error.end (res);
                                } catch (ConnManAgentError err) {
                                    show_message (err.message);
                                }
                            });
                });
            (builder.get_object ("connman_agent_report_peer_error_button") as Gtk.Button)
                .clicked.connect (() => {
                    agent.report_peer_error.begin (new ObjectPath ("/peer/path"),
                            "Peer error message.", (obj, res) => {
                                try {
                                    agent.report_peer_error.end (res);
                                } catch (ConnManAgentError err) {
                                    show_message (err.message);
                                }
                            });
                });
            (builder.get_object ("connman_agent_request_browser_button") as Gtk.Button)
                .clicked.connect (() => {
                    agent.request_browser.begin (new ObjectPath ("/service/path"),
                            "http://www.ev3dev.org", (obj, res) => {
                                try {
                                    agent.request_browser.end (res);
                                } catch (ConnManAgentError err) {
                                    show_message (err.message);
                                }
                            });
                });
            (builder.get_object ("connman_agent_request_input_button") as Gtk.Button)
                .clicked.connect (on_show_agent_request_input_dialog);
            (builder.get_object ("connman_agent_request_peer_authorization_button") as Gtk.Button)
                .clicked.connect (() => {
                    agent.request_peer_authorization.begin (new ObjectPath ("/peer/path"),
                            new HashTable<string, Variant> (null, null), (obj, res) => {
                                try {
                                    var result = agent.request_peer_authorization.end (res);
                                    var strbuilder = new StringBuilder ("Results (%u):".printf (result.size ()));
                                    result.foreach ((k, v) =>
                                        strbuilder.append ("\n%s: %s".printf (k, v.print (true))));
                                    show_message (strbuilder.str);
                                } catch (ConnManAgentError err) {
                                    show_message (err.message);
                                }
                            });
                });
            (builder.get_object ("connman_agent_cancel_button") as Gtk.Button)
                .clicked.connect (() => agent.cancel.begin ());
        }

        public void add_controller (IBrickManagerModule controller) {
            network_status_window.add_technology_window (controller.start_window);
        }

        public void show_connection (string name) {
            var match_found = false;
            network_connections_liststore.foreach ((model, path, iter) => {
                Value net_name;
                model.get_value (iter, ControlPanel.NetworkConnectionsColumn.NAME, out net_name);
                if (net_name.get_string () == name) {
                    Value user_data;
                    model.get_value (iter, ControlPanel.NetworkConnectionsColumn.USER_DATA, out user_data);
                    var menu_item = (NetworkConnectionMenuItem)user_data.get_pointer ();
                    menu_item.button.pressed ();
                    match_found = true;
                }
                return match_found;
            });
            if (!match_found)
                message ("Could not find a network connection named '%s'", name);
        }

        bool transform_string_to_strv (Binding binding, Value source, ref Value target) {
            target = source.get_string ().split ("\n");
            return true;
        }

        bool transform_strv_to_string (Binding binding, Value source, ref Value target) {
            target = string.join ("\n", (string[])source);
            return true;
        }

        void on_show_agent_request_input_dialog () {
            if (agent_request_input_dialog == null) {
                var builder = new Gtk.Builder ();
                try {
                    builder.add_from_file (CONNMAN_AGENT_REQUEST_INPUT_DIALOG_GLADE_FILE);
                    agent_request_input_dialog = builder.get_object ("dialog") as Gtk.Dialog;
                    agent_request_input_dialog.set_transient_for (EV3devKitDesktop.GtkApp.main_window);
                    agent_request_input_dialog.response.connect ((id) => {
                        agent_request_input_dialog.destroy ();
                        agent_request_input_dialog = null;
                    });
                    (builder.get_object ("done_button") as Gtk.Button)
                        .clicked.connect (() => agent_request_input_dialog.response (0));
                    (builder.get_object ("request_psk_passphrase_button") as Gtk.Button)
                        .clicked.connect (() => {
                            var paramaters = new HashTable<string, Variant> (null, null);
                            var passphrase_args = new HashTable<string, Variant> (null, null);
                            passphrase_args["Type"] = "psk";
                            passphrase_args["Requirement"] = "mandatory";
                            paramaters["Passphrase"] = passphrase_args;
                            var expected_result = new HashTable<string, Variant> (null, null);
                            expected_result["Passphrase"] = "secret123";
                            call_agent_request_input.begin (paramaters, expected_result);
                        });
                    (builder.get_object ("request_psk_passphrase_with_previous_button") as Gtk.Button)
                        .clicked.connect (() => {
                            var paramaters = new HashTable<string, Variant> (null, null);
                            var passphrase_args = new HashTable<string, Variant> (null, null);
                            passphrase_args["Type"] = "psk";
                            passphrase_args["Requirement"] = "mandatory";
                            paramaters["Passphrase"] = passphrase_args;
                            var prev_passphrase_args = new HashTable<string, Variant> (null, null);
                            prev_passphrase_args["Type"] = "psk";
                            prev_passphrase_args["Requirement"] = "informational";
                            prev_passphrase_args["Value"] = "secret123";
                            paramaters["PreviousPassphrase"] = prev_passphrase_args;
                            var expected_result = new HashTable<string, Variant> (null, null);
                            expected_result["Passphrase"] = "anything-but-secret123";
                            call_agent_request_input.begin (paramaters, expected_result);
                        });
                    (builder.get_object ("request_hiddend_ssid_button") as Gtk.Button)
                        .clicked.connect (() => {
                            var paramaters = new HashTable<string, Variant> (null, null);
                            var name_args = new HashTable<string, Variant> (null, null);
                            name_args["Type"] = "string";
                            name_args["Requirement"] = "mandatory";
                            name_args["Alternates"] = new string[] { "SSID" };
                            paramaters["Name"] = name_args;
                            var ssid_args = new HashTable<string, Variant> (null, null);
                            ssid_args["Type"] = "ssid";
                            ssid_args["Requirement"] = "alternate";
                            paramaters["SSID"] = ssid_args;
                            var passphrase_args = new HashTable<string, Variant> (null, null);
                            passphrase_args["Type"] = "psk";
                            passphrase_args["Requirement"] = "mandatory";
                            paramaters["Passphrase"] = passphrase_args;
                            var expected_result = new HashTable<string, Variant> (null, null);
                            expected_result["Name"] = "SSID";
                            expected_result["Passphrase"] = "secret123";
                            call_agent_request_input.begin (paramaters, expected_result);
                        });
                } catch (Error err) {
                    critical ("%s", err.message);
                }
            }
            agent_request_input_dialog.show ();
        }

        async void call_agent_request_input (HashTable<string, Variant> paramaters,
            HashTable<string, Variant> expected_result)
        {
            try {
                var actual_result = yield agent.request_input (new ObjectPath ("/service/path"), paramaters);
                var builder = new StringBuilder ();
                builder.append ("Expected result (%u):".printf (expected_result.size ()));
                expected_result.foreach ((k, v) =>
                    builder.append ("\n%s: %s".printf (k, v.print (true))));
                builder.append ("\n\n");
                builder.append ("Actual result (%u):".printf (actual_result.size ()));
                actual_result.foreach ((k, v) =>
                    builder.append ("\n%s: %s".printf (k, v.print (true))));
                show_message (builder.str);
            } catch (ConnManAgentError err) {
                show_message (err.message);
            }
        }

        void show_message (string message) {
            var dialog = new Gtk.MessageDialog (EV3devKitDesktop.GtkApp.main_window,
                Gtk.DialogFlags.MODAL, Gtk.MessageType.INFO, Gtk.ButtonsType.OK, message);
            dialog.response.connect ((id) => dialog.destroy ());
            dialog.show ();
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
        }

        class EnetInfo : Object {
            public string method { get; set; }
            public string interface { get; set; }
            public string address { get; set; }
            public int mtu { get; set; }

            public EnetInfo () {
                method = "auto";
                interface = "eth0";
                address = "00:AA:33:BB:55:CC";
                mtu = 1500;
            }
        }
    }
}
