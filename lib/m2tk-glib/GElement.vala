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
 * GElement.vala:
 *
 * Base class for m2tk elements
 */

using Gee;

namespace M2tk {

    public enum VerticalAlignment {
        BOTTOM = 0,
        MIDDLE = 1,
        TOP = 2
    }

    public enum HorizontalAlignment {
        LEFT = 0,
        CENTER = 1,
        RIGHT = 2
    }

    public abstract class GElement : Object {
        internal static HashMap<unowned Element, weak GElement> element_map;

        static GNullElement _null_element;
        public static GNullElement null_element {
            get {
                if (_null_element == null)
                    _null_element = new GNullElement();
                return _null_element;
            }
        }

        static construct {
            element_map = new HashMap<unowned Element, weak GElement>();
        }

        /* format properties */

        string format;

        uint8 _x = uint8.MAX;
        public uint8 x {
            get { return _x; }
            set {
                _x = value;
                update_format();
            }
        }

        uint8 _y = uint8.MAX;
        public uint8 y {
            get { return _y; }
            set {
                _y = value;
                update_format();
            }
        }

        uint8 _width = uint8.MAX;
        public uint8 width {
            get { return _width; }
            set {
                _width = value;
                update_format();
            }
        }

        uint8 _height = uint8.MAX;
        public uint8 height {
            get { return _height; }
            set {
                _height = value;
                update_format();
            }
        }

        bool _read_only;
        public bool read_only {
            get { return _read_only; }
            set {
                _read_only = value;
                update_format();
            }
        }

        FontSpec _font = FontSpec.DEFAULT;
        public FontSpec font {
            get { return _font; }
            set {
                _font = value;
                update_format();
            }
        }

        // these format specifiers are not available on all elements
        protected bool _plus_visible;
        protected bool _auto_down_select;
        protected bool _vertical_padding; // border
        protected uint8 _column_count;
        protected uint8 _extra_column_size;
        protected FontSpec _extra_column_font = FontSpec.DEFAULT;
        protected uint8 _visible_line_count;
        protected uint8 _inital_focus_field;
        protected uint8 _value;
        protected HorizontalAlignment _horizontal_alignment;
        protected VerticalAlignment _vertical_alignment;
        protected uint8 _decimal_position;

        /* other properties */

        public uint8 actual_width { get { return element.width; } }
        public uint8 actual_height { get { return element.height; } }
        public virtual bool is_dirty { get; set; default = true; }

        Element _element;
        public unowned Element element {
            get {
                if (_element == null)
                    return M2tk.null_element;
                return _element;
                }
            }

        protected GElement(owned Element element) {
            _element = (owned)element;
            element_map[_element] = this;
        }

        protected GElement.null() {
            element_map[M2tk.null_element] = this;
        }

        ~GElement() {
            element_map.unset(_element);
        }

        protected void update_format() {
            var builder = new StringBuilder();
            if (_plus_visible)
                builder.append("+1");
            if (_auto_down_select)
                builder.append("a1");
            if (_vertical_padding)
                builder.append("b1");
            if (_column_count != 0)
                builder.append("c%d".printf((int)_column_count));
            if (_extra_column_size != 0)
                builder.append("e%d".printf((int)_extra_column_size));
            if (_extra_column_font != FontSpec.DEFAULT)
                builder.append("F%d".printf(_extra_column_font));
            if (_font != FontSpec.DEFAULT)
                builder.append("f%d".printf(_font));
            if (_height != uint8.MAX)
                builder.append("h%d".printf((int)_height));
            if (_visible_line_count != 0)
                builder.append("l%d".printf((int)_visible_line_count));
            if (_inital_focus_field != 0)
                builder.append("n%d".printf((int)_inital_focus_field));
            if (_read_only)
                builder.append("r1");
            if (_value != 0)
                builder.append("v%d".printf((int)_value));
            if (_width != uint8.MAX)
                builder.append("w%d".printf((int)_width));
            if (_x != uint8.MAX)
                builder.append("x%d".printf((int)_x));
            if (_y != uint8.MAX)
                builder.append("y%d".printf((int)_y));
            if (_horizontal_alignment != HorizontalAlignment.LEFT)
                builder.append("-%d".printf(_horizontal_alignment));
            if (_vertical_alignment != VerticalAlignment.BOTTOM)
                builder.append("|%d".printf(_vertical_alignment));
            if (_decimal_position != 0)
                builder.append(".%d".printf((int)_decimal_position));
            format = builder.str;
            element.format = format;
            is_dirty = true;
        }
    }
}
