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
 * brickdm_home.c:
 *
 * The home sceen for brickdm.
 */

#include "brickdm.h"

m2_menu_entry main_menu_data[] = {
  { "Info", NULL },
  { ". Battery", &brickdm_battery_root },
  { ". Network", &brickdm_battery_root },
  { NULL, NULL }
};

uint8_t main_menu_first = 0;
uint8_t main_menu_cnt = 6;

M2_2LMENU(main_menu, "l7e20W42", &main_menu_first, &main_menu_cnt,
          main_menu_data, '+', '-', '\0');
M2_SPACE(main_menu_space, "W1h1");
M2_VSB(main_menu_scroll, "l4w4r1", &main_menu_first, &main_menu_cnt);
M2_LIST(main_menu_list_data) = { &main_menu, &main_menu_space, &main_menu_scroll };
M2_HLIST(main_menu_hlist, NULL, main_menu_list_data);
M2_ALIGN(brickdm_home_root, BRICKDM_ROOT_FMT, &main_menu_hlist);