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
 * power.vala:
 *
 * Reads info from the battery and provides functions for displaying
 * that info.
 */

using M2tk;

namespace BrickDisplayManager {

    class Power {
        const string EV3_BATTERY_PATH =
            "/org/freedesktop/UPower/devices/battery_legoev3_battery";
        //const int BATTERY_HIST_GRAPH_WIDTH = 100;

        //string battery_voltage;
        //string battery_voltage2;
        //string battery_current;
       // string battery_power;
        //string technology_name;
       //double battery_hist_data[100];


        /* battery info screen */
        Label _battery_info_title_label;
        Box _battery_info_title_underline;
        Space _battery_info_vlist_space;
        Label _battery_info_type_label;
        Label _battery_info_type_value;
        Label _battery_info_voltage_label;
        Label _battery_info_voltage_value;
        Label _battery_info_current_label;
        Label _battery_info_current_value;
        Label _battery_info_power_label;
        Label _battery_info_power_value;
        Space _battery_info_grid_space;
        Element _battery_info_grid_list_data[12];
        GridList _battery_info_grid;
        Root _battery_info_hist_button;
        Root _battery_info_stats_button;
        Element _battery_info_battery_button_list_data[2];
        HList _battery_info_button_hlist;
        Element _battery_info_battery_list_data[6];
        VList _battery_info_vlist;
        Align _battery_info_root_element;

        public unowned Element battery_info_root_element {
            get { return _battery_info_root_element; }
        }
        Element _battery_hist_root_element;
        public unowned Element battery_hist_root_element {
            get { return _battery_hist_root_element; }
        }
        Element _battery_stats_root_element;
        public unowned Element battery_stats_root_element {
            get { return _battery_stats_root_element; }
        }
        Element _shutdown_root_element;
        public unowned Element shutdown_root_element {
            get { return _shutdown_root_element; }
        }

