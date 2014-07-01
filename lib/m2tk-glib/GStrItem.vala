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
 * GStrItem.vala:
 *
 * List items used by GStrList
 */

namespace M2tk {
    public class GStrItem : Object {
        public string text { get; set; }
        public string? extended_text { get; set; }
        public Object? user_data { get; set; }

        public signal void selected (uint8 index, GStrItem item);

        public GStrItem (string text, string? extended_text = null, Object? user_data = null) {
            this.text = text;
            this.extended_text = extended_text;
            this.user_data = user_data;
        }
    }
}
