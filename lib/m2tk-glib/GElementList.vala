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

using Gee;

namespace M2tk {
    public class GElementList : AbstractList<GElement> {
        GListElement parent;

        public override int size { get { return parent.child_list.length; } }

        public GElementList(GListElement parent) {
            base();
            this.parent = parent;
        }

        public override ListIterator<GElement> list_iterator() {
            return new GElementListIterator(parent);
        }

        public override GElement get(int index)
            requires (index >= 0 && index < size)
        {
            unowned Element element = parent.child_list[index];
            return GElement.element_map[element];
        }

        public override void set(int index, GElement item)
            requires (index >= 0)
        {
            if (index >= parent.child_list.length)
                parent.child_list.length = index;
            unowned Element? old_element = parent.child_list[index];
            if (old_element != null)
                GElement.element_map[(Element)old_element].unref();
            item.ref();
            parent.child_list[index] = item.element;
            parent.update_list();
        }

        public override int index_of(GElement item) {
            int index = 0;
            foreach (var element in this) {
                if (element == item)
                    return index;
                index++;
            }
            return -1;
        }

        public override void insert(int index, GElement item)
            requires (index >= 0)
        {
            item.ref();
            parent.child_list.insert(index, item.element);
            parent.update_list();
        }

        public override GElement remove_at(int index)
            requires (index >= 0 && index < size)
        {
            unowned Element element = parent.child_list[index];
            parent.child_list.remove_index((uint)index);
            var result = GElement.element_map[element];
            result.unref();
            return result;
        }

        public override Gee.List<GElement>? slice(int start, int stop)
            requires (start > -size && stop <= size
                && (start < stop || ((start >= 0 && start < (size - stop))
                    || (start < 0 && -start < stop))))
        {
            var result = new ArrayList<GElement>();
            if (start < 0)
                start = size - start;
            if (stop < 0)
                stop = size - stop;
            for (int i = start; i < stop; i++)
                result.add(this[i]);
            return result;
        }

        public override bool contains (GElement item) {
            return index_of(item) >= 0;
        }

        public override bool add(GElement item) {
            item.ref();
            parent.child_list.add(item.element);
            parent.update_list();
            return true;
        }

        public override bool remove(GElement item) {
            var result = parent.child_list.remove(item.element);
            if (result) {
                item.unref();
                parent.update_list();
            }
            return result;
        }

        public override void clear() {
            foreach(var element in this)
                element.unref();
            parent.child_list.length = 0;
            parent.update_list();
        }

        public override Iterator<GElement> iterator() {
            return new GElementListIterator(parent);
        }

        class GElementListIterator : Object, Iterator<GElement>,
            BidirIterator<GElement>, ListIterator<GElement>
        {
            GListElement parent;
            int position = 0;

            public bool valid { get { return parent != null; } }

            public bool read_only { get { return false; } }

            public GElementListIterator(GListElement parent) {
                this.parent = parent;
            }

            public void insert(GElement item) {
                item.ref();
                position--;
                parent.child_list.insert(position, item.element);
                parent.update_list();
            }

            public new void @set(GElement item) {
                unowned Element old_element = parent.child_list[position];
                GElement.element_map[old_element].unref();
                item.ref();
                parent.child_list[position] = item.element;
                parent.update_list();
            }

            public void add(GElement item) {
                item.ref();
                position++;
                parent.child_list.insert(position, item.element);
                parent.update_list();
            }

            public int index() {
                return position;
            }

            public bool previous() {
                position--;
                return has_previous();
            }

            public bool has_previous() {
                return position > 0;
            }

            public bool first() {
                position = 0;
                return parent.child_list.length > 0;
            }

            public bool last() {
                position = parent.child_list.length - 1;
                return parent.child_list.length > 0;
            }

            public bool next() {
                position++;
                return has_next();
            }

            public bool has_next() {
                return position < parent.child_list.length - 1;
            }

            public new GElement @get() {
                unowned Element element = parent.child_list[position];
                return GElement.element_map[element];
            }

            public void remove() {
                unowned Element? element = parent.child_list[position];
                parent.child_list.remove_index(position);
                if (element != null) {
                    GElement.element_map[element].unref();
                    parent.update_list();
                }
            }
        }
    }
}
