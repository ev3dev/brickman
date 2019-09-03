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
 * BatteryStatusBarItem.vala:
 *
 * Indicates battery status
 */

using Ev3devKit.Ui;
using Grx;

namespace BrickManager {
    public class BatteryStatusBarItem : StatusBarItem {
        const ushort END_WIDTH = 2;
        const ushort END_OFFSET = 2;
        const ushort PADDING = 1;
        const ushort TOP = 3;
        static Font font;

        static construct {
            try {
                font =  Font.load ("fixed sans", 4);
            } catch (GLib.Error err) {
                critical ("%s", err.message);
            }
        }

        string _text = "???";
        TextOptions text_options;

        double _voltage;
        public double voltage {
            get { return _voltage; }
            set {
                if (_voltage == value)
                    return;
                _voltage = value;
                if (voltage >= 10)
                    _text = "%.1f".printf (value);
                else
                    _text = "%.2f".printf (value);
                redraw ();
            }
        }

        public BatteryStatusBarItem () {
            text_options = new TextOptions (BatteryStatusBarItem.font, Color.NONE, Color.NONE);
        }

        public override int draw (int x, StatusBar.Align align) {
            var color = status_bar.screen.fg_color;
            text_options.fg_color = color;
            var main_width = text_options.font.get_text_width (_text) + PADDING * 2 + 2;
            var total_width = main_width + END_WIDTH;
            if (align ==  StatusBar.Align.RIGHT)
                x -= total_width - 1;
            draw_box (x, TOP, x + main_width - 1, HEIGHT - TOP, color);
            draw_filled_box (x + main_width, TOP + END_OFFSET,
                x + main_width + END_WIDTH - 1, HEIGHT - TOP - END_OFFSET,
                color);
            draw_text (_text, x + PADDING, TOP + 1 + PADDING, text_options);
            return total_width;
        }
    }
}
