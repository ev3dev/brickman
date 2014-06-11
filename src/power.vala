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
        const string EV3_BATTERY_PATH =
            "/org/freedesktop/UPower/devices/battery_legoev3_battery";
        const string UNKNOWN_VALUE = "<unk>";

        string battery_voltage2 = UNKNOWN_VALUE;
        double battery_hist_data[100];

        public BatteryInfoScreen battery_info_screen { get; private set; }
        public ShutdownScreen shutdown_screen { get; private set; }

        public class BatteryInfoScreen : Screen {
            BatteryHistScreen _battery_hist_screen;
            BatteryStatsScreen _battery_stats_screen;

            GLabel _title_label;
            GBox _title_underline;
            GSpace _space;
            GLabel _tech_label;
            GLabel _tech_value_label;
            GLabel _voltage_label;
            GLabel _voltage_value_label;
            GLabel _current_label;
            GLabel _current_value_label;
            GLabel _power_label;
            GLabel _power_value_label;
            GGridList _info_grid_list;
            GRoot _hist_button;
            GRoot _stats_button;
            GHList _button_list;
            GVList _content_list;

            public string technology {
                get { return _tech_value_label.text; }
                set { _tech_value_label.text = value; }
            }

            double _voltage;
            public double voltage {
                get { return _voltage; }
                set {
                    _voltage = value;
                    _voltage_value_label.text = "%.2fV".printf(value);
                    update_current();
                }
            }

            double _power;
            public double power {
                get { return _power; }
                set {
                    _power = value;
                    _power_value_label.text = "%.2fW".printf(value);
                    update_current();
                }
            }

            void update_current() {
                _current_value_label.text = "%.0fmA".printf(power / voltage * 1000);
            }

            public BatteryInfoScreen () {
                _battery_hist_screen = new BatteryHistScreen();
                _battery_stats_screen = new BatteryStatsScreen();

                _title_label = new GLabel("Battery Info");
                _title_underline = new GBox(100, 1);
                _space = new GSpace(2, 5);
                _tech_label = new GLabel("Type:");
                _tech_value_label = new GLabel(UNKNOWN_VALUE);
                _voltage_label = new GLabel("Voltage:");
                _voltage_value_label = new GLabel(UNKNOWN_VALUE);
                _current_label = new GLabel("Current:");
                _current_value_label = new GLabel(UNKNOWN_VALUE);
                _power_label = new GLabel("Power:");
                _power_value_label = new GLabel(UNKNOWN_VALUE);
                _info_grid_list = new GGridList(3);
                _info_grid_list.add(_tech_label);
                _info_grid_list.add(_space);
                _info_grid_list.add(_tech_value_label);
                _info_grid_list.add(_voltage_label);
                _info_grid_list.add(_space);
                _info_grid_list.add(_voltage_value_label);
                _info_grid_list.add(_current_label);
                _info_grid_list.add(_space);
                _info_grid_list.add(_current_value_label);
                _info_grid_list.add(_power_label);
                _info_grid_list.add(_space);
                _info_grid_list.add(_power_value_label);
                _hist_button = new GRoot(_battery_hist_screen, "History");
                _hist_button.font = FontSpec.F0 | FontSpec.HIGHLIGHT;
                _stats_button = new GRoot(_battery_stats_screen, "Stats");
                _stats_button.font = FontSpec.F0 | FontSpec.HIGHLIGHT;
                _stats_button.change_value = 1;
                _button_list = new GHList();
                _button_list.add(_hist_button);
                _button_list.add(_stats_button);
                _content_list = new GVList();
                _content_list.add(_title_label);
                _content_list.add(_title_underline);
                _content_list.add(_space);
                _content_list.add(_info_grid_list);
                _content_list.add(_space);
                _content_list.add(_button_list);
_tech_label.notify.connect((s, p) => { debug("property %s changed", p.name); });
                child = _content_list;
            }
        }

        public class BatteryHistScreen : Screen {
            GLabel _title_label;

            public BatteryHistScreen() {
                _title_label = new GLabel("History");

                child = _title_label;
            }
        }

        public class BatteryStatsScreen : Screen {
            GLabel _title_label;

            public BatteryStatsScreen() {
                _title_label = new GLabel("Statistics");

                child = _title_label;
            }
        }

        public class ShutdownScreen : Screen {
            GButton _shutdown_button;
            GButton _restart_button;
            GSpace _space;
            GVList _content_list;

            public ShutdownScreen() {
                _shutdown_button = new GButton("Shutdown");
                _shutdown_button.font = FontSpec.F0 | FontSpec.HIGHLIGHT | FontSpec.CENTER;
                _shutdown_button.width = 80;
                _shutdown_button.pressed.connect(on_shutdown_button_pressed);
                _restart_button = new GButton("Restart");
                _restart_button.font = FontSpec.F0 | FontSpec.HIGHLIGHT | FontSpec.CENTER;
                _restart_button.width = 80;
                _restart_button.pressed.connect(on_restart_button_pressed);
                _space = new GSpace(0, 5);
                _content_list = new GVList();
                _content_list.add(_shutdown_button);
                _content_list.add(_space);
                _content_list.add(_restart_button);

                child = _content_list;
            }

            void run_command(string command) {
                try {
                    Process.spawn_command_line_sync(command);
                    // TODO: shutdown application - or at least release VT
                } catch (SpawnError err) {
                    warning("%s", err.message);
                    // TODO: handle error
                }
            }

            void on_shutdown_button_pressed() {
              run_command("poweroff");
            }

            void on_restart_button_pressed() {
              run_command("reboot");
            }
        }

        public Power() {
            battery_info_screen = new BatteryInfoScreen();
            shutdown_screen = new ShutdownScreen();

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
            } catch (Error err) {
                warning("%s", err.message);
                // TODO: show error message
            }
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
            unowned U8g.Graphics u8g = gui.m2tk.graphics;

            debug("Drawing graph.");
            for (ushort i = 0; i < battery_hist_data.length; i++)
                u8g.draw_pixel(i, (ushort)(battery_hist_data[i]*20));
        }

        void draw_battery_status_icon()
        {
          unowned U8g.Graphics u8g = gui.m2tk.graphics;

          const ushort batt_width = 20;
          const ushort batt_height = 9;
          const ushort end_y_ofs = 2;
          const ushort end_width = 2;
          ushort x = u8g.get_width() - batt_width - 5;
          const ushort y = 5;

          u8g.draw_frame(x, y, batt_width, batt_height);
          u8g.draw_box(x + batt_width, y + end_y_ofs, end_width,
             batt_height - 2 * end_y_ofs);

           u8g.set_font(U8g.Font.dsg4_04b_03);
           u8g.draw_str(x + 2, y + batt_height - 2, battery_voltage2);
        }

        void update_status(Device device)
        {
            battery_info_screen.technology = Device.technology_to_string(device.technology);
            battery_info_screen.voltage = device.voltage;
            battery_info_screen.power = device.energy_rate;

            battery_voltage2 = "%0.2f".printf(device.voltage);
        }

        void on_device_changed(Device device) {
          var object_path = device.get_object_path();
          debug("changed: %s", object_path);
          //unowned Element root = get_root();
          if (object_path == null)
            return;
          if (EV3_BATTERY_PATH == object_path) {
            //if (gui.statusbar_visible || root == battery_info_root_element)
              update_status(device);
            //if (root == battery_hist_root_element)
              update_battery_hist_data(device);
          }
        }
    }
}
