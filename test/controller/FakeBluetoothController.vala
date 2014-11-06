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

/* FakeBluetoothController.vala - Fake Bluetooth (BlueZ 5) controller for testing */

using EV3devKit;

namespace BrickManager {
    public class FakeBluetoothController : Object, IBrickManagerModule {
        BluetoothWindow bluetooth_window;
        BluetoothAdaptersWindow adapters_window;
        BluetoothDevicesWindow devices_window;

        public string menu_item_text { get { return "Bluetooth"; } }
        public Window start_window { get { return bluetooth_window; } }

        public FakeBluetoothController (Gtk.Builder builder) {
            bluetooth_window = new BluetoothWindow ();
            bluetooth_window.adapters_selected.connect (() => bluetooth_window.screen.show_window (adapters_window));
            bluetooth_window.devices_selected.connect (() => bluetooth_window.screen.show_window (devices_window));
            adapters_window = new BluetoothAdaptersWindow ();
            devices_window = new BluetoothDevicesWindow ();

            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            bluetooth_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.BLUETOOTH);

            var bluetooth_loading_checkbutton = builder.get_object ("bluetooth-loading-checkbutton") as Gtk.CheckButton;
            bluetooth_loading_checkbutton.bind_property ("active", bluetooth_window, "loading", BindingFlags.SYNC_CREATE);
            bluetooth_loading_checkbutton.bind_property ("active", adapters_window, "loading", BindingFlags.SYNC_CREATE);
            bluetooth_loading_checkbutton.bind_property ("active", devices_window, "loading", BindingFlags.SYNC_CREATE);

            /* Adapters */

            var bluetooth_adapters_liststore = builder.get_object ("bluetooth-adapters-liststore") as Gtk.ListStore;
            bluetooth_adapters_liststore.foreach ((model, path, iter) => {
                Value present;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.PRESENT, out present);
                Value alias;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ALIAS, out alias);
                var menu_item = new EV3devKit.MenuItem (alias.dup_string ());
                // there is a reference cycle with menu_item here, but it doesn't matter because we never get rid of it.
                menu_item.button.pressed.connect (() => {
                Value address;
                    bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ADDRESS, out address);
                    bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ALIAS, out alias);
                    var info_window = new BluetoothAdapterInfoWindow () {
                        title = alias.dup_string (),
                        address = address.dup_string (),
                        loading = false
                    };
                    var handler_id = bluetooth_adapters_liststore.row_changed.connect ((path, iter) => {
                        bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ADDRESS, out address);
                        bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ALIAS, out alias);
                        if (info_window.title != alias.get_string ())
                            info_window.title = alias.dup_string ();
                        if (info_window.address != address.get_string ())
                            info_window.address = address.dup_string ();
                    });
                    info_window.weak_ref (() => SignalHandler.disconnect (bluetooth_adapters_liststore, handler_id));
                    adapters_window.screen.show_window (info_window);
                });
                if (present.get_boolean ())
                    adapters_window.menu.add_menu_item (menu_item);
                menu_item.ref (); //liststore USER_DATA is gpointer, so it does not take a ref
                bluetooth_adapters_liststore.set (iter, ControlPanel.BluetoothAdapterColumn.USER_DATA, menu_item);
                return false;
            });
            bluetooth_adapters_liststore.row_changed.connect ((path, iter) => {
                Value present;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.PRESENT, out present);
                Value alias;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.ALIAS, out alias);
                Value user_data;
                bluetooth_adapters_liststore.get_value (iter, ControlPanel.BluetoothAdapterColumn.USER_DATA, out user_data);
                var menu_item = (EV3devKit.MenuItem)user_data.get_pointer ();
                if (adapters_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    adapters_window.menu.remove_menu_item (menu_item);
                else if (!adapters_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    adapters_window.menu.add_menu_item (menu_item);
                var menu_item_label = (Label)menu_item.button.child;
                if (menu_item_label.text != alias.get_string ())
                    menu_item_label.text = alias.dup_string ();
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

            /* Agent */

            var agent = new BlueZ5Agent (DesktopTestApp.screen);
            (builder.get_object ("bluetooth-agent-display-pincode-button") as Gtk.Button)
                .clicked.connect(() => {
                    var path = new ObjectPath ("My Device");
                    agent.display_pin_code.begin (path, "000000", (obj, res) => {
                        try {
                            agent.display_pin_code.end (res);
                        } catch (BlueZ5Error err) {
                            critical ("%s", err.message);
                        }
                    });
                });
            (builder.get_object ("bluetooth-agent-cancel-button") as Gtk.Button)
                .clicked.connect(() => agent.cancel ());
        }
    }
}