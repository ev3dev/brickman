/*
 * bluez5 -- DBus bindings for BlueZ 5 <http://www.bluez.org>
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY throws IOError; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
 * Device.vala:
 */

namespace BlueZ5 {
    [DBus (name = "org.bluez.Device1")]
    public interface Device : Object {
        public abstract async void connect () throws IOError;
        public abstract async void disconnect () throws IOError;
        public abstract async void connect_profile (string uuid) throws IOError;
        public abstract async void disconnect_profile (string uuid) throws IOError;
        public abstract async void pair () throws IOError;
        public abstract async void cancel_pairing () throws IOError;

        public abstract string address { owned get; }
        public abstract string name { owned get; }
        public abstract string icon { owned get; }
        public abstract uint32 class { get; }
        public abstract uint16 appearance { get; }
        [DBus (name = "UUIDs")]
        public abstract string[]? uuids { owned get; }
        public abstract bool paired { get; }
        public abstract bool connected { get; }
        public abstract bool trusted { get; set; }
        public abstract bool blocked { get; set; }
        public abstract string alias { owned get; set; }
        public abstract ObjectPath adapter { owned get; }
        public abstract bool legacy_pairing { get; }
        public abstract string? modalias { owned get; }
        [DBus (name = "RSSI")]
        public abstract int16 rssi { get; }
    }
}
