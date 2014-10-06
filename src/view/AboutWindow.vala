/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * AboutWindow.vala - displays infomation about this program and the EV3 itself
 */

using EV3devKit;

namespace BrickManager {
    public class AboutWindow : BrickManagerWindow {
        Label kernel_label;
        Label eeprom_label;

        public string kernel_version {
            get { return kernel_label.text; }
            set { kernel_label.text = value; }
        }

        public string eeprom_version {
            get { return eeprom_label.text; }
            set { eeprom_label.text = value; }
        }

        public AboutWindow () {
            title = "About";
            content_vbox.add (new Label ("%s v%s".printf (EXEC_NAME, VERSION)));
            content_vbox.add (new Label ("The ev3dev Brick Manager"));
            content_vbox.add (new Label ("(C) 2014 David Lechner"));
            content_vbox.add (new Label ("System Info") {
                border_bottom = 1,
                padding_bottom = 3,
                margin_top = 6
            });
            var system_info_grid = new Grid (2, 2);
            content_vbox.add (system_info_grid);
            system_info_grid.add (new Label ("Kernel:") {
                horizontal_align = WidgetAlign.END,
                font = small_font,
                margin_right = 3
            });
            kernel_label = new Label ("???") {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            system_info_grid.add (kernel_label);
            system_info_grid.add (new Label ("EEPROM:") {
                horizontal_align = WidgetAlign.END,
                font = small_font,
                margin_right = 3
            });
            eeprom_label = new Label ("???") {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            system_info_grid.add (eeprom_label);
            content_vbox.add (new Spacer ());
        }
    }
}
