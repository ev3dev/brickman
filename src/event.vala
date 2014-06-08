/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * brickdm_event_handler() copied from m2eh6bs.c
 * m2tklib = Mini Interative Interface Toolkit Library
 * Copyright (C) 2011  olikraus@gmail.com
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
 * event.vala:
 *
 * - M2tkEventSource:  M2tkEventSourceFunc that gets keyboard input
 *                     using the ncurses library.
 * - M2tkEventHandler: M2tkEventHandlerFunc that process key presses for
 *                     navigation and data entry.
 */

namespace BrickDisplayManager
{
    uchar M2tkEventSource(M2tk.M2 m2, M2tk.EventSourceMessage msg) {
        switch(msg) {
        case M2tk.EventSourceMessage.GET_KEY:
            switch (Curses.getch()) {
            /* Actual keys on the EV3 */
            case Curses.Key.DOWN:
                return M2tk.Key.EVENT | M2tk.Key.DATA_DOWN;
            case Curses.Key.UP:
                return M2tk.Key.EVENT | M2tk.Key.DATA_UP;
            case Curses.Key.LEFT:
                return M2tk.Key.EVENT | M2tk.Key.PREV;
            case Curses.Key.RIGHT:
                return M2tk.Key.EVENT | M2tk.Key.NEXT;
            case '\n':
                return M2tk.Key.EVENT | M2tk.Key.SELECT;
            case Curses.Key.BACKSPACE:
                return M2tk.Key.EVENT | M2tk.Key.EXIT;

            /* Other keys in case a keyboard or keypad is plugged in */
            case Curses.Key.BTAB:
            case Curses.Key.PREVIOUS:
                return M2tk.Key.EVENT | M2tk.Key.PREV;
            case Curses.Key.NEXT:
              return M2tk.Key.EVENT | M2tk.Key.NEXT;
            case Curses.Key.ENTER:
            case Curses.Key.OPEN:
               return M2tk.Key.EVENT | M2tk.Key.SELECT;
            case Curses.Key.CANCEL:
            case Curses.Key.EXIT:
                return M2tk.Key.EVENT | M2tk.Key.EXIT;
            case Curses.Key.HOME:
                return M2tk.Key.EVENT | M2tk.Key.HOME;
            case Curses.Key.SHOME:
                return M2tk.Key.EVENT | M2tk.Key.HOME2;
            case Curses.Key.F0+1:
                return M2tk.Key.EVENT | M2tk.Key.Q1;
            case Curses.Key.F0+2:
                return M2tk.Key.EVENT | M2tk.Key.Q2;
            case Curses.Key.F0+3:
                return M2tk.Key.EVENT | M2tk.Key.Q3;
            case Curses.Key.F0+4:
                return M2tk.Key.EVENT | M2tk.Key.Q4;
            case Curses.Key.F0+5:
                return M2tk.Key.EVENT | M2tk.Key.Q5;
            case Curses.Key.F0+6:
                return M2tk.Key.EVENT | M2tk.Key.Q6;
            case '0':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_0;
            case '1':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_1;
            case '2':
              return M2tk.Key.EVENT | M2tk.Key.KEYPAD_2;
            case '3':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_3;
            case '4':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_4;
            case '5':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_5;
            case '6':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_6;
            case '7':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_7;
            case '8':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_8;
            case '9':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_9;
            case '*':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_STAR;
            case '#':
                return M2tk.Key.EVENT | M2tk.Key.KEYPAD_HASH;
          }
          return M2tk.Key.NONE;
        case M2tk.EventSourceMessage.INIT:
            Curses.cbreak();
            Curses.noecho();
            Curses.stdscr.keypad(true);
            Curses.stdscr.nodelay(true);
            break;
        }
        return 0;
    }

    uchar M2tkEventHandler(M2tk.M2 m2, M2tk.EventHandlerMessage msg,
        uchar arg1, uchar arg2)
    {
        unowned M2tk.Nav nav = m2.nav;

        switch(msg) {
        case M2tk.EventHandlerMessage.SELECT:
            return nav.user_down(true);

        case M2tk.EventHandlerMessage.EXIT:
            // if there is no valid parent, then go to the previous root
            if (nav.user_up() != 0) {
                var info = root_stack.poll_head();
                if (info != null) {
                    M2tk.set_root(info.element, info.value, RootInfo.MAX_VALUE);
                } else {
                // TODO: show shutdown dialog
                }
            }
            return 1;

        case M2tk.EventHandlerMessage.NEXT:
            return nav.user_next();

        case M2tk.EventHandlerMessage.PREV:
            return nav.user_prev();

        case M2tk.EventHandlerMessage.DATA_DOWN:
            if (nav.data_down() == 0)
                return nav.user_next();
            return 1;

        case M2tk.EventHandlerMessage.DATA_UP:
            if (nav.data_up() == 0)
                return nav.user_prev();
            return 1;
        }

        if (msg >= M2tk.Key.Q1 && msg <= M2tk.Key.LOOP_END) {
            if (nav.quick_key((M2tk.Key)msg - M2tk.Key.Q1 + 1) != 0)
            {
                if (nav.is_data_entry)
                    return nav.data_up();
                return nav.user_down(true);
            }
        }

        if (msg >= M2tk.ElementCallbackMessage.SPACE) {
            nav.data_char(msg);      // assign the char
            return nav.user_next();  // go to next position
        }
        return 0;
    }

}
