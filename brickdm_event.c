#include <fcntl.h>
#include <glib.h>
#include <libudev.h>
#include <linux/input.h>
#include <m2ghu8g.h>
#include <stdio.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#define BITS_PER_LONG (sizeof(long) * 8)

struct udev *udev;
struct udev_monitor *udev_monitor;
GSList *event_device_list = NULL;
GSList *event_queue = NULL;
int ttyfd;

struct event_device_info {
  gchar *path;
  int fd;
};

inline gboolean test_bit(int bit, const long unsigned *bytes)
{
  return bytes[bit / BITS_PER_LONG] & (1 << (bit % BITS_PER_LONG));
}

void destroy_event_device_info(gpointer data)
{
  struct event_device_info *info = data;
  if (info) {
    close(info->fd);
    g_free(info->path);
    g_free(data);
  }
}

void append_event_device(const gchar *path)
{
  struct event_device_info *info;
  unsigned long evbit[(EV_CNT + BITS_PER_LONG + 1) / BITS_PER_LONG];

  printf("Adding Device Node Path: %s\n", path);
  info = g_try_new(struct event_device_info, 1);
  if (!info) {
    perror("Out of memory!");
    return;
  }

  info->path = g_strdup(path);
  info->fd = open(path, O_RDWR | O_NONBLOCK);
  if (info->fd < 0) {
    perror("Could not open file.");
    destroy_event_device_info((gpointer)info);
    return;
  }

  /* check that device is a keyboard */
  ioctl(info->fd, EVIOCGBIT(0, sizeof(evbit)), evbit);
  if (!test_bit(EV_KEY, evbit)) {
    destroy_event_device_info((gpointer)info);
    return;
  }

  event_device_list = g_slist_append(event_device_list, (gpointer)info);
}

gint compare_event_device_path(gconstpointer a, gconstpointer b)
{
  const struct event_device_info *info = a;
  const char* path = b;

  return g_strcmp0(path, info->path);
}

void remove_event_device(const char *path)
{
  GSList *item =
    g_slist_find_custom(event_device_list, (gconstpointer)path,
                        compare_event_device_path);
  struct event_device_info *info;

  if (!item)
    return;
  info = item->data;
  if (info) {
    printf("Removing Device Node Path: %s\n", path);
    event_device_list = g_slist_remove(event_device_list, info);
    destroy_event_device_info(info);
  }
}

void check_udev_monitor()
{
  int fd, ret;
  fd_set fds;
  struct timeval tv;
  struct udev_device *dev;
  const gchar *path, *action;

  fd = udev_monitor_get_fd(udev_monitor);

  FD_ZERO(&fds);
  FD_SET(fd, &fds);
  tv.tv_sec = 0;
  tv.tv_usec = 0;

  ret = select(fd+1, &fds, NULL, NULL, &tv);
  if (ret > 0 && FD_ISSET(fd, &fds)) {
    dev = udev_monitor_receive_device(udev_monitor);
    if (!dev)
      return;
    path = udev_device_get_devnode(dev);
    if (!path)
      return;
    action = udev_device_get_action(dev);
    if (!g_strcmp0(action, "add"))
      append_event_device(path);
    else if (!g_strcmp0(action, "remove"))
      remove_event_device(path);
    udev_device_unref(dev);
  }
}

void check_event_devices()
{
  GSList *dev = event_device_list;
  struct event_device_info *info;
  struct input_event event;
  const int event_size = sizeof(struct input_event);

  event_queue = g_slist_reverse(event_queue);
  while (dev)
  {
    info = dev->data;
    while (read(info->fd, &event, event_size) == event_size)
    {
      /* only look at keyboard events */
      if (event.type != EV_KEY)
        continue;
      /* ignore key up event - other events are key down and autorepeat */
      if (event.value == 1)
        continue;
      event_queue = g_slist_prepend(event_queue, GINT_TO_POINTER(event.code));
    }
    dev = g_slist_next(dev);
  }
  event_queue = g_slist_reverse(event_queue);
}

/*
 * Implements m2_es_fnptr (m2tklib event source)
 */
