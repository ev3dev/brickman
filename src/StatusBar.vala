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
 * StatusBar.vala:
 *
 * The brickdm status bar. Contains info like battery status, wi-fi
 * status, bluetooth status, etc.
 */

using Gee;
using U8g;

namespace BrickDisplayManager {
    public class StatusBar : Object {
        public const ushort HEIGHT = 13;
        const ushort PADDING = 2;

        ArrayList<StatusBarItem> left_items;
        ArrayList<StatusBarItem> right_items;

        public bool visible { get; set; default = true; }

        bool _dirty = true;
        public bool dirty {
            get {
                if (_dirty)
                    return true;
                foreach (var item in left_items) {
                    if (item.dirty)
                        return true;
                }
                foreach (var item in right_items) {
                    if (item.dirty)
                        return true;
                }
                return false;
            }
            set {
                _dirty = value;
                if (value)
                    return;
                foreach (var item in left_items)
                    item.dirty = false;
                foreach (var item in right_items)
                    item.dirty = false;
            }
        }

        public void draw(Graphics u8g) {
            u8g.set_default_background_color();
            u8g.set_default_forground_color();
            var x = 0;
            foreach (var item in left_items)
                x += item.draw(u8g, x, Align.LEFT) + PADDING;
            x = u8g.width - 1;
            foreach (var item in right_items)
                x -= item.draw(u8g, x, Align.RIGHT) + PADDING;
            u8g.draw_line(0, 15, u8g.width, 15);
        }

        public void add_left(StatusBarItem item) {
            left_items.add(item);
        }

        public void add_right(StatusBarItem item) {
            right_items.add(item);
        }

        public StatusBar() {
            left_items = new ArrayList<StatusBarItem>();
            right_items = new ArrayList<StatusBarItem>();
        }

        public enum Align {
            LEFT, RIGHT
        }
    }
}
