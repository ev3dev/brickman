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
 * brickdm_event.c:
 *
 * Implements an m2tk event source that gets keyboard input using the ncurses
 * library.
 */

#include <curses.h>
#include <m2ghu8g.h>

#include "brickdm.h"

uint8_t brickdm_event_source(m2_p ep, uint8_t msg)
{
  switch(msg)
  {
    case M2_ES_MSG_GET_KEY:
      switch (getch()) {
        /* Actual keys on the EV3 */
        case KEY_DOWN:
          return M2_KEY_EVENT(M2_KEY_DATA_DOWN);
        case KEY_UP:
          return M2_KEY_EVENT(M2_KEY_DATA_UP);
        case KEY_LEFT:
          return M2_KEY_EVENT(M2_KEY_PREV);
        case KEY_RIGHT:
          return M2_KEY_EVENT(M2_KEY_NEXT);
        case '\n':
          return M2_KEY_EVENT(M2_KEY_SELECT);
        case KEY_BACKSPACE:
          return M2_KEY_EVENT(M2_KEY_EXIT);

        /* Other keys incase a keyboard or keypad is plugged in */
        case KEY_BTAB:
        case KEY_PREVIOUS:
          return M2_KEY_EVENT(M2_KEY_PREV);
        case KEY_NEXT:
          return M2_KEY_EVENT(M2_KEY_NEXT);
        case KEY_ENTER:
        case KEY_COMMAND:
        case KEY_OPEN:
          return M2_KEY_EVENT(M2_KEY_SELECT);
        case KEY_CANCEL:
        case KEY_EXIT:
          return M2_KEY_EVENT(M2_KEY_EXIT);
        case KEY_HOME:
          return M2_KEY_EVENT(M2_KEY_HOME);
        case KEY_SHOME:
          return M2_KEY_EVENT(M2_KEY_HOME2);
        case KEY_F(1):
          return M2_KEY_EVENT(M2_KEY_Q1);
        case KEY_F(2):
          return M2_KEY_EVENT(M2_KEY_Q2);
        case KEY_F(3):
          return M2_KEY_EVENT(M2_KEY_Q3);
        case KEY_F(4):
          return M2_KEY_EVENT(M2_KEY_Q4);
        case KEY_F(5):
          return M2_KEY_EVENT(M2_KEY_Q5);
        case KEY_F(6):
          return M2_KEY_EVENT(M2_KEY_Q6);
        case '0':
          return M2_KEY_EVENT(M2_KEY_0);
        case '1':
          return M2_KEY_EVENT(M2_KEY_1);
        case '2':
          return M2_KEY_EVENT(M2_KEY_2);
        case '3':
          return M2_KEY_EVENT(M2_KEY_3);
        case '4':
          return M2_KEY_EVENT(M2_KEY_4);
        case '5':
          return M2_KEY_EVENT(M2_KEY_5);
        case '6':
          return M2_KEY_EVENT(M2_KEY_6);
        case '7':
          return M2_KEY_EVENT(M2_KEY_7);
        case '8':
          return M2_KEY_EVENT(M2_KEY_8);
        case '9':
          return M2_KEY_EVENT(M2_KEY_9);
        case '*':
          return M2_KEY_EVENT(M2_KEY_STAR);
        case '#':
          return M2_KEY_EVENT(M2_KEY_HASH);
      }
      return M2_KEY_NONE;
    case M2_ES_MSG_INIT:
      cbreak();
      noecho();
      keypad(stdscr, TRUE);
      nodelay(stdscr, TRUE);
      break;
  }
  return 0;
}
#include <glib.h>
uint8_t brickdm_event_handler(m2_p ep, uint8_t msg, uint8_t arg1, uint8_t arg2)
{
  m2_nav_p nav = m2_get_nav(ep);

  switch(msg) {
    case M2_EP_MSG_SELECT:
      return m2_nav_user_down(nav, 1);

    case M2_EP_MSG_EXIT:
      // if there is no valid parent, then go to the previous root
      if (!m2_nav_user_up(nav)) {
        brickdm_root_info *info = brickdm_pop_root_stack();
        if (info) {
          m2_SetRootExtended(info->element, info->value, BRICKDM_MAX_USER_VALUE);
          g_free(info);
        } else {
          // TODO: show shutdown dialog
        }
      }
      return 1;

    case M2_EP_MSG_NEXT:
      return m2_nav_user_next(nav);

    case M2_EP_MSG_PREV:
      return m2_nav_user_prev(nav);

    case M2_EP_MSG_DATA_DOWN:
      if ( m2_nav_data_down(nav) == 0 )
        return m2_nav_user_next(nav);
      return 1;

    case M2_EP_MSG_DATA_UP:
      if ( m2_nav_data_up(nav) == 0 )
        return m2_nav_user_prev(nav);
      return 1;
  }

  if (msg >= M2_KEY_Q1 && msg <= M2_KEY_LOOP_END) {
    if (m2_nav_quick_key(nav, msg - M2_KEY_Q1 + 1) != 0)
    {
      if (m2_nav_is_data_entry(nav))
        return m2_nav_data_up(m2_get_nav(ep));
      return m2_nav_user_down(nav, 1);
    }
  }

  if (msg >= M2_EL_MSG_SPACE) {
    m2_nav_prepare_fn_arg_current_element(nav);
    m2_fn_arg_call(msg);           // assign the char
    return m2_nav_user_next(nav);  // go to next position
  }
  return 0;
}
