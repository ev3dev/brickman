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

/* FileBrowserController.vala - File Browser controller */

using Linux.Input;

namespace BrickManager {

    public enum LEDState {
        /**
         * Indicates that brickman is running normally (ready for input).
         */
        NORMAL,
        /**
         * Indicates that brickman is busy and will not respond to input.
         */
        BUSY,
        /**
         * Indicates that user program is running.
         */
        USER
    }

    /**
     * Object for hosting global instances of various managers used in brickman
     */
    public class GlobalManager : Object {
        bool have_ev3_leds = false;
        EV3devKit.Devices.LED ev3_green_left_led;
        EV3devKit.Devices.LED ev3_green_right_led;
        EV3devKit.Devices.LED ev3_red_left_led;
        EV3devKit.Devices.LED ev3_red_right_led;
        EV3devKit.Devices.Input ev3_buttons;

        /**
         * The device manager for interacting with hardware devices.
         */
        public EV3devKit.Devices.DeviceManager device_manager { get; private set; }

        /**
         * Emitted when the back button is held down for one second.
         */
        public signal void back_button_long_pressed ();

        public GlobalManager () {
            device_manager = new EV3devKit.Devices.DeviceManager ();
            try {
                ev3_green_left_led = device_manager.get_led (EV3devKit.Devices.LED.EV3_GREEN_LEFT);
                ev3_green_right_led = device_manager.get_led (EV3devKit.Devices.LED.EV3_GREEN_RIGHT);
                ev3_red_left_led = device_manager.get_led (EV3devKit.Devices.LED.EV3_RED_LEFT);
                ev3_red_right_led = device_manager.get_led (EV3devKit.Devices.LED.EV3_RED_RIGHT);
                have_ev3_leds = true;
            } catch (Error err) {
                critical ("%s", err.message);
            }
            try {
                ev3_buttons = device_manager.get_input_device (EV3devKit.Devices.Input.EV3_BUTTONS_NAME);
                uint timeout_id = 0;
                var button_down_handler_id = ev3_buttons.key_down.connect ((key_code) => {
                    if (key_code == KEY_BACKSPACE) {
                        timeout_id = Timeout.add (1000, () => {
                            back_button_long_pressed ();
                            EV3devKit.ConsoleApp.ignore_next_key_press ();
                            timeout_id = 0;
                            return Source.REMOVE;
                        });
                    }
                });
                var button_up_handler_id = ev3_buttons.key_up.connect ((key_code) => {
                    if (key_code == KEY_BACKSPACE && timeout_id != 0) {
                        Source.remove (timeout_id);
                    }
                });
                weak_ref (() => {
                    ev3_buttons.disconnect (button_down_handler_id);
                    ev3_buttons.disconnect (button_up_handler_id);
                });
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }

        public void set_leds (LEDState state) {
            if (!have_ev3_leds)
                return;
            try {
                switch (state) {
                case LEDState.NORMAL:
                    ev3_green_left_led.set_trigger ("default-on");
                    ev3_green_right_led.set_trigger ("default-on");
                    ev3_red_left_led.set_trigger ("none");
                    ev3_red_left_led.set_brightness (0);
                    ev3_red_right_led.set_trigger ("none");
                    ev3_red_right_led.set_brightness (0);
                    break;
                case LEDState.BUSY:
                    ev3_green_left_led.set_trigger ("none");
                    ev3_green_left_led.set_brightness (0);
                    ev3_green_right_led.set_trigger ("none");
                    ev3_green_right_led.set_brightness (0);
                    ev3_red_left_led.set_trigger ("default-on");
                    ev3_red_right_led.set_trigger ("default-on");
                    break;
                case LEDState.USER:
                    ev3_green_left_led.set_trigger ("default-on");
                    ev3_green_right_led.set_trigger ("default-on");
                    ev3_red_left_led.set_trigger ("default-on");
                    ev3_red_right_led.set_trigger ("default-on");
                    break;
                }
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }

        public void stop_all_motors () {
            device_manager.get_tacho_motors ().foreach ((motor) =>
                motor.run = 0);
            device_manager.get_dc_motors ().foreach ((motor) => {
                try {
                    motor.send_command ("coast");
                } catch (Error e) {
                    critical (e.message);
                }
            });
            device_manager.get_servo_motors ().foreach ((motor) =>
                motor.command = "float");
        }
    }
}