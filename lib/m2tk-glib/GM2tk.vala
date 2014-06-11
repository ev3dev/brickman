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
 * GM2tk.vala:
 *
 * Wrapper for the global M2tk object
 */

using Gee;
using U8g;

[CCode (cheader_filename = "m2ghu8g.h")]
namespace M2tk {
     public class GM2tk : Object {
        static HashMap<unowned M2, weak GM2tk> m2_map;

        static construct {
            m2_map = new HashMap<unowned M2, weak GM2tk>();
        }

        static Graphics _u8g;
        public static unowned Graphics graphics {
            get {
                if (_u8g == null) {
                    _u8g = new Graphics();
                    _u8g.init(U8g.Device.linux_framebuffer);
                }
                return _u8g;
            }
        }

        M2 _m2;

        public GElement root {
            get { return GElement.element_map[_m2.root]; }
        }

        public GElement home {
            get { return GElement.element_map[_m2.home]; }
            set { _m2.home = value.element; }
        }

        public GElement home2 {
            get { return GElement.element_map[_m2.home2]; }
            set { _m2.home2 = value.element; }
        }

        public signal void root_element_changed(Element new_root,
            Element old_root, uint8 value);

        /**
         * Create new instance of GM2tk
         *
         * @param root_element The initial root element
         * @param event_source The event source function that provides event messages
         * @param event_handler The event handler function that processes events
         * @param graphics_handler The graphics handler function that draws the elements
         * @param icon_handler The graphics handler function that draws icons for
         *      check boxes and radio buttons.
         *      Note: This function is shared by all instances of GM2tk.
         */
        public GM2tk(GElement root_element, EventSourceFunc event_source,
            EventHandlerFunc event_handler, GraphicsFunc graphics_handler,
            GraphicsFunc icon_handler)
        {
            _m2 = new M2();
            m2_map[_m2] = this;
            _m2.init(root_element.element, event_source, event_handler, graphics_handler);
            _m2.set_root_change_callback((RootChangeFunc)on_root_element_change);
            set_graphics(graphics, icon_handler);
        }

        ~GM2tk() {
            m2_map.unset(_m2);
        }

        public void draw() {
            _m2.draw();
        }

        public void check_key() {
            _m2.check_key();
        }

        public uint8 handle_key() {
            return _m2.handle_key();
        }

        public void set_root(GElement element, uint8 next_count = 0,
            uint8 change_value = 0)
        {
            _m2.set_root(element.element, next_count, change_value);
        }

        public void set_font(FontIndex index, U8g.Font font) {
            _m2.set_font(index, font);
        }

        public static void set_additional_read_only_x_padding(uint8 width) {
            M2tk.set_additional_read_only_x_padding(width);
        }

        public static void set_additional_text_x_padding(uint8 width) {
            M2tk.set_additional_text_x_padding(width);
        }

        public static void set_invisible_frame_x_padding(uint8 width) {
            M2tk.set_invisible_frame_x_padding(width);
        }

        static void on_root_element_change(Element new_root,
            Element old_root, uint8 value)
        {
            // callback does not let us know who was calling, so we have
            // to try to guess the right one.
            foreach (var m2 in m2_map.keys) {
                if (m2.root == new_root)
                    m2_map[m2].root_element_changed (new_root, old_root, value);
            }
        }
    }
}
