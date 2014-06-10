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

        GButton _battery_menu_item;
        GButton _shutdown_menu_item;
        GVList _menu_list;
        GAlign _root_element;
        public unowned Element root_element {
            get { return _root_element.element; }
        }

        public Home(Power power) {
            debug("initializing Home");
            this.power = power;

            //Root.create(network.root_element, "Network"),
            _battery_menu_item = new GButton("Battery");
            _battery_menu_item.pressed.connect(on_battery_menu_item_pressed);
            _shutdown_menu_item = new GButton("Shutdown");
            _shutdown_menu_item.pressed.connect(on_shutdown_menu_item_pressed);
            _menu_list = new GVList();
            _menu_list.add(_battery_menu_item);
            _menu_list.add(_shutdown_menu_item);
            _root_element = new GAlign(_menu_list);
            _root_element.vertical_alignment = VerticalAlignment.MIDDLE;
            _root_element.horizontal_alignment = HorizontalAlignment.CENTER;
            _root_element.height = 115;
            _root_element.width = 178;
        }

        void on_battery_menu_item_pressed() {
            set_root(power.battery_info_root_element);
        }

        void on_shutdown_menu_item_pressed() {
            set_root(power.shutdown_root_element);
        }
    }
}