        public Power() {

            _battery_info_title_label =  Label.create("Battery Info:");
            _battery_info_title_underline = Box.create("h1W48");
            _battery_info_vlist_space = Space.create("h5");
            _battery_info_type_label = Label.create("Type:");
            _battery_info_type_value = Label.create();
            _battery_info_voltage_label = Label.create("Voltage:");
            _battery_info_voltage_value = Label.create();
            _battery_info_current_label = Label.create("Current:");
            _battery_info_current_value = Label.create();
            _battery_info_power_label = Label.create("Power:");
            _battery_info_power_value = Label.create();
            _battery_info_grid_space = Space.create("w2");
            _battery_info_grid_list_data[0] = (owned) _battery_info_type_label;
            _battery_info_grid_list_data[1] = (owned) _battery_info_grid_space;
            _battery_info_grid_list_data[2] = (owned) _battery_info_type_value;
            _battery_info_grid_list_data[3] = (owned) _battery_info_voltage_label;
            _battery_info_grid_list_data[4] = (owned) _battery_info_grid_space;
            _battery_info_grid_list_data[5] = (owned) _battery_info_voltage_value;
            _battery_info_grid_list_data[6] = (owned) _battery_info_current_value;
            _battery_info_grid_list_data[7] = (owned) _battery_info_grid_space;
            _battery_info_grid_list_data[8] = (owned) _battery_info_current_value;
            _battery_info_grid_list_data[9] = (owned) _battery_info_power_label;
            _battery_info_grid_list_data[10] = (owned) _battery_info_grid_space;
            _battery_info_grid_list_data[11] = (owned) _battery_info_power_value;
            _battery_info_grid = GridList.create(_battery_info_grid_list_data, "c3");
            _battery_info_hist_button = Root.create(battery_hist_root_element, "History", "f4");
            _battery_info_stats_button = Root.create(battery_stats_root_element, "Stats", "f4");
            _battery_info_battery_button_list_data[0] = (owned) _battery_info_hist_button;
            _battery_info_battery_button_list_data[1] = (owned) _battery_info_stats_button;
            _battery_info_button_hlist = HList.create(_battery_info_battery_button_list_data);
            _battery_info_battery_list_data [0] = (owned) _battery_info_title_label;
            _battery_info_battery_list_data [1] = (owned) _battery_info_title_underline;
            _battery_info_battery_list_data [2] = (owned) _battery_info_vlist_space;
            _battery_info_battery_list_data [3] = (owned) _battery_info_grid;
            _battery_info_battery_list_data [4] = (owned) _battery_info_vlist_space;
            _battery_info_battery_list_data [5] = (owned) _battery_info_button_hlist;
            _battery_info_vlist = VList.create(_battery_info_battery_list_data);
            _battery_info_root_element = Align.create(_battery_info_vlist, DEFAULT_ROOT_ELEMENT_FORMAT);

/*
            _battery_hist_root_element = Align.create(
                (owned) VList.create({
                        (owned) Label.create("History:"),
                        (owned) Space.create()
                }), DEFAULT_ROOT_ELEMENT_FORMAT);

            _battery_stats_root_element = Align.create(
                VList.create({
                        Label.create("Statistics:"),
                        Space.create()
                }), DEFAULT_ROOT_ELEMENT_FORMAT);



            _shutdown_root_element = Align.create(
                VList.create({
                        Button.create((ButtonFunc)on_shutdown_button, "Shutdown", "f12W32"),
                        Button.create((ButtonFunc)on_restart_button, "Restart", "f12W32")
                }), DEFAULT_ROOT_ELEMENT_FORMAT);
*/
        }

/*
        void update_battery_hist_data(UpDevice *device)
        {
          GPtrArray *array;
          UpHistoryItem *item;
          int i;

          g_debug("Getting history.");
          array = up_device_get_history_sync(device, "rate", 3600,
                                             BATTERY_HIST_GRAPH_WIDTH, NULL, NULL);
          if(!array) {
            g_debug("Failed to get history.");
            // TODO: show error on screen
            return;
          }
          for (i=0; i<array->len; i++) {
            item = g_ptr_array_index(array, i);
            battery_hist_data[i] = up_history_item_get_value (item);
            g_debug("time: %d, state: %d, value: %.2f", up_history_item_get_time(item),
              up_history_item_get_state (item), battery_hist_data[i]);
          }
          g_ptr_array_unref (array);
          brickdm_needs_redraw = TRUE;
        }

        void battery_hist_button_callback(m2_el_fnarg_p fnarg)
        {
          UpDevice *device = up_device_new();
          up_device_set_object_path_sync(device, BRICKDM_POWER_EV3_BATTERY_PATH, NULL, NULL);
          update_battery_hist_data(device);
          g_object_unref(device);
          m2_SetRoot(&brickdm_battery_hist_root);
        }

        void battery_hist_graph_callback(m2_el_fnarg_p fnarg)
        {
          int i;
          g_debug("Drawing graph.");
          for (i=0; i<BATTERY_HIST_GRAPH_WIDTH; i++)
            u8g_DrawPixel(&u8g, i, (battery_hist_data[i]*20));
        }

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
           u8g_DrawStr(&u8g, x + 2, y + batt_height - 2, battery_voltage2);
        }

        void brickdm_power_update_status(UpDevice *device)
        {
          gdouble voltage, rate;
          UpDeviceTechnology technology;

          g_object_get(device, "voltage", &voltage,
                               "energy-rate", &rate,
                               "technology", &technology, NULL);
          g_snprintf(battery_voltage, BATTERY_STRING_SIZE, "%0.2f V", voltage);
          g_snprintf(battery_voltage2, BATTERY_STRING_SIZE, "%0.2f", voltage);
          g_snprintf(battery_current, BATTERY_STRING_SIZE, "%0.0f mA", rate / voltage * 1000.0);
          g_snprintf(battery_power, BATTERY_STRING_SIZE, "%0.2f W", rate);
          g_strlcpy(technology_name, up_device_technology_to_string(technology),
            TECHNOLOGY_NAME_SIZE);
          brickdm_needs_redraw = TRUE;
        }

        static void
        brickdm_power_device_changed_cb(UpClient *client, UpDevice *device,
                                        gpointer user_data)
        {
          const gchar *object_path;
          m2_rom_void_p root = m2_GetRoot();

          ASSERT_MAIN_LOOP;
          object_path = up_device_get_object_path (device);
          //g_debug("changed:   %s", object_path);
          if (object_path == NULL)
            return;
          if (g_strcmp0(BRICKDM_POWER_EV3_BATTERY_PATH, object_path) == 0) {
            if (brickdm_show_statusbar || root == &brickdm_battery_root)
              brickdm_power_update_status(device);
            if (root == &brickdm_battery_hist_root)
              update_battery_hist_data(device);
          }
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
*/
        static void run_command(string command)
        {
            try {
                Process.spawn_command_line_sync(command);
            } catch (SpawnError err) {
                // TODO: handle error
            }
        }

        static void on_shutdown_button(ElementFuncArgs arg)
        {
          run_command("poweroff");
        }

        static void on_restart_button(ElementFuncArgs arg)
        {
          run_command("reboot");
        }
    }
}
