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
    public class GStrList : M2tk.GScrollable, M2tk.GElement {
        static VirtStringLine2 virt_string_line_2;

        static construct {
            virt_string_line_2 = VirtStringLine2.create ();
        }

        StringList string_list { get { return (StringList)element; } }

        uint8 _item_count = 0;
        public uchar item_count {
            get { return _item_count; }
            set {
                _item_count = value;
                dirty = true;
            }
        }
        uint8 old_top_item = 0;
        uint8 _top_item = 0;
        public uchar top_item {
            get { return _top_item; }
            set {
                _top_item = value;
                dirty = true;
            }
        }

        GStrItemList _item_list;
        public GStrItemList item_list { get { return _item_list; } }

        public uchar extra_column_width {
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

        public uchar visible_line_count {
            get { return _visible_line_count; }
            set {
                _visible_line_count = value;
                update_format ();
            }
        }

        // This does not work properly.
        // TODO: Need to override StringListBase.show
        bool _use_extra_column_font_for_height = false;
        public bool use_extra_column_font_for_height {
            get { return _use_extra_column_font_for_height; }
            set {
                _use_extra_column_font_for_height = value;
                dirty = true;
            }
        }

        public signal void about_to_show (GStrList str_list);

        public GStrList(uint8 width) {
            set_element(StringList.create ((StringListFunc)on_get_str,
                ref _item_count, ref _top_item));
            _item_list = new GStrItemList (this);
            this.width = width;
            string_list.func = (ElementFunc)hook_func;
        }

        internal void update_list () {
            item_count = (uint8)item_list.size;
            if (item_count <= visible_line_count)
                top_item = 0;
            dirty = true;
        }

        static string on_get_str (uchar index, StringListFuncMessage msg) {
            // this is not actually used since we are overriding everything
            // from the hook_func
            return "";
        }

        static uint8 hook_func (ElementFuncArgs arg) {
            unowned StringList string_list = (StringList)arg.element;
            var gstrlist = (GStrList)element_map[string_list];
            uint8 result;
            switch (arg.msg) {
            case ElementMessage.GET_LIST_ELEMENT:
                Element.MallocStruct **ptr = arg.data;
                *ptr = virt_string_line_2;
                result = 1;
                break;
            case ElementMessage.GET_HEIGHT:
                if (gstrlist.use_extra_column_font_for_height)
                    result = GraphicsUtil.get_char_height_with_normal_border(gstrlist.extra_column_font);
                else
                    result = GraphicsUtil.get_char_height_with_normal_border(string_list.font);
                result *= gstrlist.visible_line_count;
                result = VList.calc_height_overlap_correction(result, gstrlist.visible_line_count);
                break;
            case ElementMessage.NEW_DIALOG:
                gstrlist.about_to_show (gstrlist);
                result = 0;
                break;
            default:
                string_list.func = (ElementFunc)StringList.Func;
                result = string_list.func (arg);
                string_list.func = (ElementFunc)hook_func;
                break;
            }
            if (gstrlist.top_item != gstrlist.old_top_item) {
                gstrlist.notify_property ("top-item");
                gstrlist.old_top_item = gstrlist.top_item;
            }
            return result;
        }
    }

    [CCode (cname = "m2_el_fnfmt_t", free_function = "g_free", has_type_id = false)]
    class VirtStringLine2 : Element {
        static bool has_extra_column (Element parent_element) {
            return Option.get_value (parent_element.format, 'e') != Option.NOT_FOUND ||
                Option.get_value (parent_element.format, 'E') != Option.NOT_FOUND;
        }

        static uint8 Func (ElementFuncArgs arg) {
            unowned StringList parent_element = (StringList)arg.nav.parent_element;
            GStrList gstrlist = (GStrList)GElement.element_map[parent_element];
            uint8 font = arg.nav.parent_get_font ();
            uint8 pos = arg.nav.child_pos;

            switch (arg.msg) {
            case ElementMessage.GET_LIST_LEN:
                return 0;  /* not a list, return 0 */
            case ElementMessage.GET_HEIGHT:
                // This does not seem to ever get called
                return GraphicsUtil.get_char_height_with_normal_border(font);
            case ElementMessage.GET_WIDTH:
                /* width is defined only by the eE and wW options */
                return parent_element.calc_width ();
            case ElementMessage.GET_OPT:
                if ( arg.arg == 't' ) {
                    /* child is touch sensitive if the parent is touch sensitive */
                    *(uint8 *)(arg.data) = parent_element.get_option_value_with_default (arg.arg, 0);
                    return 1;
                }
                break;
            case ElementMessage.NEW_FOCUS:
                /* adjust the top value, if required */
                parent_element.adjust_top_to_focus (pos);
                return 1;
            case ElementMessage.SELECT:
                if (pos < gstrlist.item_list.size)
                    gstrlist.item_list[pos].selected (pos, gstrlist.item_list[pos]);
                return 1;
            case ElementMessage.SHOW:
                string? extra_text = null;
                if (has_extra_column (parent_element))
                    extra_text = gstrlist.item_list[pos].extended_text ?? "";
                var text = gstrlist.item_list[pos].text ?? "";
                StringListBase.show (arg, extra_text, text);
              return 1;
          }
          return 0;
        }

        [CCode (cname = "g_malloc0")]
        VirtStringLine2(size_t size = sizeof(Element.MallocStruct))
            requires (size == sizeof(Element.MallocStruct));

        public static VirtStringLine2 create () {
            var element = new VirtStringLine2 ();
            element.func = (ElementFunc)Func;
            return element;
        }
    }
}
