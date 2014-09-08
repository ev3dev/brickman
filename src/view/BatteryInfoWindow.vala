/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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
 * power.vala:
 *
 * Reads info from the battery and provides functions for displaying
 * that info.
 */

using EV3devKit;

namespace BrickManager {

    public class BatteryInfoWindow : Window {
        const string UNKNOWN_VALUE = "<unk>";

        BatteryHistWindow battery_hist_screen;
        BatteryStatsWindow battery_stats_screen;

        Label title_label;
        Label loading_label;
        Label tech_label;
        Label tech_value_label;
        Label voltage_label;
        Label voltage_value_label;
        Label current_label;
        Label current_value_label;
        Label power_label;
        Label power_value_label;
        Grid info_grid_list;
        Button hist_button;
        Button stats_button;
        Box button_list;
        Box info_vlist;
        Box content_box;

        public bool loading {
            get { return content_box.children.contains (loading_label); }
            set {
                if (value == loading)
                    return;
                if (value) {
                    var index = _content_box.children.index_of (info_vlist);
                    content_box.children[index] = _loading_label;

                } else {
                    var index = _content_box.children.index_of (loading_label);
                    content_box.children[index] = _info_vlist;
                }
            }
        }

        public string technology {
            get { return tech_value_label.text; }
            set { tech_value_label.text = value; }
        }

        double _voltage;
        public double voltage {
            get { return _voltage; }
            set {
                _voltage = value;
                voltage_value_label.text = "%.2fV".printf (value);
                update_current();
            }
        }

        double _power;
        public double power {
            get { return _power; }
            set {
                _power = value;
                power_value_label.text = "%.2fW".printf (value);
                update_current();
            }
        }

        void update_current() {
            current_value_label.text = "%.0fmA".printf (power / voltage * 1000);
        }

        public BatteryInfoWindow () {
            battery_hist_screen = new BatteryHistWindow ();
            battery_stats_screen = new BatteryStatsWindow ();

            title_label = new Label ("Battery Info");
            loading_label = new Label ("Loading...");
            tech_label = new Label ("Type:");
            tech_value_label = new Label (UNKNOWN_VALUE);
            voltage_label = new Label ("Voltage:");
            voltage_value_label = new Label (UNKNOWN_VALUE);
            current_label = new Label ("Current:");
            current_value_label = new Label (UNKNOWN_VALUE);
            power_label = new Label ("Power:");
            power_value_label = new Label (UNKNOWN_VALUE);
            info_grid_list = new Grid (4, 2);
            info_grid_list.children.add (tech_label);
            info_grid_list.children.add (tech_value_label);
            info_grid_list.children.add (voltage_label);
            info_grid_list.children.add (voltage_value_label);
            info_grid_list.children.add (current_label);
            info_grid_list.children.add (current_value_label);
            info_grid_list.children.add (power_label);
            info_grid_list.children.add (power_value_label);
            hist_button = new Button.with_label ("History");
            hist_button.pressd.connect (() =>
                window.screen.push_window (battery_hist_screen));
            stats_button = new Button.with_label ("Stats");
            stats_button.pressd.connect (() =>
                window.screen.push_window (battery_stats_screen));
            button_list = new Box.horizontal ();
            button_list.children.add (hist_button);
            button_list.children.add (stats_button);
            info_vlist = new Box.vertical();
            info_vlist.children.add (info_grid_list);
            info_vlist.children.add (space);
            info_vlist.children.add (button_list);
            content_box = new Box.vertical ();
            content_box.children.add (title_label);
            content_box.children.add (title_underline);
            content_box.children.add (space);
            content_box.children.add (loading_label);

            add (content_box);
        }
    }
}
