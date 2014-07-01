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
 * GStrList.vala:
 *
 * wrapper for m2tk STRLIST
 */

using Gee;

namespace M2tk {
    public class GStrList : M2tk.GElement {
        static GStrList element_func_string_list;

        StringList string_list { get { return (StringList)element; } }

        internal uint8 item_count = 0;
        internal uint8 top_item = 0;

        GStrItemList _item_list;
        public GStrItemList item_list { get { return _item_list; } }

        public uint8 extra_column_size {
            get { return _extra_column_size; }
            set {
                _extra_column_size = value;
                update_format ();
            }
        }

        public FontSpec extra_column_font {
            get { return _extra_column_font; }
            set {
                _extra_column_font = value;
                update_format();
            }
        }

        public uint8 visible_line_count {
            get { return _visible_line_count; }
            set {
                _visible_line_count = value;
                update_format ();
            }
        }

        public signal void about_to_show (GStrList str_list);

        public GStrList(uint8 width) {
            set_element(StringList.create ((StringListFunc)on_get_str, ref item_count, ref top_item));
            _item_list = new GStrItemList (this);
            this.width = width;
            string_list.func = (ElementFunc)hook_func;
        }

        internal void update_list () {
            item_count = (uint8)item_list.size;
            dirty = true;
        }

        static string on_get_str (uint8 index, StringListFuncMessage msg) {
            switch (msg) {
            case StringListFuncMessage.GET_STR:
                return element_func_string_list.item_list[index].text ?? "";
            case StringListFuncMessage.SELECT:
                element_func_string_list.item_list[index].selected (index, element_func_string_list.item_list[index]);
                break;
            case StringListFuncMessage.GET_EXTENDED_STR:
                return element_func_string_list.item_list[index].extended_text ?? "";
            case StringListFuncMessage.NEW_DIALOG:
                element_func_string_list.about_to_show (element_func_string_list);
                break;
            }
            return "";
        }

        static uint8 hook_func (ElementFuncArgs arg) {
            unowned StringList string_list = (StringList)arg.element;
            element_func_string_list = (GStrList)element_map[string_list];
            string_list.func = (ElementFunc)StringList.Func;
            var result = string_list.func (arg);
            string_list.func = (ElementFunc)hook_func;
            return result;
        }
    }
}
