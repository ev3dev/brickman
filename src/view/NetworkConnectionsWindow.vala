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
 * NetworkConnectionsWindow.vala:
 *
 * Displays list of network connections.
 */

using Gee;
using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    class NetworkConnectionsWindow : BrickManagerWindow {
        internal UI.Menu menu;
        Button scan_wifi_button;

        public bool has_wifi { get; set; }
        public bool scan_wifi_busy { get; set; }

        public signal void scan_wifi_selected ();
        public signal void connection_selected (Object user_data);

        public NetworkConnectionsWindow () {
            title = "Network Connections";
            scan_wifi_button = new Button.with_label ("Scan WiFi", small_font) {
                horizontal_align = WidgetAlign.START,
                vertical_align = WidgetAlign.START,
                margin_top = -4,
                margin_bottom = -1,
                margin_left = 3,
                padding_top = -2
            };
            scan_wifi_button.pressed.connect (() => {
                if (!_scan_wifi_busy)
                    scan_wifi_selected ();
            });
            notify["has-wifi"].connect (() => {
                if (_has_wifi)
                    content_vbox.insert_before (scan_wifi_button, menu);
                else
                    content_vbox.remove (scan_wifi_button);
            });
            notify["scan-wifi-busy"].connect (() => {
                if (_scan_wifi_busy)
                    ((Label)scan_wifi_button.child).text = "Scanning";
                else
                    ((Label)scan_wifi_button.child).text = "Scan WiFi";
            });
            menu = new UI.Menu () {
                spacing = 2
            };
            content_vbox.add (menu);
        }
    }
}
