/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
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

/* DeviceBrowserController.vala - Controller for Browsing Devices (sensors, motors, etc.) */

using Ev3devKit.Devices;
using Ev3devKit.Ui;

namespace BrickManager {
    public class DeviceBrowserController : Object, IBrickManagerModule {
        const int WATCH_MS = 500;

        DeviceManager manager;
        DeviceBrowserWindow device_browser_window;
        PortBrowserWindow? port_browser_window;
        SensorBrowserWindow? sensor_browser_window;
        MotorBrowserWindow? motor_browser_window;

        public BrickManagerWindow start_window { get { return device_browser_window; } }

        public DeviceBrowserController () {
            manager = global_manager.device_manager;
            device_browser_window = new DeviceBrowserWindow ();
            device_browser_window.ports_menu_item_selected.connect (
                on_ports_menu_item_selected);
            device_browser_window.sensors_menu_item_selected.connect (
                on_sensors_menu_item_selected);
            device_browser_window.motors_menu_item_selected.connect (
                on_motors_menu_item_selected);
        }

        void on_ports_menu_item_selected () {
            port_browser_window = new PortBrowserWindow ();
            var port_added_handler_id = manager.port_added.connect (on_port_added);
            manager.get_ports ().foreach (on_port_added);
            // connect_after ensures that this signal handler is called after
            // the others that are added in on_port_added (). This is important
            // so that we don't set port_browser_window = null before all of
            // the other signal handlers have run.
            port_browser_window.closed.connect_after (() => {
                manager.disconnect (port_added_handler_id);
                port_browser_window = null;
            });
            port_browser_window.show ();
        }

        void on_port_added (Port port) {
            var menu_item = new Ev3devKit.Ui.MenuItem.with_right_arrow (port.port_name);
            var button_pressed_handler_id = menu_item.button.pressed.connect (() => {
                var window = new PortInfoWindow (port.port_name, port.device_name,
                    port.driver_name);
                port.bind_property ("mode", window, "mode", BindingFlags.SYNC_CREATE);
                port.bind_property ("status", window, "status", BindingFlags.SYNC_CREATE);
                port.bind_property ("status", window, "can-set-device", BindingFlags.SYNC_CREATE,
                    transform_port_status_to_can_set_device);
                var set_device_button_pressed_hander_id = window.set_device_button_pressed.connect (() => {
                    // TODO: when we add support for more types of drivers here, we will
                    // need to add some logic here to lookup status.
                    var device_dialog = new SelectFromListDialog (manager.get_nxt_analog_sensor_driver_names ());
                    var item_selected_handler_id = device_dialog.item_selected.connect ((item) => {
                        try {
                            port.set_device (item);
                        } catch (Error err) {
                            var error_dialog = new MessageDialog ("Error", err.message);
                            error_dialog.show ();
                        }
                    });
                    var notify_connected_handler_id = port.notify["connected"].connect (() => {
                        device_dialog.close ();
                    });
                    ulong dialog_closed_handler_id = 0;
                    dialog_closed_handler_id = device_dialog.closed.connect (() => {
                        device_dialog.disconnect (item_selected_handler_id);
                        port.disconnect (notify_connected_handler_id);
                        device_dialog.disconnect (dialog_closed_handler_id);
                    });
                    device_dialog.show ();
                });
                var set_mode_button_pressed_hander_id = window.set_mode_button_pressed.connect (() => {
                    var mode_dialog = new SelectFromListDialog (port.modes);
                    var item_selected_handler_id = mode_dialog.item_selected.connect ((item) => {
                        try {
                            port.set_mode (item);
                        } catch (Error err) {
                            var error_dialog = new MessageDialog ("Error", err.message);
                            error_dialog.show ();
                        }
                    });
                    var notify_connected_handler_id = port.notify["connected"].connect (() => {
                        mode_dialog.close ();
                    });
                    ulong dialog_closed_handler_id = 0;
                    dialog_closed_handler_id = mode_dialog.closed.connect (() => {
                        mode_dialog.disconnect (item_selected_handler_id);
                        port.disconnect (notify_connected_handler_id);
                        mode_dialog.disconnect (dialog_closed_handler_id);
                    });
                    mode_dialog.show ();
                });
                var notify_connected_handler_id = port.notify["connected"].connect (() => {
                    var dialog = new MessageDialog ("Port Removed",
                        "Port %s was disconnected.".printf (port.port_name));
                    dialog.show ();
                    window.close ();
                });
                ulong window_closed_handler_id = 0;
                window_closed_handler_id = window.closed.connect (() => {
                    window.disconnect (set_device_button_pressed_hander_id);
                    window.disconnect (set_mode_button_pressed_hander_id);
                    port.disconnect (notify_connected_handler_id);
                    window.disconnect (window_closed_handler_id);
                });
                window.show ();
            });
            // TODO: figure out how to sort menu items
            port_browser_window.menu.add_menu_item (menu_item);
            ulong notify_connected_handler_id = 0;
            ulong window_closed_handler_id = 0;
            notify_connected_handler_id = port.notify["connected"].connect (() => {
                port_browser_window.menu.remove_menu_item (menu_item);
                menu_item.button.disconnect (button_pressed_handler_id);
                port.disconnect (notify_connected_handler_id);
                port_browser_window.disconnect (window_closed_handler_id);
            });
            window_closed_handler_id = port_browser_window.closed.connect (() => {
                menu_item.button.disconnect (button_pressed_handler_id);
                port.disconnect (notify_connected_handler_id);
                port_browser_window.disconnect (window_closed_handler_id);
            });
        }

