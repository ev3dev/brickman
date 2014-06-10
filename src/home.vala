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
 * Home.vala:
 *
 * The home screen for brickdm.
 */

using M2tk;

namespace BrickDisplayManager {

    class Home : Object {

        Power power;

        Element _list_data[2];
        VList _menu_list;
        Align _root_element;
        public unowned Element root_element {
            get { return _root_element; }
        }

        public Home(Power power) {
            debug("initializing Home");
            this.power = power;

            _list_data = {
                //Root.create(network.root_element, "Network"),
                Root.create(power.battery_info_root_element, "Battery"),
                Root.create(power.shutdown_root_element, "Shutdown")
            };
            _menu_list = VList.create(_list_data);
            _root_element = Align.create(_menu_list, DEFAULT_ROOT_ELEMENT_FORMAT);
        }
    }
}
