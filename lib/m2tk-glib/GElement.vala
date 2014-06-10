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
        protected static HashMap<unowned Element, weak GElement> element_map;

        static construct {
            element_map = new HashMap<unowned Element, weak GElement>();
        }

        /* format */
        protected bool? _plus_visible;
        protected bool? _auto_down_select;
        protected bool? _vertical_padding; // border
        protected uint8? _column_count;
        protected uint8? _extra_column_size;
        protected FontSpec _extra_column_font;
        protected FontSpec _font;
        protected uint8? _height;
        protected uint8? _visible_line_count;
        protected uint8? _inital_focus_field;
        protected bool? _read_only;
        protected uint8? _value;
        protected uint8? _width;
        protected uint8? _x;
        protected uint8? _y;
        protected HorizontalAlignment _horizontal_alignment;
        protected VerticalAlignment _vertical_alignment;
        protected uint8? _decimal_position;

        protected Element element;
        string format;

        protected GElement(Element element) {
            element_map[element] = this;
        }

        protected void update_format() {
            var builder = new StringBuilder();
            if (_plus_visible != null)
                builder.append("+%d".printf((bool)_plus_visible ? 1 : 0));
            if (_auto_down_select != null)
                builder.append("a%d".printf((bool)_auto_down_select ? 1 : 0));
            if (_vertical_padding != null)
                builder.append("b%d".printf((bool)_vertical_padding ? 1 : 0));
            if (_column_count != null)
                builder.append("c%d".printf((int)_column_count));
            if (_extra_column_size != null)
                builder.append("e%d".printf((int)_extra_column_size));
            if (_extra_column_font != FontSpec.F0)
                builder.append("F%d".printf(_extra_column_font));
            if (_font != FontSpec.F0)
                builder.append("f%d".printf(_font));
            if (_height != null)
                builder.append("h%d".printf((int)_height));
            if (_visible_line_count != null)
                builder.append("l%d".printf((int)_visible_line_count));
            if (_inital_focus_field != null)
                builder.append("n%d".printf((int)_inital_focus_field));
            if (_read_only != null)
                builder.append("r%d".printf((bool)_read_only ? 1 : 0));
            if (_value != null)
                builder.append("v%d".printf((int)_value));
            if (_width != null)
                builder.append("w%d".printf((int)_width));
            if (_x != null)
                builder.append("x%d".printf((int)_x));
            if (_y != null)
                builder.append("y%d".printf((int)_y));
            if (_horizontal_alignment != HorizontalAlignment.LEFT)
                builder.append("-%d".printf(_horizontal_alignment));
            if (_vertical_alignment != VerticalAlignment.BOTTOM)
                builder.append("|%d".printf(_vertical_alignment));
            if (_decimal_position != null)
                builder.append(".%d".printf((int)_decimal_position));
            format = builder.str;
            element.format = format;
        }
    }
}
