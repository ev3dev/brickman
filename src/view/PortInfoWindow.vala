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
 * PortInfoWindow.vala: Main Device Browser Menu
 */

using Ev3devKit.Ui;

namespace BrickManager {
    public class PortInfoWindow : BrickManagerWindow {
        const int SPACING = 4;

        Scroll vscroll;
        Box scroll_vbox;
        Label mode_value_label;
        Label status_value_label;
        Button set_device_button;
        Button set_mode_button;

        public string mode {
            get { return mode_value_label.text; }
            set { mode_value_label.text = value; }
        }

        public string status {
            get { return status_value_label.text; }
            set { status_value_label.text = value; }
        }

        bool _can_set_device;
        public bool can_set_device {
            get { return _can_set_device; }
            set {
                if (value && set_device_button.parent == null) {
                    scroll_vbox.insert_before (set_device_button, set_mode_button);
                    if (set_mode_button.has_focus) {
                        vscroll.scroll_to_child (set_mode_button);
                    }
                } else if (!value) {
                    if (set_device_button.has_focus)
                        set_mode_button.focus ();
                    scroll_vbox.remove (set_device_button);
                }
                _can_set_device = value;
            }
        }

        public signal void set_mode_button_pressed ();
        public signal void set_device_button_pressed ();

        public PortInfoWindow (string address, string device_name, string driver_name) {
            title = address;
            vscroll = new Scroll.vertical () {
                margin_top = -3,
                can_focus = false
            };
            content_vbox.add (vscroll);
            scroll_vbox = new Box.vertical ();
            vscroll.add (scroll_vbox);
            var device_name_label = new Label ("Device name:") {
                margin_top = SPACING,
                can_focus = true
            };
            var device_name_label_has_focus_handler_id =
                device_name_label.notify["has-focus"].connect (() =>
            {
                if (device_name_label.has_focus)
                    vscroll.scroll_to_child (device_name_label);
            });
            scroll_vbox.add (device_name_label);
            var device_name_value_label = new Label (device_name);
            scroll_vbox.add (device_name_value_label);
            var driver_name_label = new Label ("Driver name:") {
                margin_top = SPACING
            };
            scroll_vbox.add (driver_name_label);
            var driver_name_value_label = new Label (driver_name);
            scroll_vbox.add (driver_name_value_label);
            var mode_label = new Label ("Mode:") {
                margin_top = SPACING
            };
            scroll_vbox.add (mode_label);
            mode_value_label = new Label ("???");
            scroll_vbox.add (mode_value_label);
            var status_label = new Label ("Status:") {
                margin_top = SPACING
            };
            scroll_vbox.add (status_label);
            status_value_label = new Label ("???");
            scroll_vbox.add (status_value_label);
            set_device_button = new Button.with_label ("Set device") {
                margin = SPACING,
                margin_bottom = 0
            };
            set_device_button.notify["has-focus"].connect (() => {
                if (set_device_button.has_focus)
                    vscroll.scroll_to_child (set_device_button);
            });
            set_device_button.pressed.connect (() => set_device_button_pressed ());
            // don't add set_device_button - see can_set_device property
            set_mode_button = new Button.with_label ("Set mode") {
                margin = SPACING
            };
            set_mode_button.notify["has-focus"].connect (() => {
                if (set_mode_button.has_focus)
                    vscroll.scroll_to_child (set_mode_button);
            });
            set_mode_button.pressed.connect (() => set_mode_button_pressed ());
            scroll_vbox.add (set_mode_button);

            // Workaround vala bug where the lambdas reference "this" and cause
            // a reference cycle.
            unref ();
            weak_ref (() => {
                ref ();
                device_name_label.disconnect (device_name_label_has_focus_handler_id);
            });
        }
    }
}
