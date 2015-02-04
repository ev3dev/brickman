/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 WasabiFan <wasabifan@outlook.com>
 *
 * based on BatteryStatusBarItem.vala
 *   Copyright (C) 2014 David Lechner <david@lechnology.com>
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
 * NetworkStatusBarItem.vala:
 *
 * Indicates network IP address in status bar
 */

using EV3devKit.UI;
using GRX;

namespace BrickManager {
    public class NetworkStatusBarItem : StatusBarItem {
        const ushort TOP = 2;
        static Font font;

        static construct {
            font =  Font.load ("xm6x8");
        }

        string _text = "";
        TextOption text_option;

        public string text {
            get { return _text; }
            set {
                _text = value;
                redraw();
            }
        }

        public NetworkStatusBarItem () {
            text_option = new TextOption () {
                font = NetworkStatusBarItem.font,
                bg_color = Color.no_color
            };
        }

        public override int draw (int x, StatusBar.Align align) {
            var color = status_bar.screen.fg_color;
            text_option.fg_color = color;
            var main_width = text_option.vala_string_width(_text) + 2;

            draw_vala_string (_text, x + 1, TOP, text_option);
            return main_width;
        }
    }
}
