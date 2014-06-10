/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * based in part on GNOME Power Manager:
 * Copyright (C) 2008-2011 Richard Hughes <richard@hughsie.com>
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
 * gui.vala:
 *
 * The main graphical user interface class.
 */

using M2tk;

namespace BrickDisplayManager {

    class GUI : Object {

        static bool dirty = true;
        static bool statusbar_visible = true;
        static U8g.Graphics u8g;
        static Deque<RootInfo> root_stack;
        Power power = new Power();

        Element _list_data[2];
        VList _menu_list;
        Align _root_element;
        public unowned Element root_element {
            get { return _root_element; }
        }

        public GUI() {
            _list_data = {
                //Root.create(network.root_element, "Network"),
                Root.create(power.battery_info_root_element, "Battery"),
                Root.create(power.shutdown_root_element, "Shutdown")
            };
            _menu_list = VList.create(_list_data);
            _root_element = Align.create(_menu_list, DEFAULT_ROOT_ELEMENT_FORMAT);

            u8g = new U8g.Graphics();
            u8g.init(U8g.Device.linux_framebuffer);
            M2tk.init(ui.root_element, M2tkEventSource, M2tkEventHandler,
                M2tk.U8gBoxShadowFrameGraphicsHandler);
            M2tk.set_u8g(u8g, M2tk.IconType.BOX);
            M2tk.set_font(M2tk.FontIndex.F0, U8g.Font.x11_7x13);
            M2tk.set_font(M2tk.FontIndex.F1, U8g.Font.m2tk_icon_9);
            M2tk.set_u8g_additional_text_x_border(3);

            root_stack = new LinkedList<RootInfo>();
            M2tk.set_root_change_callback((M2tk.RootChangeFunc)on_root_element_change);
        }

        public void show_shutdown_screen() {
            set_root(power.shutdown_root_element);
        }

        static void on_root_element_change(M2tk.Element new_root,
            M2tk.Element old_root, uchar value)
        {
            if (value != RootInfo.MAX_VALUE) {
                var info = new RootInfo();
                info.element = old_root;
                info.value = value;
                root_stack.offer_head(info);
            }
        }

        static uchar event_source(M2 m2, EventSourceMessage msg) {
            switch(msg) {
            case EventSourceMessage.GET_KEY:
                switch (Curses.getch()) {
                /* Actual keys on the EV3 */
                case Curses.Key.DOWN:
                    return Key.EVENT | Key.DATA_DOWN;
                case Curses.Key.UP:
                    return Key.EVENT | Key.DATA_UP;
                case Curses.Key.LEFT:
                    return Key.EVENT | Key.PREV;
                case Curses.Key.RIGHT:
                    return Key.EVENT | Key.NEXT;
                case '\n':
                    return Key.EVENT | Key.SELECT;
                case Curses.Key.BACKSPACE:
                    return Key.EVENT | Key.EXIT;

                /* Other keys in case a keyboard or keypad is plugged in */
                case Curses.Key.BTAB:
                case Curses.Key.PREVIOUS:
                    return Key.EVENT | Key.PREV;
                case Curses.Key.NEXT:
                  return Key.EVENT | Key.NEXT;
                case Curses.Key.ENTER:
                case Curses.Key.OPEN:
                   return Key.EVENT | Key.SELECT;
                case Curses.Key.CANCEL:
                case Curses.Key.EXIT:
                    return Key.EVENT | Key.EXIT;
                case Curses.Key.HOME:
                    return Key.EVENT | Key.HOME;
                case Curses.Key.SHOME:
                    return Key.EVENT | Key.HOME2;
                case Curses.Key.F0+1:
                    return Key.EVENT | Key.Q1;
                case Curses.Key.F0+2:
                    return Key.EVENT | Key.Q2;
                case Curses.Key.F0+3:
                    return Key.EVENT | Key.Q3;
                case Curses.Key.F0+4:
                    return Key.EVENT | Key.Q4;
                case Curses.Key.F0+5:
                    return Key.EVENT | Key.Q5;
                case Curses.Key.F0+6:
                    return Key.EVENT | Key.Q6;
                case '0':
                    return Key.EVENT | Key.KEYPAD_0;
                case '1':
                    return Key.EVENT | Key.KEYPAD_1;
                case '2':
                  return Key.EVENT | Key.KEYPAD_2;
                case '3':
                    return Key.EVENT | Key.KEYPAD_3;
                case '4':
                    return Key.EVENT | Key.KEYPAD_4;
                case '5':
                    return Key.EVENT | Key.KEYPAD_5;
                case '6':
                    return Key.EVENT | Key.KEYPAD_6;
                case '7':
                    return Key.EVENT | Key.KEYPAD_7;
                case '8':
                    return Key.EVENT | Key.KEYPAD_8;
                case '9':
                    return Key.EVENT | Key.KEYPAD_9;
                case '*':
                    return Key.EVENT | Key.KEYPAD_STAR;
                case '#':
                    return Key.EVENT | Key.KEYPAD_HASH;
              }
              return Key.NONE;
            case EventSourceMessage.INIT:
                Curses.cbreak();
                Curses.noecho();
                Curses.stdscr.keypad(true);
                Curses.stdscr.nodelay(true);
                break;
            }
            return 0;
        }

        static uchar event_handler(M2 m2, EventHandlerMessage msg,
            uchar arg1, uchar arg2)
        {
            unowned Nav nav = m2.nav;

            switch(msg) {
            case EventHandlerMessage.SELECT:
                return nav.user_down(true);

            case EventHandlerMessage.EXIT:
                // if there is no valid parent, then go to the previous root
                if (nav.user_up() == 0) {
                    var info = root_stack.poll_head();
                    if (info != null) {
                        set_root(info.element, info.value, RootInfo.MAX_VALUE);
                    } else {
                        ui.show_shutdown_screen();
                    }
                }
                return 1;

            case EventHandlerMessage.NEXT:
                return nav.user_next();

            case EventHandlerMessage.PREV:
                return nav.user_prev();

            case EventHandlerMessage.DATA_DOWN:
                if (nav.data_down() == 0)
                    return nav.user_next();
                return 1;

            case EventHandlerMessage.DATA_UP:
                if (nav.data_up() == 0)
                    return nav.user_prev();
                return 1;
            }

            if (msg >= Key.Q1 && msg <= Key.LOOP_END) {
                if (nav.quick_key((Key)msg - Key.Q1 + 1) != 0)
                {
                    if (nav.is_data_entry)
                        return nav.data_up();
                    return nav.user_down(true);
                }
            }

            if (msg >= ElementCallbackMessage.SPACE) {
                nav.data_char(msg);      // assign the char
                return nav.user_next();  // go to next position
            }
            return 0;
        }
    }
}
