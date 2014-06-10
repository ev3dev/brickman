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
using Up;

namespace BrickDisplayManager {

    class Power {

        static Power instance;

        const string EV3_BATTERY_PATH =
            "/org/freedesktop/UPower/devices/battery_legoev3_battery";

        string battery_technology = "<unk>";
        string battery_voltage = "<unk>";
        string battery_voltage2 = "<unk>";
        string battery_current = "<unk>";
        string battery_power = "<unk>";
        double battery_hist_data[100];


        /* battery info screen */

        Element _battery_info_grid_list_data[12];
        Element _battery_info_battery_button_list_data[2];
        Element _battery_info_battery_list_data[6];
        VList _battery_info_vlist;
        Align _battery_info_root_element;

        /* shutdown screen */

        Element _shutdown_list_data[3];
        VList _shutdown_vlist;
        Align _shutdown_root_element;

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
        public unowned Element shutdown_root_element {
            get { return _shutdown_root_element; }
        }

        public Power() {
            instance = this;

            /* battery history screen */
            _battery_hist_root_element = Label.create("History:");

            /* battery statistics screen */
            _battery_stats_root_element = Label.create("Statistics:");

            /* battery info screen */

            _battery_info_grid_list_data = {
                Label.create("Type:"),
                Space.create("w2"),
                LabelWithFunc.create((LabelFunc)on_battery_info_type_label),
                Label.create("Voltage:"),
                Space.create("w2"),
                LabelWithFunc.create((LabelFunc)on_battery_info_voltage_label),
                Label.create("Current:"),
                Space.create("w2"),
                LabelWithFunc.create((LabelFunc)on_battery_info_current_label),
                Label.create("Power:"),
                Space.create("w2"),
                LabelWithFunc.create((LabelFunc)on_battery_info_power_label)
            };
            _battery_info_battery_button_list_data = {
                Root.create(_battery_hist_root_element, "History", "f4"),
                Root.create(_battery_stats_root_element, "Stats", "f4")
            };
            _battery_info_battery_list_data = {
                Label.create("Battery Info:"),
                Box.create("h1W48"),
                Space.create("h5"),
                GridList.create(_battery_info_grid_list_data, "c3"),
                Space.create("h5"),
                HList.create(_battery_info_battery_button_list_data)
            };
            _battery_info_vlist = VList.create(_battery_info_battery_list_data);
            _battery_info_root_element = Align.create(_battery_info_vlist, DEFAULT_ROOT_ELEMENT_FORMAT);

            /* shutdown screen */

            _shutdown_list_data = {
                Button.create((ButtonFunc)on_shutdown_button, "Shutdown", "f12W32"),
                Space.create("h5"),
                Button.create((ButtonFunc)on_restart_button, "Restart", "f12W32")
            };
            _shutdown_vlist = VList.create(_shutdown_list_data);
            _shutdown_root_element = Align.create(_shutdown_vlist, DEFAULT_ROOT_ELEMENT_FORMAT);

            try {
                var client = new Client();
                client.enumerate_devices_sync ();
                var devices = client.get_devices();
                devices.foreach((device) => {
                    device.changed.connect(on_device_changed);
                    var kind = device.kind;
                    var object_path = device.get_object_path();
                    debug("Found %s at %s.", Device.kind_to_string(kind), object_path);
                    if (EV3_BATTERY_PATH == object_path)
                        update_status(device);
                });
            } catch (Error err) {
                warning("%s", err.message);
            }
        }

        void update_battery_hist_data(Device device)
        {
            debug("Getting history.");
            try {
                var items = device.get_history_sync("rate", 3600, battery_hist_data.length);
                items.foreach((item) => {
                    //battery_hist_data[i] = item.get_value();
                    debug("time: %ud, state: %d, value: %.2f", item.get_time(),
                        item.get_state (), item.get_value());
                });
                gui.dirty = true;
            } catch (Error err) {
                warning("%s", err.message);
                // TODO: show error message
            }
        }

        static string on_battery_info_type_label(Element element) {
            return instance.battery_technology;
        }

        static string on_battery_info_voltage_label(Element element) {
            return instance.battery_voltage;
        }

        static string on_battery_info_current_label(Element element) {
            return instance.battery_current;
        }

        static string on_battery_info_power_label(Element element) {
            return instance.battery_power;
        }

        void on_battery_hist_button(ElementFuncArgs arg)
        {
            try {
                Device device = new Device();
                device.set_object_path_sync(EV3_BATTERY_PATH);
                update_battery_hist_data(device);
                //gui.set_root(_battery_hist_root);
            } catch (Error err) {
                warning("%s", err.message);
                //TODO: show error message
            }
        }

        void battery_hist_graph_callback(ElementFuncArgs arg)
        {
            debug("Drawing graph.");
            for (ushort i = 0; i < battery_hist_data.length; i++)
                gui.graphics.draw_pixel(i, (ushort)(battery_hist_data[i]*20));
        }

        void draw_battery_status_icon()
        {
          const ushort batt_width = 20;
          const ushort batt_height = 9;
          const ushort end_y_ofs = 2;
          const ushort end_width = 2;
          ushort x = gui.graphics.get_width() - batt_width - 5;
          const ushort y = 5;

          gui.graphics.draw_frame(x, y, batt_width, batt_height);
          gui.graphics.draw_box(x + batt_width, y + end_y_ofs, end_width,
             batt_height - 2 * end_y_ofs);

           gui.graphics.set_font(U8g.Font.dsg4_04b_03);
           gui.graphics.draw_str(x + 2, y + batt_height - 2, battery_voltage2);
        }

        void update_status(Device device)
        {
            battery_technology = Device.technology_to_string(device.technology);
            battery_voltage = "%0.2f V".printf(device.voltage);
            battery_voltage2 = "%0.2f".printf(device.voltage);
            battery_current = "%0.0f mA".printf(device.energy_rate / device.voltage * 1000.0);
            battery_power = "%0.2f W".printf(device.energy_rate);
            if (gui != null)
                gui.dirty = true;
        }

        void on_device_changed(Device device) {
          var object_path = device.get_object_path();
          debug("changed: %s", object_path);
          unowned Element root = get_root();
          if (object_path == null)
            return;
          if (EV3_BATTERY_PATH == object_path) {
            if (gui.statusbar_visible || root == battery_info_root_element)
              update_status(device);
            if (root == battery_hist_root_element)
              update_battery_hist_data(device);
          }
        }

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
