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

using U8g;

[CCode (cheader_filename = "m2ghu8g.h")]
namespace M2tk {
     public class GM2tk : Object {
         static GM2tk _instance;
         public static GM2tk instance {
             get {
                if (_instance == null)
                    _instance = new GM2tk();
                return _instance;
            }
        }

        static Graphics _u8g;
        public static Graphics u8g {
            get {
                if (_u8g == null) {
                    _u8g = new Graphics();
                    _u8g.init(U8g.Device.linux_framebuffer);
                }
                return _u8g;
            }
        }

        public signal void root_element_changed(Element new_root,
            Element old_root, uint8 value);

        public static void init(Element root_element,
            EventSourceFunc event_source,
            EventHandlerFunc event_handler,
            GraphicsFunc graphics_handler,
            IconType icon_type = IconType.BOX)
        {
            init(root_element, event_source, event_handler, graphics_handler);
            set_u8g(u8g, icon_type);
            set_root_change_callback((RootChangeFunc)on_root_element_change);
        }

        static void on_root_element_change(Element new_root,
            Element old_root, uint8 value)
        {
            instance.root_element_changed (new_root, old_root, value);
        }
    }
}
