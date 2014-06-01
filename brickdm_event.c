#include <fcntl.h>
#include <glib.h>
#include <libudev.h>
#include <linux/input.h>
#include <m2ghu8g.h>
#include <stdio.h>
#include <string.h>
#include <sys/kd.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>

GSList *event_queue = NULL;
int ttyfd;
struct termios term_old;
struct termios term_new;
int old_kbd_mode;


void check_event_devices()
{
  char c = 0;
  event_queue = g_slist_reverse(event_queue);
  while (read(ttyfd, &c, sizeof(char)) == sizeof(char)) {
    event_queue = g_slist_prepend(event_queue, GINT_TO_POINTER(c));
  }
  event_queue = g_slist_reverse(event_queue);
  if (c)
    printf("\n");
}

/*
 * Implements m2_es_fnptr (m2tklib event source)
 */
uint8_t brickdm_event_source(m2_p ep, uint8_t msg)
{
  int code;
  struct kbentry entry;

  switch(msg)
  {
    case M2_ES_MSG_GET_KEY:
      check_event_devices();
      if(!event_queue)
        break;
      code = GPOINTER_TO_INT(event_queue->data);
      event_queue = g_slist_remove(event_queue, event_queue->data);

      if (code == '\e') {
        do {
          printf("%s\n", "parsing escape code");
          if(!event_queue)
            break;
          code = GPOINTER_TO_INT(event_queue->data);
          if (code == '\e')
            break;
          printf("escape code: %c %d /0x%x\n", code, code, code);
          event_queue = g_slist_remove(event_queue, event_queue->data);
          if (code == '[') {
            do {
              printf("%s\n", "parsing CSI code");
              if(!event_queue)
                break;
              code = GPOINTER_TO_INT(event_queue->data);
              if (code == '\e')
                break;
              event_queue = g_slist_remove(event_queue, event_queue->data);
              printf("escape code: %c %d /0x%x\n", code, code, code);
              switch (code) {
                case 'A':
                  return M2_KEY_EVENT(M2_KEY_DATA_UP);
                case 'B':
                  return M2_KEY_EVENT(M2_KEY_DATA_DOWN);
                case 'C':
                  return M2_KEY_EVENT(M2_KEY_NEXT);
                case 'D':
                  return M2_KEY_EVENT(M2_KEY_PREV);
              }
              return M2_KEY_NONE;
            } while (0);
          }
        } while (0);
      }

      printf("regular code: %c %d /0x%x %s\n", code & 0x7f, code & 0x7f,
        code & 0x7f, code & 0x80 ? "released" : "pressed");
      entry.kb_table = K_NORMTAB;
      entry.kb_index = code;
      do {
        ioctl(ttyfd, KDGKBENT, &entry);
        printf("entry: %c %d /0x%x\n", entry.kb_value, entry.kb_value, entry.kb_value);
      } while (entry.kb_table++ < K_ALTSHIFTTAB);
      switch (code) {
        /* Actual keys on the EV3 */
        case'\n':
          return M2_KEY_EVENT(M2_KEY_SELECT);
        case '\e':
        case '\b':
        case 127:
          return M2_KEY_EVENT(M2_KEY_EXIT);

        /* Other keys incase a keyboard or keypad is plugged in */
        // case KEY_HOME:
        //   return M2_KEY_EVENT(M2_KEY_HOME);
        // case KEY_F1:
        //   return M2_KEY_EVENT(M2_KEY_Q1);
        // case KEY_F2:
        //   return M2_KEY_EVENT(M2_KEY_Q2);
        // case KEY_F3:
        //   return M2_KEY_EVENT(M2_KEY_Q3);
        // case KEY_F4:
        //   return M2_KEY_EVENT(M2_KEY_Q4);
        // case KEY_F5:
        //   return M2_KEY_EVENT(M2_KEY_Q5);
        // case KEY_F6:
        //   return M2_KEY_EVENT(M2_KEY_Q6);
        // case KEY_0:
        // case KEY_KP0:
        // case KEY_NUMERIC_0:
        //   return M2_KEY_EVENT(M2_KEY_0);
        // case KEY_1:
        // case KEY_KP1:
        // case KEY_NUMERIC_1:
        //   return M2_KEY_EVENT(M2_KEY_1);
        // case KEY_2:
        // case KEY_KP2:
        // case KEY_NUMERIC_2:
        //   return M2_KEY_EVENT(M2_KEY_2);
        // case KEY_3:
        // case KEY_KP3:
        // case KEY_NUMERIC_3:
        //   return M2_KEY_EVENT(M2_KEY_3);
        // case KEY_4:
        // case KEY_KP4:
        // case KEY_NUMERIC_4:
        //   return M2_KEY_EVENT(M2_KEY_4);
        // case KEY_5:
        // case KEY_KP5:
        // case KEY_NUMERIC_5:
        //   return M2_KEY_EVENT(M2_KEY_5);
        // case KEY_6:
        // case KEY_KP6:
        // case KEY_NUMERIC_6:
        //   return M2_KEY_EVENT(M2_KEY_6);
        // case KEY_7:
        // case KEY_KP7:
        // case KEY_NUMERIC_7:
        //   return M2_KEY_EVENT(M2_KEY_7);
        // case KEY_8:
        // case KEY_KP8:
        // case KEY_NUMERIC_8:
        //   return M2_KEY_EVENT(M2_KEY_8);
        // case KEY_9:
        // case KEY_KP9:
        // case KEY_NUMERIC_9:
        //   return M2_KEY_EVENT(M2_KEY_9);
        // case KEY_NUMERIC_STAR:
        //   return M2_KEY_EVENT(M2_KEY_STAR);
        // case KEY_NUMERIC_POUND:
        //   return M2_KEY_EVENT(M2_KEY_HASH);
      }
      return M2_KEY_NONE;
    case M2_ES_MSG_INIT:
      ttyfd = open("/dev/tty0", O_RDWR | O_NONBLOCK);
      if (ttyfd < 0)
        perror("Could not open /dev/tty");
      tcgetattr(ttyfd, &term_old);
      memcpy(&term_new, &term_old, sizeof(struct termios));
      term_new.c_lflag &= ~(ECHO|ICANON); /* disable echo and canonization */
      tcsetattr(ttyfd, TCSANOW, &term_new);
      ioctl(ttyfd, KDGKBMODE, &old_kbd_mode);
      ioctl(ttyfd, KDSKBMODE, K_RAW);
      break;
  }
  return 0;
}

void brickdm_event_destroy(void)
{
  ioctl(ttyfd, KDSKBMODE, old_kbd_mode);
  tcsetattr(ttyfd, TCSANOW, &term_old);
  close(ttyfd);
  g_slist_free(event_queue);
}