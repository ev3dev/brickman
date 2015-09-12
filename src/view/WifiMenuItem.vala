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
 * WifiMenuItem.vala: Custom MenuItem for showing Wi-Fi connections.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public enum WifiSecurity {
        OPEN,
        SECURED,
        WPS
    }

    public class WifiMenuItem : Ui.MenuItem {
        Box hbox;
        Label connected_label;
        Ui.Icon secure_icon;
        Ui.Icon wps_icon;
        SignalBars signal_bars;

        public bool connected {
            get { return connected_label.visible; }
            set { connected_label.visible = value; }
        }

        public string connection_name {
            get { return label.text; }
            set { label.text = value; }
        }

        WifiSecurity _security;
        public WifiSecurity security {
            get { return _security; }
            set {
                _security = value;
                if (secure_icon != null) {
                    if (_security == WifiSecurity.SECURED)
                        hbox.insert_before (secure_icon, signal_bars);
                    else
                        hbox.remove (secure_icon);
                }
                if (wps_icon != null) {
                    if (_security == WifiSecurity.WPS)
                        hbox.insert_before (wps_icon, signal_bars);
                    else
                        hbox.remove (wps_icon);
                }
            }
        }

        public int signal_strength {
            get { return signal_bars.strength; }
            set { signal_bars.strength = value; }
        }

        public WifiMenuItem () {
            base.with_button (new Button () {
                padding_top = 1,
                padding_bottom = 1
            }, new Label () {
                text_horizontal_align = Grx.TextHorizAlign.LEFT
            });
            button.pressed.connect (on_button_pressed);
            hbox = new Box.horizontal ();
            button.add (hbox);
            connected_label = new Label ("*") {
                horizontal_align = WidgetAlign.START,
                visible = false
            };
            hbox.add (connected_label);
            hbox.add (label);
            try {
                secure_icon = new Ui.Icon.from_stock (StockIcon.LOCK_7X9) {
                    horizontal_align = WidgetAlign.END,
                    vertical_align = WidgetAlign.CENTER
                };
                wps_icon = new Ui.Icon.from_stock (StockIcon.WPS_9X9) {
                    horizontal_align = WidgetAlign.END,
                    vertical_align = WidgetAlign.CENTER
                };
            } catch (Error err) {
                critical ("%s", err.message);
            }
            signal_bars = new SignalBars () {
                horizontal_align = WidgetAlign.END,
                vertical_align = WidgetAlign.CENTER
            };
            hbox.add (signal_bars);
        }

        void on_button_pressed () {
            if (menu == null)
                return;
            var wifi_window = menu.window as WifiWindow;
            if (wifi_window == null)
                return;
            wifi_window.connection_selected (represented_object);
        }
    }
}
