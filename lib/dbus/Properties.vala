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
    [DBus (name = "org.freedesktop.DBus.Properties")]
    public interface Properties : DBusProxy {
        public abstract async Variant? get (string interface_name, string property_name) throws IOError;
        public abstract async void set (string interface_name, string property_name, Variant? value) throws IOError;
        public abstract async HashTable<string, Variant> get_all (string interface_name) throws IOError;

        public abstract signal void properties_changed (string interface_name, HashTable<string, Variant> changed_properties, string[] invalidated_properties);
    }
}