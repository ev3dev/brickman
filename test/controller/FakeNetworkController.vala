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
        public string menu_item_text { get { return "Networking"; } }
        NetworkStatusWindow network_status_window;
        public Window start_window { get { return network_status_window; } }
        NetworkConnectionsWindow network_connections_window;

        public FakeNetworkController (Gtk.Builder builder) throws Error {
            /* NetworkStatusWindow */

            network_status_window = new NetworkStatusWindow ();

            var networking_loading_checkbutton = builder.get_object ("networking_loading_checkbutton") as Gtk.CheckButton;
            networking_loading_checkbutton.bind_property ("active", network_status_window, "loading", BindingFlags.SYNC_CREATE);
            (builder.get_object ("connman_offline_mode_checkbutton") as Gtk.CheckButton)
                .bind_property ("active", network_status_window, "airplane-mode",
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
                Value powered;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.POWERED, out powered);
                Value user_data;
                connman_technology_liststore.get_value (iter, ControlPanel.NetworkTechnologyColumn.USER_DATA, out user_data);
                var menu_item = (CheckboxMenuItem)user_data.get_pointer ();
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
            network_status_window.manage_connections_selected.connect (() =>
                network_status_window.screen.push_window (network_connections_window));

            networking_loading_checkbutton.bind_property ("active", network_connections_window, "loading", BindingFlags.SYNC_CREATE);
            var connman_service_liststore = builder.get_object ("connman_service_liststore") as Gtk.ListStore;
            var connman_service_state_liststore = builder.get_object ("connman_service_state_liststore") as Gtk.ListStore;
            connman_service_liststore.foreach ((model, path, iter) => {
                Value name;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.NAME, out name);
                var menu_item = new NetworkConnectionMenuItem () {
                    connection_name = name.dup_string ()
                };
                network_connections_window.menu.add_menu_item (menu_item);
                connman_service_liststore.set (iter, ControlPanel.NetworkServiceColumn.PRESENT, true);
                Value has_strength;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.HAS_STRENGTH, out has_strength);
                if (has_strength.get_boolean ()) {
                    Value strength;
                    connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STRENGTH, out strength);
                    menu_item.signal_strength = int.parse (strength.get_string ());
                }
                menu_item.ref (); //liststore USER_DATA is gpointer, so it does not take a ref
                connman_service_liststore.set (iter, ControlPanel.NetworkServiceColumn.USER_DATA, menu_item);
                return false;
            });
            connman_service_liststore.row_changed.connect ((path, iter) => {
                Value present;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.PRESENT, out present);
                Value state;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STATE, out state);
                Value has_strength;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.HAS_STRENGTH, out has_strength);
                Value strength;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.STRENGTH, out strength);
                Value user_data;
                connman_service_liststore.get_value (iter, ControlPanel.NetworkServiceColumn.USER_DATA, out user_data);
                var menu_item = (NetworkConnectionMenuItem)user_data.get_pointer ();
                if (network_connections_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    network_connections_window.menu.remove_menu_item (menu_item);
                else if (!network_connections_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    network_connections_window.menu.add_menu_item (menu_item);
                if (has_strength.get_boolean ()) {
                    if (menu_item.signal_strength == null || menu_item.signal_strength != int.parse (strength.get_string ()))
                        menu_item.signal_strength = int.parse (strength.get_string ());
                } else if (menu_item.signal_strength != null) {
                    menu_item.signal_strength = null;
                }
            });
            (builder.get_object ("connman_service_present_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_service_liststore, toggle, path, ControlPanel.NetworkServiceColumn.PRESENT));
            (builder.get_object ("connman_service_state_cellrenderercombo") as Gtk.CellRendererCombo)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    connman_service_liststore, path, new_text, ControlPanel.NetworkServiceColumn.STATE));
            (builder.get_object ("connman_service_has_strength_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    connman_service_liststore, toggle, path, ControlPanel.NetworkServiceColumn.HAS_STRENGTH));
            (builder.get_object ("connman_service_strength_cellrendererspin") as Gtk.CellRendererSpin)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    connman_service_liststore, path, new_text, ControlPanel.NetworkServiceColumn.STRENGTH));
        }
    }
}