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
 * MotorValueDialog.vala: Main Device Browser Menu
 */

using Ev3devKit.Ui;

namespace BrickManager {
    public class MotorValueDialog : Dialog {
        Label value_label;

        public string value_text {
            get { return value_label.text; }
            set { value_label.text = value; }
        }

        public MotorValueDialog () {
            value_label = new Label ("???") {
                margin = 12
            };
            value_label.font = Fonts.get_big ();
            add (value_label);
        }
    }
}
