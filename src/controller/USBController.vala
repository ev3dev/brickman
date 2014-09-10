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
        const Systemd.UnitActiveState active_states[] = {
            Systemd.UnitActiveState.ACTIVE,
            Systemd.UnitActiveState.RELOADING,
            Systemd.UnitActiveState.ACTIVATING
        };
        const Systemd.UnitActiveState inactive_states[] = {
            Systemd.UnitActiveState.INACTIVE,
            Systemd.UnitActiveState.FAILED,
            Systemd.UnitActiveState.DEACTIVATING
        };
        USBWindow usb_window;
        Systemd.Unit rndis_service;
        Systemd.Unit cdc_service;

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
                rndis_service = yield manager.load_unit ("rndis-gadget.service");
                cdc_service = yield manager.load_unit ("cdc-gadget.service");
                rndis_service.notify["active-state"].connect (on_active_state_changed);
                cdc_service.notify["active-state"].connect (on_active_state_changed);
                on_active_state_changed ();
                usb_window.notify["device-port-service"].connect (on_device_port_service_changed);
                usb_window.loading = false;
            } catch (IOError err) {
                critical (err.message);
            }
        }

        void on_active_state_changed () {
            usb_window.device_port_service_rndis_state = rndis_service.active_state.to_string ().replace ("SYSTEMD_UNIT_ACTIVE_STATE_", "");
            usb_window.device_port_service_cdc_state = cdc_service.active_state.to_string ().replace ("SYSTEMD_UNIT_ACTIVE_STATE_", "");
            if (rndis_service.active_state in active_states)
                usb_window.device_port_service = USBDevicePortService.RNDIS;
            else if (cdc_service.active_state in active_states)
                usb_window.device_port_service = USBDevicePortService.CDC;
            else
                usb_window.device_port_service = USBDevicePortService.NONE;
        }

        void on_device_port_service_changed () {
            switch (usb_window.device_port_service) {
            case USBDevicePortService.RNDIS:
                if (rndis_service.active_state == Systemd.UnitActiveState.INACTIVE
                    || rndis_service.active_state == Systemd.UnitActiveState.FAILED)
                    rndis_service.start.begin ();
                break;
            case USBDevicePortService.CDC:
                if (cdc_service.active_state == Systemd.UnitActiveState.INACTIVE
                        || cdc_service.active_state == Systemd.UnitActiveState.FAILED)
                    cdc_service.start.begin ();
                break;
            case USBDevicePortService.NONE:
                if (rndis_service.active_state == Systemd.UnitActiveState.ACTIVE)
                    rndis_service.stop.begin ();
                if (cdc_service.active_state == Systemd.UnitActiveState.ACTIVE)
                    cdc_service.stop.begin ();
                break;
            }
        }
    }
}