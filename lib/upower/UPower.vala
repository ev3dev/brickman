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
 * UPower.vala:
 *
 * DBus interface for org.freedesktop.UPower
 */

namespace UPower {

    public const string WELL_KNOWN_NAME = "org.freedesktop.UPower";

    [DBus (name = "org.freedesktop.UPower")]
    interface Client : Object {
        public signal void device_added (ObjectPath device);
        public signal void device_removed(ObjectPath device);
        public signal void device_changed (ObjectPath device);
        public signal void changed ();
        public signal void sleeping ();
        public signal void resuming ();

        public abstract string daemon_version { owned get; }
        public abstract bool can_suspend { get; }
        public abstract bool can_hibernate { get; }
        public abstract bool on_battery { get; }
        public abstract bool on_low_battery { get; }
        public abstract bool lid_is_closed { get; }
        public abstract bool lid_is_present { get; }

        public abstract async ObjectPath[] enumerate_devices () throws IOError;
        public abstract async void about_to_sleep () throws IOError;
        public abstract async void suspend () throws IOError;
        public abstract async bool suspend_allowed () throws IOError;
        public abstract async void hibernate () throws IOError;
        public abstract async bool hibernate_allowed () throws IOError;
    }
}
