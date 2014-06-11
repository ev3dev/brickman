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
 * GListElement.vala:
 *
 * shared implementation for m2tk HLIST, VLIST, GRIDLIST and XYLIST
 */

namespace M2tk {
    public abstract class GListElement : M2tk.GElement {
        PtrArray child_list = new PtrArray.sized(uint8.MAX);
        ListElement list_element { get { return (ListElement)element; } }

        public uint8? x {
            get { return _x; }
            set {
                _x = value;
                update_format();
            }
        }

        public uint8? y {
            get { return _y; }
            set {
                _y = value;
                update_format();
            }
        }

        public GListElement(owned Element element) {
            base((owned)element);
            update_list();
        }

        public void add(GElement element) {
            child_list.add(element.element);
            update_list();
        }

        void update_list() {
            list_element.list = (Element*)child_list.pdata;
            list_element.length = (uint8)child_list.len;
            // TODO: set dirty
        }
    }
}
