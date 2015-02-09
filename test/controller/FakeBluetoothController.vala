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

/* FakeBluetoothController.vala - Fake Bluetooth (BlueZ 5) controller for testing */

using BlueZ5;
using EV3devKit.UI;

namespace BrickManager {
    public class FakeBluetoothController : Object, IBrickManagerModule {
        BluetoothWindow bluetooth_window;

        public BrickManagerWindow start_window { get { return bluetooth_window; } }

        public signal void show_network_connection_requested (string address);

        public FakeBluetoothController (Gtk.Builder builder) {
            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            var bluetooth_loading_checkbutton = builder.get_object ("bluetooth-loading-checkbutton") as Gtk.CheckButton;
            var bluetooth_available_checkbutton = builder.get_object ("bluetooth-available-checkbutton") as Gtk.CheckButton;

            /* Start/Main Window */

            bluetooth_window = new BluetoothWindow ();
            bluetooth_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.BLUETOOTH);
            bluetooth_loading_checkbutton.bind_property ("active", bluetooth_window, "loading", BindingFlags.SYNC_CREATE);
            bluetooth_available_checkbutton.bind_property ("active", bluetooth_window, "available", BindingFlags.SYNC_CREATE);
            (builder.get_object ("bluetooth-powered-checkbutton") as Gtk.CheckButton).bind_property ("active",
                bluetooth_window, "powered", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            (builder.get_object ("bluetooth-visible-checkbutton") as Gtk.CheckButton).bind_property ("active",
                bluetooth_window, "bt-visible", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            (builder.get_object ("bluetooth-scanning-checkbutton") as Gtk.CheckButton).bind_property ("active",
                bluetooth_window, "scanning", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            bluetooth_window.scan_selected.connect (() => bluetooth_window.scanning = !bluetooth_window.scanning);

            var bluetooth_show_adapter_checkbutton = builder.get_object ("bluetooth-show-adapter-checkbutton") as Gtk.CheckButton;

            var bluetooth_devices_liststore = builder.get_object ("bluetooth-devices-liststore") as Gtk.ListStore;
            bluetooth_devices_liststore.row_changed.connect ((path, iter) => {
                Value present;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.PRESENT, out present);
                Value name;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.NAME, out name);
                Value adapter;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ADAPTER, out adapter);
                Value connected;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED, out connected);
                Value user_data;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.USER_DATA, out user_data);
                var menu_item = (BluetoothDeviceMenuItem?)user_data.get_pointer ();
                if (!present.get_boolean () && menu_item != null) {
                    bluetooth_window.menu.remove_menu_item (menu_item);
                    bluetooth_devices_liststore.set (iter, ControlPanel.BluetoothDeviceColumn.USER_DATA, (void*)null);
                }
                if (present.get_boolean () && menu_item == null) {
                    menu_item = new BluetoothDeviceMenuItem () {
                        name = name.dup_string (),
                        adapter = adapter.dup_string (),
                        connected = connected.get_boolean ()
                    };
                    weak BluetoothDeviceMenuItem weak_menu_item = menu_item;
                    bluetooth_show_adapter_checkbutton.bind_property ("active", menu_item, "show-adapter", BindingFlags.SYNC_CREATE);
                    menu_item.button.pressed.connect (() => {

                        /* Device Info Window */

                        var bluetooth_device_info_title_entry = builder.get_object ("bluetooth-device-info-title-entry") as Gtk.Entry;
                        var bluetooth_device_info_address_entry = builder.get_object ("bluetooth-device-info-address-entry") as Gtk.Entry;
                        var bluetooth_device_info_paired_checkbutton = builder.get_object ("bluetooth-device-info-paired-checkbutton") as Gtk.CheckButton;
                        var bluetooth_device_info_connected_checkbutton = builder.get_object ("bluetooth-device-info-connected-checkbutton") as Gtk.CheckButton;
                        var bluetooth_device_info_has_network_checkbutton = builder.get_object ("bluetooth-device-info-has-network-checkbutton") as Gtk.CheckButton;

                        bluetooth_device_info_title_entry.text = weak_menu_item.name +
                            (bluetooth_show_adapter_checkbutton.active ? " (%s)".printf (weak_menu_item.adapter) : "");
                        bluetooth_device_info_connected_checkbutton.active = weak_menu_item.connected;

                        var info_window = new BluetoothDeviceWindow ();
                        bluetooth_device_info_title_entry.bind_property ("text", info_window, "title", BindingFlags.SYNC_CREATE);
                        bluetooth_device_info_address_entry.bind_property ("text", info_window, "address", BindingFlags.SYNC_CREATE);
                        bluetooth_device_info_paired_checkbutton.bind_property ("active", info_window, "paired", BindingFlags.SYNC_CREATE);
                        bluetooth_device_info_connected_checkbutton.bind_property ("active", info_window, "connected", BindingFlags.SYNC_CREATE);
                        bluetooth_device_info_has_network_checkbutton.bind_property ("active", info_window, "has-network", BindingFlags.SYNC_CREATE);
                        weak BluetoothDeviceWindow weak_info_window = info_window;
                        info_window.network_selected.connect (() => show_network_connection_requested (weak_menu_item.name));
                        info_window.connect_selected.connect (() => weak_info_window.connected = !weak_info_window.connected);
                        info_window.show ();
                    });

                    bluetooth_window.menu.add_menu_item (menu_item);
                    bluetooth_devices_liststore.set (iter, ControlPanel.BluetoothDeviceColumn.USER_DATA, (void*)menu_item);
                }
                if (menu_item == null)
                    return;
                if (menu_item.name != name.get_string ())
                    menu_item.name = name.dup_string ();
                if (menu_item.adapter != adapter.get_string ())
                    menu_item.adapter = adapter.dup_string ();
                if (menu_item.connected != connected.get_boolean ())
                    menu_item.connected = connected.get_boolean ();
            });
            bluetooth_devices_liststore.foreach ((model, path, iter) => {
                model.row_changed (path, iter);
                return false;
            });
            (builder.get_object ("bluetooth-devices-present-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.PRESENT));
            (builder.get_object ("bluetooth-devices-name-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.NAME));
            (builder.get_object ("bluetooth-devices-adapter-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.ADAPTER));
            (builder.get_object ("bluetooth-devices-connected-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.CONNECTED));

            (builder.get_object ("bluetooth-devices-add-button") as Gtk.Button).clicked.connect (() => {
                Gtk.TreeIter iter;
                bluetooth_devices_liststore.append (out iter);
                bluetooth_devices_liststore.set_value (iter, ControlPanel.BluetoothDeviceColumn.PRESENT, true);
                bluetooth_devices_liststore.set_value (iter, ControlPanel.BluetoothDeviceColumn.NAME, "New Device");
                bluetooth_devices_liststore.set_value (iter, ControlPanel.BluetoothDeviceColumn.ADAPTER, "ev3dev");
                bluetooth_devices_liststore.set_value (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED, false);
                bluetooth_devices_liststore.row_changed (bluetooth_devices_liststore.get_path (iter), iter);
            });
            var bluetooth_devices_remove_button = builder.get_object ("bluetooth-devices-remove-button") as Gtk.Button;
            var bluetooth_devices_treeview_selection = (builder.get_object ("bluetooth-devices-treeview") as Gtk.TreeView).get_selection ();
            bluetooth_devices_remove_button.clicked.connect (() => {
                Gtk.TreeModel model;
                Gtk.TreeIter iter;
                if (bluetooth_devices_treeview_selection.get_selected (out model, out iter)) {
                    Value user_data;
                    model.get_value (iter, ControlPanel.BluetoothDeviceColumn.USER_DATA, out user_data);
                    var menu_item = (BluetoothDeviceMenuItem?)user_data.get_pointer ();
                    if (menu_item != null)
                        bluetooth_window.menu.remove_menu_item (menu_item);
                    bluetooth_devices_liststore.remove (iter);
                }
            });
            bluetooth_devices_treeview_selection.changed.connect (() => {
                bluetooth_devices_remove_button.sensitive = bluetooth_devices_treeview_selection.count_selected_rows () > 0;
            });
            bluetooth_devices_treeview_selection.changed ();

            /* Agent */

            var agent = new BlueZ5Agent ();
            (builder.get_object ("bluetooth-agent-request-pin-code-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    agent.request_pin_code.begin (path, (obj, res) => {
                        try {
                            var pin_code = agent.request_pin_code.end (res);
                            show_message ("pin_code: %s".printf (pin_code));
                        } catch (BlueZError err) {
                            message ("%s", err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-display-pin-code-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change this value.
                    agent.display_pin_code (path, "000000");
                });
            (builder.get_object ("bluetooth-agent-request-passkey-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    agent.request_passkey.begin (path, (obj, res) => {
                        try {
                            var pin_code = agent.request_passkey.end (res);
                            show_message ("passkey: %u".printf (pin_code));
                        } catch (BlueZError err) {
                            message ("%s", err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-display-passkey-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change these values.
                    agent.display_passkey (path, 0, 0);
                });
            (builder.get_object ("bluetooth-agent-request-confirmation-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change these values.
                    agent.request_confirmation.begin (path, 0, (obj, res) => {
                        try {
                            agent.request_confirmation.end (res);
                            show_message ("Accepted.");
                        } catch (BlueZError err) {
                            show_message (err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-request-authorization-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change these values.
                    agent.request_authorization.begin (path, (obj, res) => {
                        try {
                            agent.request_authorization.end (res);
                            show_message ("Accepted.");
                        } catch (BlueZError err) {
                            show_message (err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-authorize-service-button") as Gtk.Button)
                .clicked.connect (() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change these values.
                    agent.authorize_service.begin (path, UUID.SerialPort, (obj, res) => {
                        try {
                            agent.authorize_service.end (res);
                            show_message ("Accepted.");
                        } catch (BlueZError err) {
                            show_message (err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-cancel-button") as Gtk.Button)
                .clicked.connect (() => agent.cancel ());
        }

        void show_message (string message) {
            var dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
                Gtk.MessageType.INFO, Gtk.ButtonsType.OK, message);
            dialog.response.connect ((id) => dialog.destroy ());
            dialog.show ();
        }
    }
}