uint8_t brickdm_event_source(m2_p ep, uint8_t msg)
{
  struct udev_enumerate *udev_enum;
  struct udev_list_entry *input_devices, *input_dev;
  int code;

  switch(msg)
  {
    case M2_ES_MSG_GET_KEY:
      check_udev_monitor();
      check_event_devices();
      if(!event_queue)
        break;
      code = GPOINTER_TO_INT(event_queue->data);
      event_queue = g_slist_remove(event_queue, event_queue->data);

      switch (code) {
        /* Actual keys on the EV3 */
        case KEY_UP:
          return M2_KEY_EVENT(M2_KEY_DATA_UP);
        case KEY_DOWN:
          return M2_KEY_EVENT(M2_KEY_DATA_DOWN);
        case KEY_LEFT:
          return M2_KEY_EVENT(M2_KEY_PREV);
        case KEY_RIGHT:
          return M2_KEY_EVENT(M2_KEY_NEXT);
        case KEY_ENTER:
          return M2_KEY_EVENT(M2_KEY_SELECT);
        case KEY_ESC:
          return M2_KEY_EVENT(M2_KEY_EXIT);

        /* Other keys incase a keyboard or keypad is plugged in */
        case KEY_BACKSPACE:
          return M2_KEY_EVENT(M2_KEY_EXIT);
        case KEY_HOME:
          return M2_KEY_EVENT(M2_KEY_HOME);
        case KEY_F1:
          return M2_KEY_EVENT(M2_KEY_Q1);
        case KEY_F2:
          return M2_KEY_EVENT(M2_KEY_Q2);
        case KEY_F3:
          return M2_KEY_EVENT(M2_KEY_Q3);
        case KEY_F4:
          return M2_KEY_EVENT(M2_KEY_Q4);
        case KEY_F5:
          return M2_KEY_EVENT(M2_KEY_Q5);
        case KEY_F6:
          return M2_KEY_EVENT(M2_KEY_Q6);
        case KEY_0:
        case KEY_KP0:
        case KEY_NUMERIC_0:
          return M2_KEY_EVENT(M2_KEY_0);
        case KEY_1:
        case KEY_KP1:
        case KEY_NUMERIC_1:
          return M2_KEY_EVENT(M2_KEY_1);
        case KEY_2:
        case KEY_KP2:
        case KEY_NUMERIC_2:
          return M2_KEY_EVENT(M2_KEY_2);
        case KEY_3:
        case KEY_KP3:
        case KEY_NUMERIC_3:
          return M2_KEY_EVENT(M2_KEY_3);
        case KEY_4:
        case KEY_KP4:
        case KEY_NUMERIC_4:
          return M2_KEY_EVENT(M2_KEY_4);
        case KEY_5:
        case KEY_KP5:
        case KEY_NUMERIC_5:
          return M2_KEY_EVENT(M2_KEY_5);
        case KEY_6:
        case KEY_KP6:
        case KEY_NUMERIC_6:
          return M2_KEY_EVENT(M2_KEY_6);
        case KEY_7:
        case KEY_KP7:
        case KEY_NUMERIC_7:
          return M2_KEY_EVENT(M2_KEY_7);
        case KEY_8:
        case KEY_KP8:
        case KEY_NUMERIC_8:
          return M2_KEY_EVENT(M2_KEY_8);
        case KEY_9:
        case KEY_KP9:
        case KEY_NUMERIC_9:
          return M2_KEY_EVENT(M2_KEY_9);
        case KEY_NUMERIC_STAR:
          return M2_KEY_EVENT(M2_KEY_STAR);
        case KEY_NUMERIC_POUND:
          return M2_KEY_EVENT(M2_KEY_HASH);
      }
      return M2_KEY_NONE;
    case M2_ES_MSG_INIT:
      udev = udev_new();
      if (!udev) {
        perror("Can't create udev.");
        return 1;
      }

      udev_monitor = udev_monitor_new_from_netlink(udev, "udev");
      udev_monitor_filter_add_match_subsystem_devtype(udev_monitor, "input", NULL);
      udev_monitor_enable_receiving(udev_monitor);

      udev_enum = udev_enumerate_new(udev);
      if (udev_enumerate_add_match_subsystem(udev_enum, "input") < 0) {
              perror("Could not enumerate udev input subsystem.");
      }
      udev_enumerate_scan_devices(udev_enum);
      input_devices = udev_enumerate_get_list_entry(udev_enum);
      udev_list_entry_foreach(input_dev, input_devices) {
        struct udev_device *dev;
        const char *path;

        path = udev_list_entry_get_name(input_dev);
        dev = udev_device_new_from_syspath(udev, path);
        path = udev_device_get_devnode(dev);
        // only event devices have a dev node (i.e. /dev/input/event0).
        if (!path)
          continue;
        append_event_device(path);
        udev_device_unref(dev);
      }
      udev_enumerate_unref(udev_enum);
      break;
  }
  return 0;
}

void brickdm_event_destroy(void)
{
  udev_monitor_unref(udev_monitor);
  udev_unref(udev);
  g_slist_free_full(event_device_list, destroy_event_device_info);
}