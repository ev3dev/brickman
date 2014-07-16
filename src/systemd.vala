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
 * systemd.vala:
 *
 * Interactions with systemd
 */

namespace BrickDisplayManager {

    class Systemd {
        internal org.freedesktop.login1.Manager logind_manager;

        public static async Systemd new_async () {
            var instance = new Systemd ();
            instance.init.begin ((obj, res) => {
                try {
                    instance.init.end (res);

                } catch (IOError err) {
                    critical (err.message);
                }
            });
            return instance;
        }

        async void init () throws IOError {
            logind_manager = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.login1.SERVICE_NAME,
                org.freedesktop.login1.Manager.OBJECT_PATH);
        }
    }
}
