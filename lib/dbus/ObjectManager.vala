/*
 * dbus -- vala bindings for d-bus standard interfaces
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

namespace org.freedesktop.DBus {
    [DBus (name = "org.freedesktop.DBus.ObjectManager")]
    public interface ObjectManager : DBusProxy {
        public abstract async HashTable<ObjectPath, HashTable<string, HashTable<string, Variant>>> get_managed_objects () throws IOError;

        public abstract signal void interfaces_added (ObjectPath object_path, HashTable<string, HashTable<string, Variant>> interfaces_and_properties);
        public abstract signal void interfaces_removed (ObjectPath object_path, string[] interfaces);
    }
}