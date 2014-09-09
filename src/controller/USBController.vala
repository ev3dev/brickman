/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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

/* USBController.vala - Controller for USB Gadget stuff */

using EV3devKit;

namespace BrickManager {
    public class USBController : Object, IBrickManagerModule {
        USBWindow usb_window;


        public string menu_item_text { get { return "USB Device Port"; } }
        public Window start_window { get { return usb_window; } }

        public USBController () {
            usb_window = new USBWindow ();
            init.begin ();
        }

        /**
         * initalization that requires global systemd object goes here
         */
        public async void init () {
            try {
                var manager = yield Systemd.Manager.get_system_manager ();
                var rndis_service = yield manager.get_unit ("rndis-gadget.service");
                var cdc_service = yield manager.get_unit ("cdc-gadget.service");
                usb_window.notify["device-port-service"].connect (() => {
                    switch (usb_window.device_port_service) {
                    case USBDevicePortService.NONE:
                        break;
                    case USBDevicePortService.RNDIS:
                        break;
                    case USBDevicePortService.CDC:
                        break;
                    }
                });
                usb_window.loading = false;
            } catch (IOError err) {
                critical (err.message);
            }
        }
    }
}