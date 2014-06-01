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

#include <glib.h>
#include <glib-object.h>
#include <glib-unix.h>
#include <dbus/dbus.h>
#include <dbus/dbus-glib.h>

#include <u8g.h>
#include <m2.h>
#include <m2ghu8g.h>

#include "brickdm.h"

GMainLoop *loop;
u8g_t u8g;
uint8_t needs_redraw = TRUE;
int vtnum;
gboolean owns_vt = FALSE;

gboolean brickdm_sigterm_handler(gpointer user_data)
{
  g_main_loop_quit(loop);
  return TRUE;
}

gboolean brickdm_sighup_handler(gpointer user_data)
{
  int vtfd = GPOINTER_TO_INT(user_data);
  struct vt_stat vtstat;

  if (owns_vt) {
    if (ioctl(vtfd, VT_RELDISP, 1) == 0)
      owns_vt = FALSE;
  } else {
    if (ioctl(vtfd, VT_GETSTATE, &vtstat) == 0) {
      if (vtstat.v_active == vtnum) {
        ioctl(vtfd, VT_RELDISP, VT_ACKACQ);
        needs_redraw = TRUE;
        owns_vt = TRUE;
      }
    }
  }
  return TRUE;
}

gboolean timer_handler(gpointer user_data)
{
  if (owns_vt) {
    m2_CheckKey();
    needs_redraw |= m2_HandleKey();
    if (needs_redraw)
    {
      u8g_BeginDraw(&u8g);
      m2_Draw();
      u8g_EndDraw(&u8g);
    }
    needs_redraw = 0;
  }
  return TRUE;
}

M2_EXTERN_ALIGN(main_menu);

M2_LABEL(battery_label, NULL, "Battery");
M2_ROOT(goto_main, NULL, " Goto Main Menu ", &main_menu);
M2_LIST(battery_list) = { &battery_label, &goto_main };
M2_VLIST(battery_dialog, NULL, battery_list);

m2_menu_entry menu_data[] = {
  { "Info", NULL },
  { ". Battery", &battery_dialog },
  { ". Network", &battery_dialog },
  { "Other", NULL },
  { NULL, NULL }
};

uint8_t main_menu_first = 0;
uint8_t main_menu_cnt = 6;

M2_2LMENU(main_menu_menu, "l7e20W42", &main_menu_first, &main_menu_cnt, menu_data, '+', '-', '\0');
M2_SPACE(main_menu_space, "W1h1");
M2_VSB(main_menu_scroll, "l4W2r1", &main_menu_first, &main_menu_cnt);
M2_LIST(main_menu_list_data) = { &main_menu_menu, &main_menu_space, &main_menu_scroll };
M2_HLIST(main_menu_hlist, NULL, main_menu_list_data);
M2_ALIGN(main_menu, "-1|1W64H64", &main_menu_hlist);

int main(void)
{
  int vtfd;
  char device[32];
  struct vt_stat vtstat;
  int exit_value = 0;
  struct vt_mode mode = {
    .mode = VT_PROCESS,
    .relsig = SIGHUP,
    .acqsig = SIGHUP,
  };

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
  do
  {
    if (ioctl(vtfd, KDSETMODE, KD_GRAPHICS) < 0)
    {
      perror("Could not set virtual console to KD_GRAPHICS mode.");
      exit_value = 1;
      break;
    }

    owns_vt = TRUE;
    if (ioctl(vtfd, VT_SETMODE, &mode) < 0)
    {
      perror("Could not set virtual console to VT_PROCESS mode.");
      break;
    }

    /*
     * we are now free to directly access the framebuffer and take over the
     * event subsystem.
     */

    u8g_Init(&u8g, &u8g_dev_linux_fb);
    m2_Init(&main_menu, brickdm_event_source, m2_eh_6bs, m2_gh_u8g_bfs);
    m2_SetU8g(&u8g, m2_u8g_box_icon);
    m2_SetFont(0, u8g_font_7x13);
    m2_SetFont(1, u8g_font_m2icon_9);

    loop = g_main_loop_new (NULL, FALSE);
    g_timeout_add(100, timer_handler, NULL);
    // TODO: glib >= 2.36 can handle user signals - this would be better as SIGUSR1
    g_unix_signal_add(SIGHUP, brickdm_sighup_handler, GINT_TO_POINTER(vtfd));
    g_unix_signal_add(SIGINT, brickdm_sigterm_handler, NULL);
    g_unix_signal_add(SIGTERM, brickdm_sigterm_handler, NULL);
    g_main_loop_run(loop);
    brickdm_event_destroy();
    u8g_Stop(&u8g);
  } while(FALSE);

  /* tear down and cleanup */
  mode.mode = VT_AUTO;
  ioctl(vtfd, VT_SETMODE, &mode);
  ioctl(vtfd, KDSETMODE, KD_TEXT);
  if (owns_vt) {
    ioctl(vtfd, VT_ACTIVATE, vtstat.v_active);
    ioctl(vtfd, VT_WAITACTIVE, vtstat.v_active);
  }
  ioctl(vtfd, VT_DISALLOCATE, vtnum);
  close(vtfd);

  return exit_value;
}
