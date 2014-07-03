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
 * NetworkConnectionsScreen.vala:
 *
 * Monitors network status and performs other network related functions
 */

using Gee;
using M2tk;

namespace BrickDisplayManager {
    class NetworkConnectionsScreen : Screen {
        const uchar MENU_TEXT_WIDTH = 130;
        const uchar MENU_INDICATOR_WIDTH = 20;

        HashMap<Object, NetworkTechnologyItem> technology_map;

        GLabel _title_label;
        GBox _title_underline;
        GSpace _space;
        GLabel _loading_label;
        GLabel _state_label;
        GLabel _state_value_label;
        GHList _state_hlist;
        GAlign _state_align;
        GStrItem _manage_connections_item;
        NetworkTechnologyItem _airplane_mode_item;
        GStrList _menu;
        GVScrollBar _menu_scroll_bar;
        GHList _menu_hlist;
        GVList _status_list;
        GVList _content_list;

        public bool loading {
            get { return _content_list.children.contains(_loading_label); }
            set {
                if (value == loading)
                    return;
                if (value) {
                    var index = _content_list.children.index_of(_status_list);
                    _content_list.children[index] = _loading_label;

                } else {
                    var index = _content_list.children.index_of(_loading_label);
                    _content_list.children[index] = _status_list;
                }
            }
        }

        public string state {
            get { return _state_value_label.text; }
            set { _state_value_label.text = value; }
        }

        public bool airplane_mode {
            get { return _airplane_mode_item.powered; }
            set { _airplane_mode_item.powered = value; }
        }

        public signal void manage_connections_selected ();

        public NetworkConnectionsScreen () {
            technology_map = new HashMap<Object, NetworkTechnologyItem> ();
            _title_label = new GLabel ("Network");
            _title_underline = new GBox (MENU_TEXT_WIDTH + MENU_INDICATOR_WIDTH, 1);
            _space = new GSpace (4, 5);
            _loading_label = new GLabel ("Loading...");
            _state_label = new GLabel ("Status:");
            _state_value_label = new GLabel ("???");
            _state_hlist = new GHList ();
            _state_hlist.children.add (_state_label);
            _state_hlist.children.add (_space);
            _state_hlist.children.add (_state_value_label);
            _state_align = new GAlign (_state_hlist) {
                width = MENU_TEXT_WIDTH + MENU_INDICATOR_WIDTH,
                height = 20
            };
            _manage_connections_item = new GStrItem ("", "Manage connections...");
            _manage_connections_item.selected.connect ((i) =>
                manage_connections_selected ());
            _airplane_mode_item = new NetworkTechnologyItem ("Airplane Mode");
            _airplane_mode_item.notify["powered"].connect ((s, p) => {
                notify_property ("airplane-mode");
            });
            _menu = new GStrList (MENU_INDICATOR_WIDTH) {
                font = FontSpec.F0,
                extra_column_width = MENU_TEXT_WIDTH,
                extra_column_font = FontSpec.F0,
                visible_line_count = 5
            };
            _menu.item_list.add (_manage_connections_item);
            add_technology (_airplane_mode_item, _airplane_mode_item);
            _menu_scroll_bar = new GVScrollBar ();
            _menu_hlist = new GHList ();
            _menu_hlist.children.add (_menu);
            _menu_hlist.children.add (_menu_scroll_bar);
            _status_list = new GVList ();
            _status_list.children.add (_state_align);
            _status_list.children.add (_menu_hlist);
            _content_list = new GVList ();
            _content_list.children.add (_title_label);
            _content_list.children.add (_title_underline);
            _content_list.children.add (_space);
            _content_list.children.add (_loading_label);

            child = _content_list;
        }

        public void add_technology(NetworkTechnologyItem item, Object user_data) {
            technology_map[user_data] = item;
            _menu.item_list.add(item._tech_str_item);
        }

        public bool has_technology (Object user_data) {
            return technology_map.has_key (user_data);
        }

        public bool remove_technology (Object user_data) {
            NetworkTechnologyItem item;
            if (technology_map.unset (user_data, out item)) {
                _menu.item_list.remove (item._tech_str_item);
                return true;
            }
            return false;
        }
    }
}
