/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2015 Stefan Sauer <ensonic@google.com>
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
 * OpenRobertaWindow.vala - Edit connection status
 *
 * If not connected (initiallly)
 * - A list of entries:
 *   lab.open-roberta.org
 *   10.0.1.10:1999 (usb?)
 *   user-definable
 *   Another (type in)
 *
 * If selected 'another'
 * - dialog to enter ip+port
 * - we could be clever and suggest the network part of the ev3's ip already and
 *   have the port ":1999" there too
 *
 * When selected an address or after typing the new address
 * - service.connect(address) and show pairing code
 *
 * Once connected
 * - show disconnect button
 *
 * Once disconnected or if connection lost
 * - go back to start
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class OpenRobertaWindow : BrickManagerWindow {
        internal Label info;
        internal Ui.Menu menu;
        internal Ui.MenuItem public_server;
        internal Ui.MenuItem local_server;
        internal Ui.MenuItem custom_server;
        internal Ui.MenuItem config_custom;
        internal Ui.MenuItem disconnect_server;

        public bool connected { get; set; default = false; }
        public string selected_server { get; set; default = null; }

        public OpenRobertaWindow () {
            title = "Open Roberta Lab";

            info = new Label ();
            content_vbox.add (info);

            menu = new Ui.Menu () {
                spacing = 2
            };
            content_vbox.add (menu);

            public_server = new Ui.MenuItem ("lab.open-roberta.org");
            // FIXME: this is lejos usb specific, remove?
            local_server = new Ui.MenuItem ("10.0.1.10:1999");
            custom_server = new Ui.MenuItem ("custom server");
            config_custom = new Ui.MenuItem ("Edit \"custom server\" ...");
            disconnect_server = new Ui.MenuItem ("Disconnect");

            notify["connected"].connect (on_connected_changed);
            on_connected_changed ();
        }

        void on_connected_changed () {
            menu.remove_all_menu_items ();
            if (!connected) {
                info.text = "Select which server to use:";
                menu.add_menu_item (public_server);
                menu.add_menu_item (local_server);
                menu.add_menu_item (custom_server);
                menu.add_menu_item (config_custom);
                if (selected_server == local_server.label.text) {
                    local_server.button.focus ();
                } else if (selected_server == custom_server.label.text) {
                    custom_server.button.focus ();
                } else {
                    public_server.button.focus ();
                }
            } else {
                info.text = "Connected to\n" + selected_server;
                menu.add_menu_item (disconnect_server);
                disconnect_server.button.focus ();
            }
        }
    }
}
