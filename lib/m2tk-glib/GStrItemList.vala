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
 * GStrItemList.vala:
 *
 * List of GStrItem used for indexed property
 */

using Gee;

namespace M2tk {
    public class GStrItemList : AbstractList<GStrItem> {
        GStrList parent;
        ArrayList<GStrItem> real_list;

        public override int size { get { return real_list.size; } }

        public GStrItemList (GStrList parent) {
            base();
            this.parent = parent;
            real_list = new ArrayList<GStrItem> ();
        }

        public override ListIterator<GStrItem> list_iterator () {
            return real_list.list_iterator ();
        }

        public override GStrItem get (int index) {
            return real_list[index];
        }

        public override void set (int index, GStrItem item) {
            real_list.set (index, item);
            item.notify.connect (on_item_notify);
            parent.update_list ();
        }

        public override int index_of (GStrItem item) {
            int index = 0;
            foreach (var element in this) {
                if (element == item)
                    return index;
                index++;
            }
            return -1;
        }

        public override void insert (int index, GStrItem item) {
            real_list.insert(index, item);
            item.notify.connect (on_item_notify);
            parent.update_list ();
        }

        public override GStrItem remove_at (int index) {
            var item = real_list.remove_at (index);
            item.notify.disconnect (on_item_notify);
            parent.update_list ();
            return item;
        }

        public override Gee.List<GStrItem>? slice (int start, int stop) {
            return real_list.slice (start, stop);
        }

        public override bool contains (GStrItem item) {
            return real_list.contains (item);
        }

        public override bool add (GStrItem item) {
            var result = real_list.add (item);
            item.notify.connect (on_item_notify);
            parent.update_list ();
            return result;
        }

        public override bool remove (GStrItem item) {
            var result = real_list.remove (item);
            if (result)
                item.notify.disconnect (on_item_notify);
                parent.update_list ();
            return result;
        }

        public override void clear () {
            real_list.clear ();
            parent.update_list ();
        }

        public override Iterator<GStrItem> iterator () {
            return real_list.iterator ();
        }

        void on_item_notify (ParamSpec pspec) {
            parent.dirty = true;
        }
    }
}
