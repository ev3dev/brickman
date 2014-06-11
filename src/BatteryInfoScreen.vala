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
 * power.vala:
 *
 * Reads info from the battery and provides functions for displaying
 * that info.
 */

using M2tk;

namespace BrickDisplayManager {

    public class BatteryInfoScreen : Screen {
        const string UNKNOWN_VALUE = "<unk>";

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

            child = _content_list;
        }
    }
}
