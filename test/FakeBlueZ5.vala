/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* FakeBlueZ5.vala - Fake implementation of BlueZ 5 dbus stuff for testing */

namespace BlueZ5 {
    public class Device {
        public ObjectPath path { get; private set; }
        public string name { get { return path; } }
        public string alias { get { return path; } }

        public Device (ObjectPath path) {
            this.path = path;
        }

        public static Device get_for_object_path (ObjectPath path) {
            return new Device (path);
        }
    }
}