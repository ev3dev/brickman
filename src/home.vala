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
 * home.vala:
 *
 * The home screen for brickdm.
 */

namespace BrickDisplayManager {

    class Home : Object {

        Power power = new Power();

        public Home() {
            _list_data = {
                //M2tk.Root.create(network.root_element, "Network"),
                M2tk.Root.create(power.battery_info_root_element, "Battery"),
                M2tk.Root.create(power.shutdown_root_element, "Shutdown")
            };
            _root_element = M2tk.VList.create(_list_data);
            //root_element.text = "text2";
        }

        M2tk.Element _list_data[2];
        M2tk.VList _root_element;
        public unowned M2tk.VList root_element {
            get { return _root_element; }
        }
    }
/*
    m2_xmenu_entry main_menu_data[] = {
        { "Network", &brickdm_network_root, NULL },
        { "Battery", &brickdm_battery_root, NULL },
        { "Shutdown", &brickdm_shutdown_root, NULL },
        { NULL, NULL, NULL }
    };

    uchar main_menu_first = 0;
    uchar main_menu_cnt = 6;

    M2_X2LMENU(main_menu, "l7e20W42", ref main_menu_first, ref main_menu_cnt,
               main_menu_data, '+', '-', '\0');
    M2_SPACE(main_menu_space, "W1h1");
    M2_VSB(main_menu_scroll, "l4w4r1", ref main_menu_first, ref main_menu_cnt);
    M2_LIST(main_menu_list_data) = { &main_menu, &main_menu_space, &main_menu_scroll };
    M2_HLIST(main_menu_hlist, NULL, main_menu_list_data);
    M2_ALIGN(brickdm_home_root, DEFAULT_ROOT_ELEMENT_FORMAT, &main_menu_hlist);
*/
}
