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

/* FakeBatteryController.vala - Fake Battery controller for testing */

using Ev3devKit.Ui;

namespace BrickManager {
    public class FakeBatteryController : Object, IBrickManagerModule {
        BatteryInfoWindow battery_window;
        internal BatteryStatusBarItem battery_status_bar_item;

        public string display_name { get { return "Battery"; } }

        public FakeBatteryController (Gtk.Builder builder) {
            battery_window = new BatteryInfoWindow (display_name);
            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            battery_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.BATTERY);

            var battery_loading_checkbutton = builder.get_object ("battery-loading-checkbutton") as Gtk.CheckButton;
            battery_loading_checkbutton.bind_property ("active", battery_window, "loading", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-tech-comboboxtext") as Gtk.ComboBoxText)
                .bind_property ("active-id", battery_window, "technology", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-voltage-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", battery_window, "has-voltage", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-voltage-spinbutton") as Gtk.SpinButton)
                .bind_property ("value", battery_window, "voltage", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-current-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", battery_window, "has-current", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-current-spinbutton") as Gtk.SpinButton)
                .bind_property ("value", battery_window, "current", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-power-checkbutton") as Gtk.CheckButton)
                .bind_property ("active", battery_window, "has-power", BindingFlags.SYNC_CREATE);
            (builder.get_object ("battery-power-spinbutton") as Gtk.SpinButton)
                .bind_property ("value", battery_window, "power", BindingFlags.SYNC_CREATE);

            battery_status_bar_item = new BatteryStatusBarItem ();
            (builder.get_object ("battery-voltage-spinbutton") as Gtk.SpinButton)
                .bind_property ("value", battery_status_bar_item, "voltage", BindingFlags.SYNC_CREATE);
        }

        public void show_main_window () {
            battery_window.show ();
        }
    }
}