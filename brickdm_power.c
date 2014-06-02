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
 * brickdm_power.c:
 *
 * Reads info from the battery and provide functions for displaying that info.
 */

#include <libupower-glib/upower.h>

#include "brickdm.h"

#define BRICKDM_POWER_EV3_BATTERY_PATH \
  "/org/freedesktop/UPower/devices/battery_legoev3_battery"
#define BATTERY_VOLTAGE_SIZE 6
#define TECHNOLOGY_NAME_SIZE 30

gchar *current_device;
gchar battery_voltage[BATTERY_VOLTAGE_SIZE+1];
gchar technology_name[TECHNOLOGY_NAME_SIZE+1];

M2_LABEL(battery_label, NULL, "Battery Info:");
M2_BOX(battery_label_underline, "h1W48");
M2_LABEL(technology_label, NULL, "Type:");
M2_LABELP(technology_value, NULL, technology_name);
M2_LABEL(voltage_label, NULL, "Voltage:");
M2_LABELP(voltage_value, NULL, battery_voltage);
M2_SPACE(grid_space, "w2");
M2_LIST(data_grid_list_data) = {
  &technology_label, &grid_space, &technology_value,
  &voltage_label, &grid_space, &voltage_value,
};
M2_GRIDLIST(data_gird_list, "c3", data_grid_list_data);
M2_ROOT(goto_stats_button, "f4", " Stats ", &brickdm_home_root);
M2_ROOT(goto_hist_button, "f4", " Hist ", &brickdm_home_root);
M2_ROOT(goto_main_button, "f4", " Back ", &brickdm_home_root);
M2_LIST(button_list_data) = { &goto_stats_button, &goto_hist_button,
  &goto_main_button };
M2_HLIST(button_hlist, NULL, button_list_data);
M2_SPACE(list_space, "h5");
M2_LIST(battery_list_data) = { &battery_label, &battery_label_underline,
  &list_space, &data_gird_list, &list_space, &button_hlist };
M2_VLIST(battery_vlist, NULL, battery_list_data);
M2_ALIGN(brickdm_battery_root, BRICKDM_ROOT_FMT, &battery_vlist);

void brickdm_power_draw_battery_status(void)
{
  const int batt_width = 20;
  const int batt_height = 9;
  const int end_y_ofs = 2;
  const int end_width = 2;
  const int x = u8g_GetWidth(&u8g) - batt_width - 5;
  const int y = 5;

  u8g_DrawFrame(&u8g, x, y, batt_width, batt_height);
  u8g_DrawBox(&u8g, x + batt_width, y + end_y_ofs, end_width,
     batt_height - 2 * end_y_ofs);

   u8g_SetFont(&u8g, u8g_font_04b_03b);
   u8g_DrawStr(&u8g, x + 2, y + batt_height - 2, battery_voltage);
}

void brickdm_power_update_status(UpDevice *device)
{
  gdouble voltage;
  UpDeviceTechnology technology;

  g_object_get(device, "voltage", &voltage, NULL);
  g_snprintf(battery_voltage, BATTERY_VOLTAGE_SIZE, "%0.2f", voltage);
  g_object_get(device, "technology", &technology, NULL);
  g_strlcpy(technology_name, up_device_technology_to_string(technology),
    TECHNOLOGY_NAME_SIZE);
  brickdm_needs_redraw = TRUE;
}

static void
brickdm_power_device_changed_cb (UpClient *client, UpDevice *device,
                                 gpointer user_data)
{
  const gchar *object_path;

  object_path = up_device_get_object_path (device);
  g_debug("changed:   %s", object_path);
  if (object_path == NULL)
    return;
  if (g_strcmp0(BRICKDM_POWER_EV3_BATTERY_PATH, object_path) == 0)
    brickdm_power_update_status(device);
}

void brickdm_power_init(void)
{
  UpClient *client;
  GPtrArray *devices;
  int ret, i;

  client = up_client_new();
  if (!client) {
    g_warning("Could not get upower client.");
    return;
  }
  ret = up_client_enumerate_devices_sync (client, NULL, NULL);
  if (!ret)
    return;
  devices = up_client_get_devices (client);
  for (i=0; i < devices->len; i++) {
    UpDevice *device = g_ptr_array_index (devices, i);
    UpDeviceKind kind;
    const char* object_path;

    g_signal_connect(client, "device-changed",
      G_CALLBACK(brickdm_power_device_changed_cb), NULL);
    g_object_get(device, "kind", &kind, NULL);
    object_path = up_device_get_object_path(device);
    g_debug("Found %s at %s.\n", up_device_kind_to_string(kind), object_path);
    if (g_strcmp0(BRICKDM_POWER_EV3_BATTERY_PATH, object_path) == 0)
      brickdm_power_update_status(device);
  }
}