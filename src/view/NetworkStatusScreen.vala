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

using Gee;
using M2tk;

namespace BrickDisplayManager {
    class NetworkStatusScreen : Screen {
        const uchar GRID_COL1_WIDTH = 100;
        const uchar GRID_COL2_WIDTH = 50;

        HashMap<Object, NetworkTechnologyItem> technology_map;

        GLabel _title_label;
        GBox _title_underline;
        GSpace _space;
        GLabel _loading_label;
        GLabel _state_label;
        GLabel _state_value_label;
        GLabel _airplane_mode_label;
        GToggle _airplane_mode_check_box;
        GGridList _status_grid;
        GVList _content_list;

        public bool loading {
            get { return _content_list.children.contains(_loading_label); }
            set {
                if (value == loading)
                    return;
                if (value) {
                    var index = _content_list.children.index_of(_status_grid);
                    _content_list.children[index] = _loading_label;

                } else {
                    var index = _content_list.children.index_of(_loading_label);
                    _content_list.children[index] = _status_grid;
                }
            }
        }

        public string state {
            get { return _state_value_label.text; }
            set { _state_value_label.text = value; }
        }

        public bool airplane_mode {
            get { return _airplane_mode_check_box.checked; }
            set { _airplane_mode_check_box.checked = value; }
        }

        public NetworkStatusScreen() {
            technology_map = new HashMap<Object, NetworkTechnologyItem>();
            _title_label = new GLabel("Networking");
            _title_underline = new GBox(GRID_COL1_WIDTH + GRID_COL2_WIDTH, 1);
            _space = new GSpace(4, 5);
            _loading_label = new GLabel("Loading...");
            _state_label = new GLabel("Status");
            _state_label.width = GRID_COL1_WIDTH;
            _state_value_label = new GLabel("???");
            _state_value_label.width = GRID_COL2_WIDTH;
            _airplane_mode_label = new GLabel("Airplane Mode");
            _airplane_mode_label.width = GRID_COL1_WIDTH;
            _airplane_mode_check_box = new GToggle();
            _airplane_mode_check_box.width = GRID_COL2_WIDTH;
            _airplane_mode_check_box.notify["checked"].connect((s, p) => {
                notify_property("airplane-mode");
            });
            _status_grid = new GGridList(2);
            _status_grid.children.add(_state_label);
            _status_grid.children.add(_state_value_label);
            _status_grid.children.add(_airplane_mode_label);
            _status_grid.children.add(_airplane_mode_check_box);
            _content_list = new GVList();
            _content_list.children.add(_title_label);
            _content_list.children.add(_title_underline);
            _content_list.children.add(_space);
            _content_list.children.add(_loading_label);

            child = _content_list;
        }

        public void add_technology(NetworkTechnologyItem item, Object user_data) {
            technology_map[user_data] = item;
            item._tech_name_label.width = GRID_COL1_WIDTH;
            _status_grid.children.add(item._tech_name_label);
            item._powered_check_box.width = GRID_COL2_WIDTH;
            _status_grid.children.add(item._powered_check_box);
        }
    }
}
