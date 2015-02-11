/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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
 * USBWindow.vala:
 *
 * Controls USB device port state
 */

using EV3devKit;
using EV3devKit.UI;

namespace BrickManager {
    public enum USBDevicePortService {
        NONE,
        RNDIS,
        CDC
    }

    public class USBWindow : BrickManagerWindow {
        const string device_port_service_none_tip_text = "Disables USB port";
        const string device_port_service_rndis_tip_text = "For connecting to Windows";
        const string device_port_service_cdc_tip_text = "For connecting to Mac/Linux";
        const string device_port_service_rndis_label_text = "RNDIS (%s)";
        const string device_port_service_cdc_label_text = "CDC (%s)";

        Label device_port_tip_label;
        UI.Menu device_port_service_menu;
        CheckButtonGroup device_port_service_radio_group;
        RadioMenuItem device_port_service_none_menu_item;
        RadioMenuItem device_port_service_rndis_menu_item;
        RadioMenuItem device_port_service_cdc_menu_item;

        public USBDevicePortService device_port_service {
            get {
                var selected = device_port_service_radio_group.selected_item;
                if (selected == null)
                    return USBDevicePortService.NONE;
                return (USBDevicePortService)selected.weak_represented_object;
            }
            set {
                switch (value) {
                case USBDevicePortService.NONE:
                    if (!device_port_service_none_menu_item.radio.checked)
                        device_port_service_none_menu_item.radio.checked = true;
                    break;
                case USBDevicePortService.RNDIS:
                    if (!device_port_service_rndis_menu_item.radio.checked)
                        device_port_service_rndis_menu_item.radio.checked = true;
                    break;
                case USBDevicePortService.CDC:
                    if (!device_port_service_cdc_menu_item.radio.checked)
                        device_port_service_cdc_menu_item.radio.checked = true;
                    break;
                }
            }
        }

        public string device_port_service_rndis_state {
            set {
                device_port_service_rndis_menu_item.label.text =
                    device_port_service_rndis_label_text.printf (value);
            }
        }

        public string device_port_service_cdc_state {
            set  {
                device_port_service_cdc_menu_item.label.text =
                    device_port_service_cdc_label_text.printf (value);
            }
        }

        public signal void network_connections_selected ();

        public USBWindow () {
            title ="USB";
            device_port_service_menu = new UI.Menu () {
                spacing = 2
            };
            content_vbox.add (device_port_service_menu);
            device_port_service_radio_group = new CheckButtonGroup ();
            device_port_service_none_menu_item = new RadioMenuItem (
                "Off", device_port_service_radio_group);
            device_port_service_none_menu_item.button.border = 1;
            device_port_service_none_menu_item.radio.weak_represented_object =
                ((int)USBDevicePortService.NONE).to_pointer ();
            device_port_service_none_menu_item.button.notify["has-focus"].connect (() =>
                device_port_tip_label.text = device_port_service_none_tip_text);
            device_port_service_menu.add_menu_item (device_port_service_none_menu_item);
            device_port_service_rndis_menu_item = new RadioMenuItem (
                device_port_service_rndis_label_text.printf ("???"),
                device_port_service_radio_group);
            device_port_service_rndis_menu_item.button.border = 1;
            device_port_service_rndis_menu_item.radio.weak_represented_object =
                ((int)USBDevicePortService.RNDIS).to_pointer ();
            device_port_service_rndis_menu_item.button.notify["has-focus"].connect (() =>
                device_port_tip_label.text = device_port_service_rndis_tip_text);
            device_port_service_menu.add_menu_item (device_port_service_rndis_menu_item);
            device_port_service_cdc_menu_item = new RadioMenuItem (
                device_port_service_cdc_label_text.printf ("???"),
                device_port_service_radio_group);
            device_port_service_cdc_menu_item.button.border = 1;
            device_port_service_cdc_menu_item.radio.weak_represented_object =
                ((int)USBDevicePortService.CDC).to_pointer ();
            device_port_service_cdc_menu_item.button.notify["has-focus"].connect (() =>
                device_port_tip_label.text = device_port_service_cdc_tip_text);
            device_port_service_menu.add_menu_item (device_port_service_cdc_menu_item);
            device_port_service_radio_group.notify["selected-item"].connect ((s, p) => {
                notify_property ("device-port-service");
            });
            device_port_tip_label = new Label ();
            content_vbox.add (device_port_tip_label);
        }
    }
}
