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
 * SignalBars.vala: Widget for indicating signal strength using bars like a mobile phone.
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public class SignalBars : Widget {
        const int MAX_BARS = 4;
        const int BAR_WIDTH = 2;
        const int WIDTH = MAX_BARS * BAR_WIDTH;
        const int HEIGHT = MAX_BARS * BAR_WIDTH;

        public int strength { get; set; }

        public int max_strength { get; set; default = 100; }

        construct {
            margin = 1;
            notify["strength"].connect (redraw);
            notify["max_strength"].connect (redraw);
        }

        protected override int get_preferred_width () {
            return WIDTH + get_margin_border_padding_width ();
        }

        protected override int get_preferred_height () {
            return HEIGHT + get_margin_border_padding_height ();
        }

        protected override void draw_content () {
            var one_bar = (max_strength + MAX_BARS - 1) / MAX_BARS;
            var bars = (strength + one_bar - 1) / one_bar;
            GRX.Color color = window.screen.fg_color;
            if (parent.draw_children_as_focused)
                color = window.screen.bg_color;
            for (int i = 0; i < bars; i++) {
                GRX.filled_box (content_bounds.x1 + BAR_WIDTH * i,
                    content_bounds.y2 - BAR_WIDTH * (i + 1),
                    content_bounds.x1 + BAR_WIDTH * (i + 1),
                    content_bounds.y2, color);
            }
        }
    }
}
