/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
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
 * BatteryStatusBarItem.vala:
 *
 * Indicates battery status
 */

using M2tk;
using U8g;

namespace BrickDisplayManager {
    public class BatteryStatusBarItem : StatusBarItem {
        const ushort END_WIDTH = 2;
        const ushort END_OFFEST = 2;
        const ushort PADDING = 1;
        const ushort TOP = 5;
        static unowned Font font = Font.dsg4_04b_03b;

        string _text = "ERR";

        double _voltage;
        public double voltage {
            get { return _voltage; }
            set {
                _voltage = value;
                if (voltage >= 10)
                    _text = "%.1f".printf(value);
                else
                    _text = "%.2f".printf(value);
                dirty = true;
            }
        }

        public override ushort draw(Graphics u8g, ushort x, StatusBar.Align align) {
            u8g.set_font(font);
            var main_width = u8g.get_string_width(_text) + PADDING * 2 + 2;
            var total_width = main_width + END_WIDTH;
            if (align ==  StatusBar.Align.RIGHT)
                x -= total_width - 1;
            u8g.draw_frame(x, TOP, main_width, HEIGHT);
            u8g.draw_box(x + main_width, TOP + END_OFFEST,
                END_WIDTH, HEIGHT - END_OFFEST * 2);
            u8g.draw_str(x + 1 + PADDING, TOP + HEIGHT - 2, _text);
            return total_width;
        }
    }
}
