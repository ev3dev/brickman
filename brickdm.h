/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
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

#ifndef __BRICKDM_H
#define __BRICKDM_H

#include <glib.h>
#include <m2ghu8g.h>

/* m2tk format string for root ALIGN elemets */
#define BRICKDM_ROOT_FMT "-1|1W64H56"

/* globals */
extern u8g_t u8g;
extern gboolean brickdm_needs_redraw;

/* brickdm_home.c */
M2_EXTERN_ALIGN(brickdm_home_root);
extern m2_menu_entry main_menu_data[];

/* brickdm_power.c */
M2_EXTERN_ALIGN(brickdm_battery_root);
extern void brickdm_power_init(void);
extern void brickdm_power_draw_battery_status(void);

/* brickdm_event.c */
extern uint8_t brickdm_event_source(m2_p ep, uint8_t msg);

/* brickdm_graphcics.c */
extern uint8_t brickdm_gh_bfs(m2_gfx_arg_p arg);

#endif /* __BRICKDM_H */