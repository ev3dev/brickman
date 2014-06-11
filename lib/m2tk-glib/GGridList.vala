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
 * GGridList.vala:
 *
 * wrapper for m2tk GRIDLIST
 */

namespace M2tk {
    public class GGridList : M2tk.GListElement {
        public uint8 column_count {
            get { return _column_count; }
            set {
                _column_count = value;
                update_format();
            }
        }

        public GGridList(uint8 column_count) {
            base(GridList.create({}));
            this.column_count = column_count;
        }
    }
}
