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
 * NetworkConnectionMenuItem.vala: Custom MenuItem for showing network connection status.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class NetworkConnectionMenuItem : Ui.MenuItem {
        Label connected_label;

        public bool connected {
            get { return connected_label.visible; }
            set { connected_label.visible = value; }
        }

        public string connection_name {
            get { return label.text; }
            set { label.text = value; }
        }

        public NetworkConnectionMenuItem (string png_file) {
            base.with_button (new Button () {
                padding_top = 1,
                padding_bottom = 2
            }, new Label () {
                text_horizontal_align = Grx.TextHorizAlign.LEFT
            });
            button.pressed.connect (on_button_pressed);
            var hbox = new Box.horizontal ();
            button.add (hbox);
            connected_label = new Label ("*") {
                horizontal_align = WidgetAlign.START,
                visible = false
            };
            hbox.add (connected_label);
            hbox.add (label);
            try {
                var icon = new Ev3devKit.Ui.Icon.from_png (png_file) {
                    horizontal_align = WidgetAlign.END,
                    vertical_align = WidgetAlign.CENTER
                };
                hbox.add (icon);
            } catch (Error err) {
                critical ("%s", err.message);
            }
        }

        void on_button_pressed () {
            if (menu == null)
                return;
            var network_connections_window = menu.window as NetworkConnectionsWindow;
            if (network_connections_window == null)
                return;
            network_connections_window.connection_selected (represented_object);
        }
    }
}
