/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2015 David Lechner <david@lechnology.com>
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
 * WifiStatusBarItem.vala:
 *
 * Indicates Wi-Fi connection status
 */

using EV3devKit.UI;
using GRX;

namespace BrickManager {
    public class WifiStatusBarItem : StatusBarItem {
        unowned Context connected_icon;
        unowned Context idle_icon;

        public bool connected { get; set; }

        public WifiStatusBarItem () {
            string file;
            try {
                file = "wifi12x9.png";
                connected_icon = EV3devKit.UI.Icon.create_context_from_png (file);
                file = "wifi-idle12x9.png";
                idle_icon = EV3devKit.UI.Icon.create_context_from_png (file);
            } catch (Error err) {
                critical ("Error loading icon '%s'.", file);
            }
            notify["connected"].connect (redraw);
        }

        public override int draw (int x, StatusBar.Align align) {
            unowned Context icon = connected ? connected_icon : idle_icon;
            if (icon != null) {
                bit_blt (Context.current, x - icon.x_max, 1, icon, 0, 0,
                    icon.x_max, icon.y_max, Color.white.to_image_mode ());
            }
            return icon.x_max;
        }
    }
}
