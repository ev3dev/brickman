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
 * AgentManager.vala:
 */

namespace BlueZ5 {
    public class AgentManager : Object {
        internal static AgentManager? instance;

        org.bluez.AgentManager1 dbus_proxy;

        internal AgentManager (DBusProxy proxy) {
            dbus_proxy = (org.bluez.AgentManager1)proxy;
        }

        public async void register_agent (ObjectPath path, AgentManagerCapability capability)
            throws IOError, BlueZError
        {
            yield dbus_proxy.register_agent (path, capability);
        }

        public async void unregister_agent (ObjectPath path)
            throws IOError, BlueZError
        {
            yield dbus_proxy.unregister_agent (path);
        }

        public async void request_default_agent (ObjectPath path)
            throws IOError, BlueZError
        {
            yield dbus_proxy.request_default_agent (path);
        }
    }

    [DBus (use_string_marshalling = true)]
    public enum AgentManagerCapability {
        [DBus (value = "DisplayOnly")]
        DISPLAY_ONLY,
        [DBus (value = "DisplayYesNo")]
        DISPLAY_YES_NO,
        [DBus (value = "KeyboardOnly")]
        KEYBOARD_ONLY,
        [DBus (value = "NoInputNoOutput")]
        NO_INPUT_NO_OUTPUT,
        [DBus (value = "KeyboardDisplay")]
        KEYBOARD_DISPLAY
    }
}

namespace org.bluez {
    [DBus (name = "org.bluez.AgentManager1")]
    public interface AgentManager1 : Object {
        public abstract async void register_agent (ObjectPath agent, BlueZ5.AgentManagerCapability capability) throws IOError, BlueZ5.BlueZError;
        public abstract async void unregister_agent (ObjectPath agent) throws IOError, BlueZ5.BlueZError;
        public abstract async void request_default_agent (ObjectPath agent) throws IOError, BlueZ5.BlueZError;
    }
}
