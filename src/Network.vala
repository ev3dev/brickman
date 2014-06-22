/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
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

/*
 * Networking.vala:
 *
 * Monitors network status and performs other network related functions
 */

using M2tk;
using NM;

namespace BrickDisplayManager {
    class Networking {
        Client client;
        public NetworkStatusScreen network_status_screen { get; private set; }

        public Networking() {
            network_status_screen = new NetworkStatusScreen();
            AsyncInitable.new_async.begin(typeof(Client), Priority.DEFAULT, null, (obj, res) => {
                client = (Client)obj;
                client.bind_property("networking-enabled", network_status_screen,
                    "networking-enabled", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                client.bind_property("wireless-enabled", network_status_screen,
                    "wifi-enabled", BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            });
        }
    }
}