        bool transform_port_status_to_can_set_device (Binding binding,
            Value source_value, ref Value target_value)
        {
            // Currently only support setting device for nxt-analog-sensor devices
            target_value.set_boolean (source_value.get_string () == "nxt-analog");
            return true;
        }



        void on_sensors_menu_item_selected () {
            sensor_browser_window = new SensorBrowserWindow ();
            var sensor_added_handler_id = manager.sensor_added.connect (on_sensor_added);
            manager.get_sensors ().foreach (on_sensor_added);
            // connect_after ensures that this signal handler is called after
            // the others that are added in on_sensor_added (). This is important
            // so that we don't set sensor_browser_window = null before all of
            // the other signal handlers have run.
            sensor_browser_window.closed.connect_after (() => {
                manager.disconnect (sensor_added_handler_id);
                sensor_browser_window = null;
            });
            sensor_browser_window.show ();
        }

        void on_sensor_added (Sensor sensor) {
            var menu_item = new Ev3devKit.Ui.MenuItem.with_right_arrow ("%s on %s".printf (sensor.driver_name,
                sensor.port_name));
            var button_pressed_handler_id = menu_item.button.pressed.connect (() => {
                var window = new SensorInfoWindow (sensor.driver_name, sensor.device_name,
                    sensor.port_name, sensor.commands != null);
                sensor.bind_property ("mode", window, "mode", BindingFlags.SYNC_CREATE);
                var watch_values_hander_id = window.watch_values_selected.connect (() => {
                    // TODO: Do we want to support showing more than one value?
                    var value_dialog = new SensorValueDialog ();
                    var value_timout_id = Timeout.add (WATCH_MS, () => {
                        try {
                            value_dialog.value_text = "%.*f".printf (sensor.decimals,
                                sensor.get_float_value (0));
                            if (sensor.units != null)
                                value_dialog.value_text += " %s".printf (sensor.units);
                        } catch (Error err) {
                            value_dialog.close ();
                            var error_dialog = new MessageDialog ("Error", err.message);
                            error_dialog.show ();
                            // this Timeout is removed by the value_dialog.closed hander
                            // so we just fall through and return CONTINUE here instead
                            // of returning REMOVE.
                        }
                        return Source.CONTINUE;
                    });
                    var notify_connected_handler_id = sensor.notify["connected"].connect (() => {
                        value_dialog.close ();
                    });
                    ulong dialog_closed_handler_id = 0;
                    dialog_closed_handler_id = value_dialog.closed.connect (() => {
                        Source.remove (value_timout_id);
                        sensor.disconnect (notify_connected_handler_id);
                        value_dialog.disconnect (dialog_closed_handler_id);
                    });
                    value_dialog.show ();
                });
                var set_mode_selected_hander_id = window.set_mode_selected.connect (() => {
                    var mode_dialog = new SelectFromListDialog (sensor.modes);
                    var item_selected_handler_id = mode_dialog.item_selected.connect ((item) => {
                        try {
                            sensor.set_mode (item);
                        } catch (Error err) {
                            var error_dialog = new MessageDialog ("Error", err.message);
                            error_dialog.show ();
                        }
                    });
                    var notify_connected_handler_id = sensor.notify["connected"].connect (() => {
                        mode_dialog.close ();
                    });
                    ulong dialog_closed_handler_id = 0;
                    dialog_closed_handler_id = mode_dialog.closed.connect (() => {
                        mode_dialog.disconnect (item_selected_handler_id);
                        sensor.disconnect (notify_connected_handler_id);
                        mode_dialog.disconnect (dialog_closed_handler_id);
                    });
                    mode_dialog.show ();
                });
                var send_command_selected_hander_id = window.send_command_selected.connect (() => {
                    var command_dialog = new SelectFromListDialog (sensor.commands);
                    var item_selected_handler_id = command_dialog.item_selected.connect ((item) => {
                        try {
                            sensor.send_command (item);
                        } catch (Error err) {
                            var error_dialog = new MessageDialog ("Error", err.message);
                            error_dialog.show ();
                        }
                    });
                    var notify_connected_handler_id = sensor.notify["connected"].connect (() => {
                        command_dialog.close ();
                    });
                    ulong dialog_closed_handler_id = 0;
                    dialog_closed_handler_id = command_dialog.closed.connect (() => {
                        command_dialog.disconnect (item_selected_handler_id);
                        sensor.disconnect (notify_connected_handler_id);
                        command_dialog.disconnect (dialog_closed_handler_id);
                    });
                    command_dialog.show ();
                });
                ulong notify_connected_handler_id = 0;
                ulong window_closed_handler_id = 0;
                notify_connected_handler_id = sensor.notify["connected"].connect (() => {
                    var dialog = new MessageDialog ("Sensor Removed",
                        "Sensor %s on %s was disconnected.".printf (sensor.driver_name,
                        sensor.port_name));
                    dialog.show ();
                    window.close ();
                });
                window_closed_handler_id = window.closed.connect (() => {
                    window.disconnect (watch_values_hander_id);
                    window.disconnect (set_mode_selected_hander_id);
                    window.disconnect (send_command_selected_hander_id);
                    sensor.disconnect (notify_connected_handler_id);
                    window.disconnect (window_closed_handler_id);
                });
                window.show ();
            });
            // TODO: figure out how to sort menu items
            sensor_browser_window.menu.add_menu_item (menu_item);
            ulong notify_connected_handler_id = 0;
            ulong window_closed_handler_id = 0;
            notify_connected_handler_id = sensor.notify["connected"].connect (() => {
                sensor_browser_window.menu.remove_menu_item (menu_item);
                menu_item.button.disconnect (button_pressed_handler_id);
                sensor.disconnect (notify_connected_handler_id);
                sensor_browser_window.disconnect (window_closed_handler_id);
            });
            window_closed_handler_id = sensor_browser_window.closed.connect (() => {
                menu_item.button.disconnect (button_pressed_handler_id);
                sensor.disconnect (notify_connected_handler_id);
                sensor_browser_window.disconnect (window_closed_handler_id);
            });
        }

