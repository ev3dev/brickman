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

/*
 * brickdm.c:
 *
 * This is the main program. Functions in this file include:
 *
 * - Grabbing a free console for displaying graphics
 * - Handling console switching
 * - Initalizing library data structures
 * - Processing the main event loop
 */

#include <curses.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/kd.h>
#include <sys/vt.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/wait.h>

#include <glib-object.h>
#include <glib-unix.h>

#include "brickdm.h"

GMainLoop *loop;
u8g_t u8g;
GSList *root_stack = NULL;
gboolean brickdm_needs_redraw = TRUE;
gboolean brickdm_show_statusbar = TRUE;
int vtnum;

gboolean brickdm_sigterm_handler(gpointer user_data)
{
  g_main_loop_quit(loop);
  return TRUE;
}

gboolean brickdm_sighup_handler(gpointer user_data)
{
  int vtfd = GPOINTER_TO_INT(user_data);
  struct vt_stat vtstat;
  if (isendwin()) {
    if (ioctl(vtfd, VT_GETSTATE, &vtstat) == 0) {
      if (vtstat.v_active == vtnum) {
        ioctl(vtfd, VT_RELDISP, VT_ACKACQ);
        refresh();
        brickdm_needs_redraw = TRUE;
      }
    }
  } else {
    if (ioctl(vtfd, VT_RELDISP, 1) == 0)
      endwin();
  }
  return TRUE;
}

gboolean timer_handler(gpointer user_data)
{
  if (!isendwin()) {
    m2_CheckKey();
    brickdm_needs_redraw |= m2_HandleKey();
    if (brickdm_needs_redraw)
    {
      u8g_BeginDraw(&u8g);
      m2_Draw();
      if (brickdm_show_statusbar) {
        /* m2_draw can change colors on us */
        u8g_SetDefaultBackgroundColor(&u8g);
        u8g_SetDefaultForegroundColor(&u8g);
        brickdm_power_draw_battery_status();
        u8g_DrawLine(&u8g, 0, 15, u8g_GetWidth(&u8g), 15);
      }
      u8g_EndDraw(&u8g);
      brickdm_needs_redraw = FALSE;
    }
  }
  return TRUE;
}

brickdm_root_info *brickdm_pop_root_stack(void)
{
  GSList *last_root = root_stack;
  brickdm_root_info *info = NULL;

  if (last_root) {
    info = last_root->data;
    root_stack = g_slist_delete_link(root_stack, last_root);
  }
  return info;
}

void brickdm_root_changed_callback(m2_rom_void_p new_root,
                                   m2_rom_void_p old_root, uint8_t change_value)
{
  if (change_value != BRICKDM_MAX_USER_VALUE) {
    brickdm_root_info *info = g_new(brickdm_root_info, 1);
    info->element = old_root;
    info->value = change_value;
    root_stack = g_slist_prepend(root_stack, info);
  }
}

int main(void)
{
  int vtfd;
  FILE *in, *out;
  SCREEN *term;
  char device[32];
  struct vt_stat vtstat;
  int exit_value = 0;
  struct vt_mode mode = {
    .mode = VT_PROCESS,
    .relsig = SIGHUP,
    .acqsig = SIGHUP,
  };

   g_type_init();

  vtfd = open("/dev/tty0", O_RDWR, 0);
  if (vtfd < 0) {
    perror("could not open /dev/tty0");
    exit (1);
  }
  if (ioctl(vtfd, VT_GETSTATE, &vtstat) < 0) {
    perror("tty is not virtual console");
    exit (1);
  }
  if (ioctl(vtfd, VT_OPENQRY, &vtnum) < 0) {
    perror("no free virtual consoles");
    exit (1);
  }
  sprintf(device, "/dev/tty%d", vtnum);
  if (access(device, (W_OK|R_OK)) < 0) {
    perror("insufficient permission on tty");
    exit (1);
  }

  ioctl(vtfd, VT_ACTIVATE, vtnum);
  ioctl(vtfd, VT_WAITACTIVE, vtnum);

  close (vtfd);
  vtfd = open(device, O_RDWR, 0);
  in = fdopen(vtfd, "r");
  out = fdopen(vtfd, "w");
  term = newterm("linux", in, out);
  /* we are using ncurses for keyboard input only - see brickdm_event.c */

  do
  {
    if (ioctl(vtfd, KDSETMODE, KD_GRAPHICS) < 0)
    {
      perror("Could not set virtual console to KD_GRAPHICS mode.");
      exit_value = 1;
      break;
    }

    if (ioctl(vtfd, VT_SETMODE, &mode) < 0)
    {
      perror("Could not set virtual console to VT_PROCESS mode.");
      exit_value = 1;
      break;
    }

    /* we are now free to directly access the framebuffer */

    u8g_Init(&u8g, &u8g_dev_linux_fb);
    m2_Init(&brickdm_home_root, brickdm_event_source, brickdm_event_handler,
            m2_gh_u8g_bfs);
    m2_SetRootChangeCallback(brickdm_root_changed_callback);
    m2_SetU8g(&u8g, m2_u8g_box_icon);
    m2_SetFont(0, u8g_font_7x13);
    m2_SetFont(1, u8g_font_m2icon_9);
    m2_SetU8gAdditionalTextXBorder(3);

    loop = g_main_loop_new (NULL, FALSE);
    g_timeout_add(50, timer_handler, NULL);
    // TODO: glib >= 2.36 can handle user signals
    // This would be better as SIGUSR1
    g_unix_signal_add(SIGHUP, brickdm_sighup_handler, GINT_TO_POINTER(vtfd));
    g_unix_signal_add(SIGINT, brickdm_sigterm_handler, NULL);
    g_unix_signal_add(SIGTERM, brickdm_sigterm_handler, NULL);

    brickdm_power_init();

    g_main_loop_run(loop);
    u8g_Stop(&u8g);
  } while(0);

  /* tear down and cleanup */
  ioctl(vtfd, KDSETMODE, KD_TEXT);
  mode.mode = VT_AUTO;
  ioctl(vtfd, VT_SETMODE, &mode);
  if (!isendwin()) {
    endwin();
    ioctl(vtfd, VT_ACTIVATE, vtstat.v_active);
    ioctl(vtfd, VT_WAITACTIVE, vtstat.v_active);
  }
  ioctl(vtfd, VT_DISALLOCATE, vtnum);
  delscreen(term);
  fclose(in);
  fclose(out);
  close(vtfd);

  return exit_value;
}
