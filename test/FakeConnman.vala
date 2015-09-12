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

/* FakeConnman.vala - Fake implementation of ConnMan dbus stuff for testing */

namespace Connman {
    public class Manager {
        public Service get_service (ObjectPath path) {
            return new Service (path);
        }
    }

    public class Service {
        public ObjectPath path { get; private set; }
        public string name { get { return path; } }

        public Service (ObjectPath path) {
            this.path = path;
        }

        public static Service from_path_sync (ObjectPath path) throws IOError {
            return new Service (path);
        }
    }

    public class Peer {
        ObjectPath path { get; private set; }

        public Peer (ObjectPath path) {
            this.path = path;
        }

        public static Peer from_path_sync (ObjectPath path) throws IOError {
            return new Peer (path);
        }
    }
}