        void on_motors_menu_item_selected () {
            motor_browser_window = new MotorBrowserWindow ();
            var tacho_motor_added_handler_id = manager.tacho_motor_added.connect (on_tacho_motor_added);
            manager.get_tacho_motors ().foreach (on_tacho_motor_added);
            var dc_motor_added_handler_id = manager.dc_motor_added.connect (on_dc_motor_added);
            manager.get_dc_motors ().foreach (on_dc_motor_added);
            var servo_motor_added_handler_id = manager.servo_motor_added.connect (on_servo_motor_added);
            manager.get_servo_motors ().foreach (on_servo_motor_added);
            // connect_after ensures that this signal handler is called after
            // the others that are added in on_tacho_mootr_added (). This is important
            // so that we don't set motor_browser_window = null before all of
            // the other signal handlers have run.
            motor_browser_window.closed.connect_after (() => {
                manager.disconnect (tacho_motor_added_handler_id);
                manager.disconnect (dc_motor_added_handler_id);
                manager.disconnect (servo_motor_added_handler_id);
                motor_browser_window = null;
            });
            motor_browser_window.show ();
        }

        void on_tacho_motor_added (TachoMotor motor) {
            var menu_item = new Ev3devKit.Ui.MenuItem.with_right_arrow ("%s on %s".printf (motor.driver_name,
                motor.port_name));
            var button_pressed_handler_id = menu_item.button.pressed.connect (() => {
                var window = new MotorInfoWindow (motor.driver_name, "tacho-motor",
                    motor.device_name, motor.port_name, true);
                var watch_values_hander_id = window.watch_values_selected.connect (() => {
                    // TODO: Do we want to also show speed?
                    var value_dialog = new MotorValueDialog ();
                    var value_timout_id = Timeout.add (WATCH_MS, () => {
                        // TODO: Convert to degrees
                        value_dialog.value_text = "%d".printf (motor.position);
                        return Source.CONTINUE;
                    });
                    var notify_connected_handler_id = motor.notify["connected"].connect (() => {
                        value_dialog.close ();
                    });
                    ulong dialog_closed_handler_id = 0;
                    dialog_closed_handler_id = value_dialog.closed.connect (() => {
                        Source.remove (value_timout_id);
                        motor.disconnect (notify_connected_handler_id);
                        value_dialog.disconnect (dialog_closed_handler_id);
                    });
                    value_dialog.show ();
                });
                ulong notify_connected_handler_id = 0;
                ulong window_closed_handler_id = 0;
                notify_connected_handler_id = motor.notify["connected"].connect (() => {
                    var dialog = new MessageDialog ("Motor Removed",
                        "Motor %s on %s was disconnected.".printf (motor.driver_name,
                        motor.port_name));
                    dialog.show ();
                    window.close ();
                });
                window_closed_handler_id = window.closed.connect (() => {
                    window.disconnect (watch_values_hander_id);
                    motor.disconnect (notify_connected_handler_id);
                    window.disconnect (window_closed_handler_id);
                });
                window.show ();
            });
            // TODO: figure out how to sort menu items
            motor_browser_window.menu.add_menu_item (menu_item);
            ulong notify_connected_handler_id = 0;
            ulong window_closed_handler_id = 0;
            notify_connected_handler_id = motor.notify["connected"].connect (() => {
                motor_browser_window.menu.remove_menu_item (menu_item);
                menu_item.button.disconnect (button_pressed_handler_id);
                motor.disconnect (notify_connected_handler_id);
                motor_browser_window.disconnect (window_closed_handler_id);
            });
            window_closed_handler_id = motor_browser_window.closed.connect (() => {
                menu_item.button.disconnect (button_pressed_handler_id);
                motor.disconnect (notify_connected_handler_id);
                motor_browser_window.disconnect (window_closed_handler_id);
            });
        }

