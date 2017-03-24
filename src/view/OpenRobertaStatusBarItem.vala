/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2015 Stefan Sauer <ensonic@google.com>
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
 * OpenRobertaStatusBarItem.vala - Indicates connection status
 */

using Ev3devKit.Ui;
using Grx;

namespace BrickManager {
    public class OpenRobertaStatusBarItem : StatusBarItem {
        unowned Context connected_icon;
        unowned Context idle_icon;

        public bool connected { get; set; }

        public OpenRobertaStatusBarItem () {
            visible = false;
            string file;
            try {
                file = Path.build_filename (DATA_DIR, "openroberta-connected16x16.png");
                connected_icon = Ev3devKit.Ui.Icon.create_context_from_png (file);
                file = Path.build_filename (DATA_DIR, "openroberta-idle16x16.png");
                idle_icon = Ev3devKit.Ui.Icon.create_context_from_png (file);
            } catch (GLib.Error err) {
                critical ("Error loading icon '%s'.", file);
            }
            notify["connected"].connect (redraw);
        }

        public override int draw (int x, StatusBar.Align align) {
            unowned Context icon = connected ? connected_icon : idle_icon;
            if (icon != null) {
                Context.current.bit_blt (x - icon.max_x, 2, icon, 0, 0,
                    icon.max_x, icon.max_y, Color.WHITE.to_image_mode ());
                return icon.max_x;
            }
            return -2;
        }
    }
}
