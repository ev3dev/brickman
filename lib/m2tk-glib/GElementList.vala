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
 * GElementList.vala:
 *
 * List of elements used for indexed property
 */

namespace M2tk {
    public class GElementList {
        GListElement parent;

        public GElement get(uint index) requires (index < size)
        {
            unowned Element element = (Element)parent.child_list.index(index);
            return GElement.element_map[element];
        }

        public uint size { get { return parent.child_list.len; } }

        public GElementList(GListElement parent) {
            this.parent = parent;
        }
    }
}
