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

using EV3devKit.UI;

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
        Systemd.Manager manager;
        Systemd.Unit rndis_service;
        Systemd.Unit cdc_service;

        public string menu_item_text { get { return "USB"; } }
        public Window start_window { get { return usb_window; } }

        public USBController () {
            usb_window = new USBWindow ();
            init.begin ();
        }

        public async void init () {
            try {
                manager = yield Systemd.Manager.get_system_manager ();
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
            usb_window.device_port_service_rndis_state =
                unit_active_state_to_string (rndis_service.active_state);
            usb_window.device_port_service_cdc_state =
                unit_active_state_to_string (cdc_service.active_state);
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
                manager.enable_unit_files.begin ({ rndis_service.id });
                manager.disable_unit_files.begin ({ cdc_service.id });
                break;
            case USBDevicePortService.CDC:
                if (cdc_service.active_state == Systemd.UnitActiveState.INACTIVE
                        || cdc_service.active_state == Systemd.UnitActiveState.FAILED)
                    cdc_service.start.begin ();
                manager.enable_unit_files.begin ({ cdc_service.id });
                manager.disable_unit_files.begin ({ rndis_service.id });
                break;
            case USBDevicePortService.NONE:
                if (rndis_service.active_state == Systemd.UnitActiveState.ACTIVE)
                    rndis_service.stop.begin ();
                if (cdc_service.active_state == Systemd.UnitActiveState.ACTIVE)
                    cdc_service.stop.begin ();
                manager.disable_unit_files.begin ({ rndis_service.id });
                manager.disable_unit_files.begin ({ cdc_service.id });
                break;
            }
        }

        string unit_active_state_to_string (Systemd.UnitActiveState state) {
            switch (state) {
            case Systemd.UnitActiveState.ACTIVE:
                return "Active";
            case Systemd.UnitActiveState.RELOADING:
                return "Reloading";
            case Systemd.UnitActiveState.INACTIVE:
                return "Inactive";
            case Systemd.UnitActiveState.FAILED:
                return "Failed";
            case Systemd.UnitActiveState.ACTIVATING:
                return "Activating";
            case Systemd.UnitActiveState.DEACTIVATING:
                return "Deactivating";
            }
            critical ("Unknown UnitActiveState");
            return "Unknown";
        }
    }
}