/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2015 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * SensorInfoWindow.vala: Main Device Browser Menu
 */

using EV3devKit.UI;

namespace BrickManager {
    public class SensorInfoWindow : BrickManagerWindow {
        const int SPACING = 4;

        Label mode_value_label;

        public string mode {
            get { return mode_value_label.text; }
            set { mode_value_label.text = value; }
        }

        public signal void watch_values_selected ();
        public signal void set_mode_selected ();
        public signal void send_command_selected ();

        public SensorInfoWindow (string name, string device_name, string port_name, bool supports_commands) {
            title = name;
            var vscroll = new Scroll.vertical () {
                can_focus = false,
                margin_top = -3
            };
            content_vbox.add (vscroll);
            var vbox = new Box.vertical ();
            vscroll.add (vbox);
            var device_name_label = new Label ("Device name:") {
                can_focus = true
            };
            var device_name_label_has_focus_handler_id =
                device_name_label.notify["has-focus"].connect (() =>
            {
                if (device_name_label.has_focus)
                    vscroll.scroll_to_child (device_name_label);
            });
            vbox.add (device_name_label);
            var device_name_value_label = new Label (device_name);
            vbox.add (device_name_value_label);
            var port_name_label = new Label ("Port name:") {
                margin_top = SPACING
            };
            vbox.add (port_name_label);
            var port_name_value_label = new Label (port_name);
            vbox.add (port_name_value_label);
            var mode_label = new Label ("Mode:") {
                margin_top = SPACING
            };
            vbox.add (mode_label);
            mode_value_label = new Label ("???");
            vbox.add (mode_value_label);
            var watch_values_button = new Button.with_label ("Watch values") {
                margin = SPACING,
                margin_bottom = 0
            };
            var watch_values_button_has_focus_handler_id =
                watch_values_button.notify["has-focus"].connect (() =>
            {
                if (watch_values_button.has_focus)
                    vscroll.scroll_to_child (watch_values_button);
            });
            watch_values_button.pressed.connect (() => watch_values_selected ());
            vbox.add (watch_values_button);
            var set_mode_button = new Button.with_label ("Set mode") {
                margin = SPACING,
                margin_bottom = 0
            };
            var set_mode_button_has_focus_handler_id =
                set_mode_button.notify["has-focus"].connect (() =>
            {
                if (set_mode_button.has_focus)
                    vscroll.scroll_to_child (set_mode_button);
            });
            set_mode_button.pressed.connect (() => set_mode_selected ());
            vbox.add (set_mode_button);
            if (supports_commands) {
                var send_command_button = new Button.with_label ("Send command") {
                    margin = SPACING
                };
                var send_command_button_has_focus_handler_id =
                    send_command_button.notify["has-focus"].connect (() =>
                {
                    if (send_command_button.has_focus)
                        vscroll.scroll_to_child (send_command_button);
                });
                send_command_button.pressed.connect (() => send_command_selected ());
                vbox.add (send_command_button);
                weak_ref (() => send_command_button.disconnect (send_command_button_has_focus_handler_id));
            }

            // Workaround vala bug where the lambdas reference "this" and cause
            // a reference cycle.
            unref ();
            weak_ref (() => {
                ref ();
                device_name_label.disconnect (device_name_label_has_focus_handler_id);
                watch_values_button.disconnect (watch_values_button_has_focus_handler_id);
                set_mode_button.disconnect (set_mode_button_has_focus_handler_id);
            });
        }
    }
}