        void on_dc_motor_added (DcMotor motor) {
            var menu_item = new Ev3devKit.Ui.MenuItem.with_right_arrow ("%s on %s".printf (motor.driver_name,
                motor.port_name));
            var button_pressed_handler_id = menu_item.button.pressed.connect (() => {
                var window = new MotorInfoWindow (motor.driver_name, "dc-motor",
                    motor.device_name, motor.port_name, false);
                ulong notify_connected_handler_id = 0;
                ulong window_closed_handler_id = 0;
                notify_connected_handler_id = motor.notify["connected"].connect (() => {
                    var dialog = new MessageDialog ("Motor Removed",
                        "Motor %s on %s was disconnected.".printf (motor.driver_name,
                        motor.port_name));
                    dialog.show ();
                    window.close ();
                });
                window_closed_handler_id = window.closed.connect (() => {
                    motor.disconnect (notify_connected_handler_id);
                    window.disconnect (window_closed_handler_id);
                });
                window.show ();
            });
            // TODO: figure out how to sort menu items
            motor_browser_window.menu.add_menu_item (menu_item);
            ulong notify_connected_handler_id = 0;
            ulong window_closed_handler_id = 0;
            notify_connected_handler_id = motor.notify["connected"].connect (() => {
                motor_browser_window.menu.remove_menu_item (menu_item);
                menu_item.button.disconnect (button_pressed_handler_id);
                motor.disconnect (notify_connected_handler_id);
                motor_browser_window.disconnect (window_closed_handler_id);
            });
            window_closed_handler_id = motor_browser_window.closed.connect (() => {
                menu_item.button.disconnect (button_pressed_handler_id);
                motor.disconnect (notify_connected_handler_id);
                motor_browser_window.disconnect (window_closed_handler_id);
            });
        }

        void on_servo_motor_added (ServoMotor motor) {
            var menu_item = new Ev3devKit.Ui.MenuItem.with_right_arrow ("%s on %s".printf (motor.driver_name,
                motor.port_name));
            var button_pressed_handler_id = menu_item.button.pressed.connect (() => {
                var window = new MotorInfoWindow (motor.driver_name, "servo-motor",
                    motor.device_name, motor.port_name, false);
                ulong notify_connected_handler_id = 0;
                ulong window_closed_handler_id = 0;
                notify_connected_handler_id = motor.notify["connected"].connect (() => {
                    var dialog = new MessageDialog ("Motor Removed",
                        "Motor %s on %s was disconnected.".printf (motor.driver_name,
                        motor.port_name));
                    dialog.show ();
                    window.close ();
                });
                window_closed_handler_id = window.closed.connect (() => {
                    motor.disconnect (notify_connected_handler_id);
                    window.disconnect (window_closed_handler_id);
                });
                window.show ();
            });
            // TODO: figure out how to sort menu items
            motor_browser_window.menu.add_menu_item (menu_item);
            ulong notify_connected_handler_id = 0;
            ulong window_closed_handler_id = 0;
            notify_connected_handler_id = motor.notify["connected"].connect (() => {
                motor_browser_window.menu.remove_menu_item (menu_item);
                menu_item.button.disconnect (button_pressed_handler_id);
                motor.disconnect (notify_connected_handler_id);
                motor_browser_window.disconnect (window_closed_handler_id);
            });
            window_closed_handler_id = motor_browser_window.closed.connect (() => {
                menu_item.button.disconnect (button_pressed_handler_id);
                motor.disconnect (notify_connected_handler_id);
                motor_browser_window.disconnect (window_closed_handler_id);
            });
        }
    }
}