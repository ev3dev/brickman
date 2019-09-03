/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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
 * AboutWindow.vala - displays information about this program and the EV3 itself
 */

using Ev3devKit.Ui;

namespace BrickManager {
    public class AboutWindow : BrickManagerWindow {
        Label kernel_label;
        Label model_label;
        Label revision_label;
        Label serial_number_label;

        public string kernel_version {
            get { return kernel_label.text; }
            set { kernel_label.text = value; }
        }

        public string model_name {
            get { return model_label.text; }
            set { model_label.text = value; }
        }

        public string revision {
            get { return revision_label.text; }
            set { revision_label.text = value; }
        }

        public string serial_number {
            get { return serial_number_label.text; }
            set { serial_number_label.text = value; }
        }

        public AboutWindow (string display_name) {
            title = display_name;
            var scroll = new Scroll.vertical ();
            content_vbox.add (scroll);

            var scroll_vbox = new Box.vertical ();
            scroll.add (scroll_vbox);

            scroll_vbox.add (new Label ("%s v%s".printf (EXEC_NAME, VERSION)));
            scroll_vbox.add (new Label ("The ev3dev Brick Manager"));
            scroll_vbox.add (new Label ("(C) 2014-2015 ev3dev.org"));
            scroll_vbox.add (new Label ("System Info") {
                border_bottom = 1,
                padding_bottom = 3,
                margin_top = 6
            });

            scroll_vbox.add (new Label ("Kernel:") {
                margin_top = 6
            });
            kernel_label = new Label ("???");
            scroll_vbox.add (kernel_label);

            scroll_vbox.add (new Label ("Model:") {
                margin_top = 6
            });
            model_label = new Label ("???");
            scroll_vbox.add (model_label);

            scroll_vbox.add (new Label ("Revision:") {
                margin_top = 6
            });
            revision_label = new Label ("???");
            scroll_vbox.add (revision_label);

            scroll_vbox.add (new Label ("Serial Number:") {
                margin_top = 6
            });
            serial_number_label = new Label ("???");
            scroll_vbox.add (serial_number_label);
        }
    }
}
