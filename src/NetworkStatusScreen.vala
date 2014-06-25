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
 * NetworkStatusScreen.vala:
 *
 * Monitors network status and performs other network related functions
 */

using M2tk;

namespace BrickDisplayManager {
    class NetworkStatusScreen : Screen {
        GLabel _title_label;
        GBox _title_underline;
        GSpace _space;
        GLabel _running_label;
        GLabel _running_value_label;
        GLabel _networking_enabled_label;
        GToggle _networking_enabled_check_box;
        GLabel _wifi_enabled_label;
        GToggle _wifi_enabled_check_box;
        GGridList _status_grid;
        GVList _content_list;

        public bool networking_enabled {
            get { return _networking_enabled_check_box.checked; }
            set { _networking_enabled_check_box.checked = value; }
        }

        public bool wifi_enabled {
            get { return _wifi_enabled_check_box.checked; }
            set { _wifi_enabled_check_box.checked = value; }
        }

        public NetworkStatusScreen() {
            _title_label = new GLabel("Networking");
            _title_underline = new GBox(100, 1);
            _space = new GSpace(4, 5);
            _running_label = new GLabel("Running:");
            _running_value_label = new GLabel("ERR");
            _networking_enabled_label = new GLabel("Enabled:");
            _networking_enabled_check_box = new GToggle();
            _wifi_enabled_label = new GLabel("Wi-fi On:");
            _wifi_enabled_check_box = new GToggle();
            _wifi_enabled_check_box.notify["checked"].connect((s, p) => {
                notify_property("wifi-enabled");
            });
            _status_grid = new GGridList(3);
            _status_grid.add(_running_label);
            _status_grid.add(_space);
            _status_grid.add(_running_value_label);
            _status_grid.add(_networking_enabled_label);
            _status_grid.add(_space);
            _status_grid.add(_networking_enabled_check_box);
            _status_grid.add(_wifi_enabled_label);
            _status_grid.add(_space);
            _status_grid.add(_wifi_enabled_check_box);
            _content_list = new GVList();
            _content_list.add(_title_label);
            _content_list.add(_title_underline);
            _content_list.add(_space);
            _content_list.add(_status_grid);

            child = _content_list;
        }
    }
}
