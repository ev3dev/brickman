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
 * ShutdownScreen.vala:
 *
 * Screen for shutting down/restarting the brick
 */

using M2tk;

namespace BrickDisplayManager {
    public class ShutdownScreen : Screen {
        GButton _shutdown_button;
        GButton _restart_button;
        GSpace _space;
        GVList _content_list;

        public ShutdownScreen() {
            _shutdown_button = new GButton("Shutdown");
            _shutdown_button.font = FontSpec.F0 | FontSpec.HIGHLIGHT | FontSpec.CENTER;
            _shutdown_button.width = 80;
            _shutdown_button.pressed.connect(on_shutdown_button_pressed);
            _restart_button = new GButton("Restart");
            _restart_button.font = FontSpec.F0 | FontSpec.HIGHLIGHT | FontSpec.CENTER;
            _restart_button.width = 80;
            _restart_button.pressed.connect(on_restart_button_pressed);
            _space = new GSpace(0, 5);
            _content_list = new GVList();
            _content_list.add(_shutdown_button);
            _content_list.add(_space);
            _content_list.add(_restart_button);

            child = _content_list;
        }

        void run_command(string command) {
            try {
                Process.spawn_command_line_sync(command);
                // TODO: shutdown application - or at least release VT
            } catch (SpawnError err) {
                warning("%s", err.message);
                // TODO: handle error
            }
        }

        void on_shutdown_button_pressed() {
          run_command("poweroff");
        }

        void on_restart_button_pressed() {
          run_command("reboot");
        }
    }
}
