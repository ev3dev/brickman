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
 * StatusBar.vala:
 *
 * The brickman status bar. Contains info like battery status, wi-fi
 * status, bluetooth status, etc.
 */

using Gee;
using GRX;

namespace BrickManager {
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

        public void draw (Context context) {
            var x = 0;
            foreach (var item in left_items)
                x += item.draw (context, x, Align.LEFT) + PADDING;
            x = context.width - 1;
            foreach (var item in right_items)
                x -= item.draw (context, x, Align.RIGHT) + PADDING;
            line (0, HEIGHT, context.width, HEIGHT, Color.black);
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
