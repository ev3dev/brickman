/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
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

/* FakeBluetoothController.vala - Fake Bluetooth (BlueZ 5) controller for testing */

using BlueZ5;
using EV3devKit.UI;

namespace BrickManager {
    public class FakeBluetoothController : Object, IBrickManagerModule {
        BluetoothWindow bluetooth_window;

        public string menu_item_text { get { return "Bluetooth"; } }
        public Window start_window { get { return bluetooth_window; } }

        public FakeBluetoothController (Gtk.Builder builder) {
            bluetooth_window = new BluetoothWindow ();

            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            bluetooth_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.BLUETOOTH);

            var bluetooth_loading_checkbutton = builder.get_object ("bluetooth-loading-checkbutton") as Gtk.CheckButton;
            bluetooth_loading_checkbutton.bind_property ("active", bluetooth_window, "loading", BindingFlags.SYNC_CREATE);

            /* Adapters */

            var bluetooth_adapters_liststore = builder.get_object ("bluetooth-adapters-liststore") as Gtk.ListStore;
            bluetooth_adapters_liststore.foreach ((model, path, iter) => {
                Value present;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.PRESENT, out present);
                Value alias;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ALIAS, out alias);
                Value discoverable;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.DISCOVERABLE, out discoverable);
                Value discovering;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.DISCOVERING, out discovering);
                // TODO: handle more than one adapter
                bluetooth_window.bt_visible = discoverable.get_boolean ();
                bluetooth_window.scanning = discovering.get_boolean ();
                bluetooth_window.notify["bt-visible"].connect (() => bluetooth_adapters_liststore.set (
                    iter, ControlPanel.BluetoothAdapterColumn.DISCOVERABLE, bluetooth_window.bt_visible));
                bluetooth_window.notify["scanning"].connect (() => bluetooth_adapters_liststore.set (
                    iter, ControlPanel.BluetoothAdapterColumn.DISCOVERING, bluetooth_window.scanning));
                bluetooth_window.scan_selected.connect (() => bluetooth_adapters_liststore.set (
                    iter, ControlPanel.BluetoothAdapterColumn.DISCOVERING, !bluetooth_window.scanning));
                return false;
            });
            bluetooth_adapters_liststore.row_changed.connect ((path, iter) => {
                Value present;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.PRESENT, out present);
                Value alias;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ALIAS, out alias);
                Value discoverable;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.DISCOVERABLE, out discoverable);
                Value discovering;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.DISCOVERING, out discovering);
                Value user_data;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.USER_DATA, out user_data);
                // TODO: handle more than one adapter
                if (bluetooth_window.bt_visible != discoverable.get_boolean ())
                    bluetooth_window.bt_visible = discoverable.get_boolean ();
                if (bluetooth_window.scanning != discovering.get_boolean ())
                    bluetooth_window.scanning = discovering.get_boolean ();
            });
            (builder.get_object ("bluetooth-adapters-present-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_adapters_liststore, toggle, path, ControlPanel.BluetoothAdapterColumn.PRESENT));
            (builder.get_object ("bluetooth-adapters-address-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_adapters_liststore, path, new_text, ControlPanel.BluetoothAdapterColumn.ADDRESS));
            (builder.get_object ("bluetooth-adapters-name-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_adapters_liststore, path, new_text, ControlPanel.BluetoothAdapterColumn.NAME));
            (builder.get_object ("bluetooth-adapters-alias-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_adapters_liststore, path, new_text, ControlPanel.BluetoothAdapterColumn.ALIAS));
            (builder.get_object ("bluetooth-adapters-powered-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_adapters_liststore, toggle, path, ControlPanel.BluetoothAdapterColumn.POWERED));
            (builder.get_object ("bluetooth-adapters-discoverable-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_adapters_liststore, toggle, path, ControlPanel.BluetoothAdapterColumn.DISCOVERABLE));
            (builder.get_object ("bluetooth-adapters-pairable-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_adapters_liststore, toggle, path, ControlPanel.BluetoothAdapterColumn.PAIRABLE));
            (builder.get_object ("bluetooth-adapters-pairable-timeout-cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_adapters_liststore, path, new_text, ControlPanel.BluetoothAdapterColumn.PAIRABLE_TIMEOUT));
            (builder.get_object ("bluetooth-adapters-discoverable-timeout-cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_adapters_liststore, path, new_text, ControlPanel.BluetoothAdapterColumn.DISCOVERABLE_TIMEOUT));
            (builder.get_object ("bluetooth-adapters-discovering-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_adapters_liststore, toggle, path, ControlPanel.BluetoothAdapterColumn.DISCOVERING));

            /* Devices */

            var bluetooth_devices_liststore = builder.get_object ("bluetooth-devices-liststore") as Gtk.ListStore;
            bluetooth_devices_liststore.foreach ((model, path, iter) => {
                Value present;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.PRESENT, out present);
                Value alias;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ALIAS, out alias);
                Value connected;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED, out connected);
                var menu_item = new BluetoothDeviceMenuItem () {
                    name = alias.dup_string (),
                    connected = connected.get_boolean ()
                };
                // there is a reference cycle with menu_item here, but it doesn't matter because we never get rid of it.
                menu_item.button.pressed.connect (() => {
                    Value address;
                    bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ADDRESS, out address);
                    bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ALIAS, out alias);
                    Value paired;
                    bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.PAIRED, out paired);
                    bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED, out connected);
                    var info_window = new BluetoothDeviceWindow () {
                        title = alias.dup_string (),
                        address = address.dup_string (),
                        paired = paired.get_boolean (),
                        connected = connected.get_boolean (),
                        loading = false
                    };
                    weak BluetoothDeviceWindow weak_info_window = info_window;
                    info_window.connect_selected.connect (() => {
                        if (!paired.get_boolean ()) {
                            bluetooth_devices_liststore.set (iter, ControlPanel.BluetoothDeviceColumn.PAIRED, true);
                        } else {
                            bluetooth_devices_liststore.set (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED,
                                !weak_info_window.connected);
                        }
                    });
                    info_window.remove_selected.connect (() => {
                        bluetooth_devices_liststore.set (iter, ControlPanel.BluetoothDeviceColumn.PRESENT, false);
                        weak_info_window.close ();
                    });
                    var handler_id = bluetooth_devices_liststore.row_changed.connect ((path, iter) => {
                        bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ADDRESS, out address);
                        bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ALIAS, out alias);
                        bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.PAIRED, out paired);
                        bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED, out connected);
                        if (weak_info_window.title != alias.get_string ())
                            weak_info_window.title = alias.dup_string ();
                        if (weak_info_window.address != address.get_string ())
                            weak_info_window.address = address.dup_string ();
                        if (weak_info_window.paired != paired.get_boolean ())
                            weak_info_window.paired = paired.get_boolean ();
                        if (weak_info_window.connected != connected.get_boolean ())
                            weak_info_window.connected = connected.get_boolean ();
                    });
                    info_window.weak_ref (() => SignalHandler.disconnect (bluetooth_devices_liststore, handler_id));
                    info_window.show ();
                });
                if (present.get_boolean ())
                    bluetooth_window.menu.add_menu_item (menu_item);
                menu_item.ref (); //liststore USER_DATA is gpointer, so it does not take a ref
                bluetooth_devices_liststore.set (iter, ControlPanel.BluetoothDeviceColumn.USER_DATA, menu_item);
                return false;
            });
            bluetooth_devices_liststore.row_changed.connect ((path, iter) => {
                Value present;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.PRESENT, out present);
                Value alias;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.ALIAS, out alias);
                Value connected;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.CONNECTED, out connected);
                Value user_data;
                bluetooth_devices_liststore.get_value (iter, ControlPanel.BluetoothDeviceColumn.USER_DATA, out user_data);
                var menu_item = (BluetoothDeviceMenuItem)user_data.get_pointer ();
                if (bluetooth_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    bluetooth_window.menu.remove_menu_item (menu_item);
                else if (!bluetooth_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    bluetooth_window.menu.add_menu_item (menu_item);
                if (menu_item.name != alias.get_string ())
                    menu_item.name = alias.dup_string ();
                if (menu_item.connected != connected.get_boolean ())
                    menu_item.connected = connected.get_boolean ();
            });
            (builder.get_object ("bluetooth-devices-present-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.PRESENT));
            (builder.get_object ("bluetooth-devices-address-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.ADDRESS));
            (builder.get_object ("bluetooth-devices-name-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.NAME));
            (builder.get_object ("bluetooth-devices-icon-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.ICON));
            (builder.get_object ("bluetooth-devices-class-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.CLASS));
            (builder.get_object ("bluetooth-devices-appearance-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.APPEARANCE));
            (builder.get_object ("bluetooth-devices-paired-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.PAIRED));
            (builder.get_object ("bluetooth-devices-connected-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.CONNECTED));
            (builder.get_object ("bluetooth-devices-trusted-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.TRUSTED));
            (builder.get_object ("bluetooth-devices-blocked-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.BLOCKED));
            (builder.get_object ("bluetooth-devices-alias-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.ALIAS));
            (builder.get_object ("bluetooth-devices-adapter-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.ADAPTER));
            (builder.get_object ("bluetooth-devices-legacy-pairing-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    bluetooth_devices_liststore, toggle, path, ControlPanel.BluetoothDeviceColumn.LEGACY_PAIRING));
            (builder.get_object ("bluetooth-devices-rssi-cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    bluetooth_devices_liststore, path, new_text, ControlPanel.BluetoothDeviceColumn.RSSI));

            /* Agent */

            var agent = new BlueZ5Agent ();
            (builder.get_object ("bluetooth-agent-request-pin-code-button") as Gtk.Button)
                .clicked.connect(() => {
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
                .clicked.connect(() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change this value.
                    agent.display_pin_code (path, "000000");
                });
            (builder.get_object ("bluetooth-agent-request-passkey-button") as Gtk.Button)
                .clicked.connect(() => {
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
                .clicked.connect(() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change these values.
                    agent.display_passkey (path, 0, 0);
                });
            (builder.get_object ("bluetooth-agent-request-confirmation-button") as Gtk.Button)
                .clicked.connect(() => {
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
                .clicked.connect(() => {
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
                .clicked.connect(() => {
                    var path = new ObjectPath ("My Device");
                    // TODO: add UI to change these values.
                    agent.authorize_service.begin (path, "My Service", (obj, res) => {
                        try {
                            agent.authorize_service.end (res);
                            show_message ("Accepted.");
                        } catch (BlueZError err) {
                            show_message (err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-cancel-button") as Gtk.Button)
                .clicked.connect(() => agent.cancel ());
        }

        void show_message (string message) {
            var dialog = new Gtk.MessageDialog (null, Gtk.DialogFlags.MODAL,
                Gtk.MessageType.INFO, Gtk.ButtonsType.OK, message);
            dialog.response.connect ((id) => dialog.destroy ());
            dialog.show ();
        }
    }
}