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
 * GVList.vala:
 *
 * wrapper for m2tk VLIST
 */

namespace M2tk {
    public class GVList : M2tk.GElement {
        PtrArray list = new PtrArray.sized(uint8.MAX);
        VList vlist { get { return (VList)element; } }

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

        public GVList() {
            element = VList.create({});
            base(element);
            vlist.list = (Element*)list.pdata;
            vlist.length = 0;
        }

        public void add(GElement element) {
            list.add(element.element);
            vlist.length = (uint8)list.len;
            // TODO: set dirty
        }
    }
}
