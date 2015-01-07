/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
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

/* FakeDeviceBrowserController.vala - Fake Device Browser controller for testing */

using EV3devKit;

namespace BrickManager {
    public class FakeDeviceBrowserController : Object, IBrickManagerModule {
        DeviceBrowserWindow device_browser_window;

        public string menu_item_text { get { return "Device Browser"; } }
        public Window start_window { get { return device_browser_window; } }

        public FakeDeviceBrowserController (Gtk.Builder builder) {
            device_browser_window = new DeviceBrowserWindow () {
                loading = false
            };
            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            device_browser_window.shown.connect (() =>
                control_panel_notebook.page = (int)ControlPanel.Tab.DEVICE_BROWSER);

            var port_browser_window = new PortBrowserWindow () {
                loading = false
            };
            var sensor_browser_window = new SensorBrowserWindow () {
                loading = false
            };

            /* device_browser_window setup */

            device_browser_window.ports_menu_item_selected.connect (() => {
                port_browser_window.show ();
            });
            device_browser_window.sensors_menu_item_selected.connect (() => {
                sensor_browser_window.show ();
            });

            /* Ports */

            var ports_liststore = builder.get_object ("ports_liststore") as Gtk.ListStore;
            ports_liststore.foreach ((model, path, iter) => {
                Value device_name;
                ports_liststore.get_value (iter, ControlPanel.PortsColumn.DEVICE_NAME, out device_name);
                Value port_name;
                ports_liststore.get_value (iter, ControlPanel.PortsColumn.PORT_NAME, out port_name);
                Value driver_name;
                ports_liststore.get_value (iter, ControlPanel.PortsColumn.DRIVER_NAME, out driver_name);
                var menu_item = new EV3devKit.MenuItem (port_name.dup_string ());
                port_browser_window.menu.add_menu_item (menu_item);
                //liststore USER_DATA is gpointer, so it does not take a ref
                ports_liststore.set (iter, ControlPanel.PortsColumn.USER_DATA, menu_item.ref ());
                menu_item.button.pressed.connect (() => {
                    var window = new PortInfoWindow (port_name.dup_string (), device_name.dup_string (),
                        driver_name.dup_string ()) {
                        loading = false
                    };
                    var row_changed_handler_id = ports_liststore.row_changed.connect ((path, iter) => {
                        Value present;
                        ports_liststore.get_value (iter, ControlPanel.PortsColumn.PRESENT, out present);
                        if (!present.get_boolean ()) {
                            window.close ();
                            var dialog = new MessageDialog ("Port Removed",
                                "Port %s is no longer connected.".printf (port_name.get_string ()));
                            dialog.show ();
                            return;
                        }
                        Value mode;
                        ports_liststore.get_value (iter, ControlPanel.PortsColumn.MODE, out mode);
                        Value status;
                        ports_liststore.get_value (iter, ControlPanel.PortsColumn.STATUS, out status);
                        Value can_set_device;
                        ports_liststore.get_value (iter, ControlPanel.PortsColumn.CAN_SET_DEVICE, out can_set_device);
                        if (window.mode != mode.get_string ())
                            window.mode = mode.dup_string ();
                        if (window.status != status.get_string ())
                            window.status = status.dup_string ();
                        if (window.can_set_device != can_set_device.get_boolean ())
                            window.can_set_device = can_set_device.get_boolean ();
                    });
                    var set_mode_button_pressed_handler_id = window.set_mode_button_pressed.connect (() => {
                        Value modes;
                        ports_liststore.get_value (iter, ControlPanel.PortsColumn.MODES, out modes);
                        var dialog = new SelectFromListDialog (modes.get_string ().split (" "));
                        var item_selected_handler_id = dialog.item_selected.connect ((mode) => {
                            ports_liststore.set (iter, ControlPanel.PortsColumn.MODE, mode);
                            ports_liststore.set (iter, ControlPanel.PortsColumn.STATUS, mode);
                        });
                        var row_changed_handler_id2 = ports_liststore.row_changed.connect ((path, iter) => {
                            Value present;
                            ports_liststore.get_value (iter, ControlPanel.PortsColumn.PRESENT, out present);
                            if (!present.get_boolean ())
                                dialog.close ();
                        });
                        ulong dialog_closed_handler_id = 0;
                        dialog_closed_handler_id = dialog.closed.connect (() => {
                            dialog.disconnect (item_selected_handler_id);
                            ports_liststore.disconnect (row_changed_handler_id2);
                            dialog.disconnect (dialog_closed_handler_id);
                        });
                        dialog.show ();
                    });
                    var set_device_button_pressed_handler_id = window.set_device_button_pressed.connect (() => {
                        // TODO: Make this list come from the Gtk UI
                        string[] devices = { "nxt-analog", "lego-nxt-touch", "lego-nxt-light", "lego-nxt-sound" };
                        var dialog = new SelectFromListDialog (devices);
                        var item_selected_handler_id = dialog.item_selected.connect ((device) => {
                            message ("Selected device: %s", device);
                        });
                        var row_changed_handler_id2 = ports_liststore.row_changed.connect ((path, iter) => {
                            Value present;
                            ports_liststore.get_value (iter, ControlPanel.PortsColumn.PRESENT, out present);
                            if (!present.get_boolean ())
                                dialog.close ();
                        });
                        ulong dialog_closed_handler_id = 0;
                        dialog_closed_handler_id = dialog.closed.connect (() => {
                            dialog.disconnect (item_selected_handler_id);
                            ports_liststore.disconnect (row_changed_handler_id2);
                            dialog.disconnect (dialog_closed_handler_id);
                        });
                        dialog.show ();
                    });
                    ulong closed_handler_id = 0;
                    closed_handler_id = window.closed.connect (() => {
                        ports_liststore.disconnect (row_changed_handler_id);
                        window.disconnect (set_mode_button_pressed_handler_id);
                        window.disconnect (set_device_button_pressed_handler_id);
                        window.disconnect (closed_handler_id);
                    });
                    ports_liststore.row_changed (path, iter);
                    window.show ();
                });
                return false;
            });
            ports_liststore.row_changed.connect ((path, iter) => {
                Value present;
                ports_liststore.get_value (iter, ControlPanel.PortsColumn.PRESENT, out present);
                Value user_data;
                ports_liststore.get_value (iter, ControlPanel.PortsColumn.USER_DATA, out user_data);
                var menu_item = (EV3devKit.MenuItem)user_data.get_pointer ();
                if (port_browser_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    port_browser_window.menu.remove_menu_item (menu_item);
                else if (!port_browser_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    port_browser_window.menu.add_menu_item (menu_item);
            });
            (builder.get_object ("ports_present_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    ports_liststore, toggle, path, ControlPanel.PortsColumn.PRESENT));
            (builder.get_object ("ports_mode_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    ports_liststore, path, new_text, ControlPanel.PortsColumn.MODE));
            (builder.get_object ("ports_modes_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    ports_liststore, path, new_text, ControlPanel.PortsColumn.MODES));
            (builder.get_object ("ports_status_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    ports_liststore, path, new_text, ControlPanel.PortsColumn.STATUS));
            (builder.get_object ("ports_can_set_device_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    ports_liststore, toggle, path, ControlPanel.PortsColumn.CAN_SET_DEVICE));

            /* Sensors */

            var sensors_liststore = builder.get_object ("sensors_liststore") as Gtk.ListStore;
            sensors_liststore.foreach ((model, path, iter) => {
                Value present;
                sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.PRESENT, out present);
                Value device_name;
                sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.DEVICE_NAME, out device_name);
                Value driver_name;
                sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.DRIVER_NAME, out driver_name);
                Value port_name;
                sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.PORT_NAME, out port_name);
                var menu_item = new EV3devKit.MenuItem ("%s on %s".printf (driver_name.get_string (),
                    port_name.get_string ()));
                if (present.get_boolean ())
                    sensor_browser_window.menu.add_menu_item (menu_item);
                //liststore USER_DATA is gpointer, so it does not take a ref
                sensors_liststore.set (iter, ControlPanel.SensorsColumn.USER_DATA, menu_item.ref ());
                menu_item.button.pressed.connect (() => {
                    Value commands;
                    sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.COMMANDS, out commands);
                    var window = new SensorInfoWindow (driver_name.dup_string (), device_name.dup_string (),
                        port_name.dup_string (), commands.get_string () != "n/a") {
                        loading = false
                    };
                    var row_changed_handler_id = sensors_liststore.row_changed.connect ((path, iter) => {
                        sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.PRESENT, out present);
                        if (!present.get_boolean ()) {
                            window.close ();
                            var dialog = new MessageDialog ("Sensor Removed",
                                "Sensor %s on %s is no longer connected.".printf (driver_name.get_string(),
                                    port_name.get_string ()));
                            dialog.show ();
                            return;
                        }
                        Value address;
                        sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.ADDRESS, out address);
                        Value mode;
                        sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.MODE, out mode);
                        if (window.address != address.get_string ())
                            window.address = address.dup_string ();
                        if (window.mode != mode.get_string ())
                            window.mode = mode.dup_string ();
                    });
                    var watch_values_handler_id = window.watch_values_selected.connect (() => {
                        Value units;
                        sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.UNITS, out units);
                        var dialog = new SensorValueDialog ();
                        // TODO: make this value adjustable in UI instead of using Timeout
                        var value = 0;
                        var timeout_id = Timeout.add (500, () => {
                            dialog.value_text = "%d %s".printf (value++, units.get_string ());
                            return Source.CONTINUE;
                        });
                        dialog.closed.connect (() => Source.remove (timeout_id));
                        dialog.show ();
                    });
                    var set_mode_handler_id = window.set_mode_selected.connect (() => {
                        Value modes;
                        sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.MODES, out modes);
                        var dialog = new SelectFromListDialog (modes.get_string ().split (" "));
                        dialog.item_selected.connect ((mode) => {
                            sensors_liststore.set (iter, ControlPanel.SensorsColumn.MODE, mode);
                        });
                        dialog.show ();
                    });
                    var send_command_handler_id = window.send_command_selected.connect (() => {
                        var dialog = new SelectFromListDialog (commands.get_string ().split (" "));
                        dialog.item_selected.connect ((command) => {
                            message ("Sent command: %s", command);
                        });
                        dialog.show ();
                    });
                    ulong closed_handler_id = 0;
                    closed_handler_id = window.closed.connect (() => {
                        sensors_liststore.disconnect (row_changed_handler_id);
                        window.disconnect (watch_values_handler_id);
                        window.disconnect (set_mode_handler_id);
                        window.disconnect (send_command_handler_id);
                        window.disconnect (closed_handler_id);
                    });
                    sensors_liststore.row_changed (path, iter);
                    window.show ();
                });
                return false;
            });
            sensors_liststore.row_changed.connect ((path, iter) => {
                Value present;
                sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.PRESENT, out present);
                Value user_data;
                sensors_liststore.get_value (iter, ControlPanel.SensorsColumn.USER_DATA, out user_data);
                var menu_item = (EV3devKit.MenuItem)user_data.get_pointer ();
                if (sensor_browser_window.menu.has_menu_item (menu_item) && !present.get_boolean ())
                    sensor_browser_window.menu.remove_menu_item (menu_item);
                else if (!sensor_browser_window.menu.has_menu_item (menu_item) && present.get_boolean ())
                    sensor_browser_window.menu.add_menu_item (menu_item);
            });
            (builder.get_object ("sensors_present_cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    sensors_liststore, toggle, path, ControlPanel.SensorsColumn.PRESENT));
            (builder.get_object ("sensors_address_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    sensors_liststore, path, new_text, ControlPanel.SensorsColumn.ADDRESS));
            (builder.get_object ("sensors_modes_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    sensors_liststore, path, new_text, ControlPanel.SensorsColumn.MODES));
            (builder.get_object ("sensors_mode_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    sensors_liststore, path, new_text, ControlPanel.SensorsColumn.MODE));
            (builder.get_object ("sensors_commands_cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    sensors_liststore, path, new_text, ControlPanel.SensorsColumn.COMMANDS));
        }
    }
}