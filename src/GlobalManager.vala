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

    public enum EV3Button {
        UP = KEY_UP,
        DOWN = KEY_DOWN,
        LEFT = KEY_LEFT,
        RIGHT = KEY_RIGHT,
        ENTER = KEY_ENTER,
        BACK = KEY_BACKSPACE
    }

    /**
     * Object for hosting global instances of various managers used in brickman
     */
    public class GlobalManager : Object {
        const string EV3_BUTTONS_INPUT_EVENT_PATH =
            "/dev/input/by-path/platform-gpio-keys.0-event";

        bool have_ev3_leds = false;
        EV3devKit.Devices.LED ev3_green_left_led;
        EV3devKit.Devices.LED ev3_green_right_led;
        EV3devKit.Devices.LED ev3_red_left_led;
        EV3devKit.Devices.LED ev3_red_right_led;

        /**
         * The device manager for interacting with hardware devices.
         */
        public EV3devKit.Devices.DeviceManager device_manager { get; construct set; }

        /**
         * Emitted when a button on the EV3 is pressed.
         *
         * @param button The button that was pressed.
         */
        public signal void ev3_button_down (EV3Button button);

        /**
         * Emitted when a button on the EV3 is released.
         *
         * @param code The button that was pressed.
         */
        public signal void ev3_button_up (EV3Button button);

        public GlobalManager () {
            try {
                var channel = new IOChannel.file (EV3_BUTTONS_INPUT_EVENT_PATH, "r");
                channel.set_encoding (null);
                channel.set_close_on_unref (false);
                channel.add_watch (IOCondition.IN, (source, condition) => {
                    try {
                        var chars = new char[sizeof(Event)];
                        size_t bytes_read;
                        source.read_chars (chars, out bytes_read);
                        var event = (Event*)chars;
                        if (event.type == EV_KEY) {
                            if (event.value == 0)
                                ev3_button_down ((EV3Button)event.code);
                            else
                                ev3_button_up ((EV3Button)event.code);
                        }
                    } catch (Error err) {
                        critical ("%s", err.message);
                        return false;
                    }
                    return true;
                });
            } catch (Error err) {
                critical ("%s", err.message);
            }
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