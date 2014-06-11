/*
 * m2tk-glib -- GLib bindings for m2tklib graphical toolkit
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
 * GFontList.vala:
 *
 * List of fonts used for indexed property
 */

namespace M2tk {
    public class GFontList {
        unowned M2 m2;

        public U8g.Font get(uint index) {
            return m2.get_font(index);
        }

        public void set(uint index, U8g.Font font) {
            m2.set_font(index, font);
        }

        public uint size { get { return 4; } }

        public GFontList(M2 m2) {
            this.m2 = m2;
        }
    }
}
