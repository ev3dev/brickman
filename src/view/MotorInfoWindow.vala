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
 * MotorInfoWindow.vala: Main Device Browser Menu
 */

using EV3devKit.UI;

namespace BrickManager {
    public class MotorInfoWindow : BrickManagerWindow {
        const int SPACING = 4;

        Label running_value_label;

        bool _running;
        public bool running {
            get { return _running; }
            set {
                running_value_label.text = value ? "yes" : "no";
                _running = value;
            }
        }

        public signal void watch_values_selected ();

        public MotorInfoWindow (string name, string class_name, string device_name,
            string port_name, bool show_watch_button)
        {
            title = name;
            var vscroll = new Scroll.vertical () {
                can_focus = false,
                margin_top = -3
            };
            content_vbox.add (vscroll);
            var vbox = new Box.vertical ();
            vscroll.add (vbox);

            var class_name_label = new Label ("Sysfs Class:") {
                margin_top = SPACING,
                can_focus = true
            };
            var class_name_label_has_focus_handler_id =
                class_name_label.notify["has-focus"].connect (() =>
            {
                if (class_name_label.has_focus)
                    vscroll.scroll_to_child (class_name_label);
            });
            vbox.add (class_name_label);
            var class_name_value_label = new Label (class_name);
            vbox.add (class_name_value_label);

            var device_name_label = new Label ("Device name:") {
                margin_top = SPACING
            };
            vbox.add (device_name_label);
            var device_name_value_label = new Label (device_name);
            vbox.add (device_name_value_label);

            var port_name_label = new Label ("Port name:") {
                margin_top = SPACING
            };
            vbox.add (port_name_label);
            var port_name_value_label = new Label (port_name);
            vbox.add (port_name_value_label);

            // TODO: driver needs notification support before making this visible
            //var running_label = new Label ("Running:") {
            //    margin_top = SPACING
            //};
            //vbox.add (running_label);
            running_value_label = new Label ("???");
            //vbox.add (running_value_label);

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
            if (show_watch_button) {
                vbox.add (watch_values_button);
            }

            // Workaround vala bug where the lambdas reference "this" and cause
            // a reference cycle.
            unref ();
            weak_ref (() => {
                ref ();
                class_name_label.disconnect (class_name_label_has_focus_handler_id);
                watch_values_button.disconnect (watch_values_button_has_focus_handler_id);
            });
        }
    }
}
