/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
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

/* FakeUSBController.vala - Fake Network (ConnMan) controller for testing */

using EV3devKit.UI;

namespace BrickManager {
    public class FakeUSBController : Object, IBrickManagerModule {
        USBWindow usb_window;

        public string menu_item_text { get { return "USB"; } }
        public Window start_window { get { return usb_window; } }

        public FakeUSBController (Gtk.Builder builder) {
            usb_window = new USBWindow ();
            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            usb_window.shown.connect (() => control_panel_notebook.page = (int)ControlPanel.Tab.USB);

            var usb_loading_checkbutton = builder.get_object ("usb_loading_checkbutton") as Gtk.CheckButton;
            usb_loading_checkbutton.bind_property ("active", usb_window, "loading", BindingFlags.SYNC_CREATE);
            var usb_gadget_none_radiobutton = builder.get_object ("usb_gadget_none_radiobutton") as Gtk.RadioButton;
            usb_gadget_none_radiobutton.notify["active"].connect(() => usb_window.device_port_service = USBDevicePortService.NONE);
            var usb_gadget_rndis_radiobutton = builder.get_object ("usb_gadget_rndis_radiobutton") as Gtk.RadioButton;
            usb_gadget_rndis_radiobutton.notify["active"].connect(() => usb_window.device_port_service = USBDevicePortService.RNDIS);
            var usb_gadget_cdc_radiobutton = builder.get_object ("usb_gadget_cdc_radiobutton") as Gtk.RadioButton;
            usb_gadget_cdc_radiobutton.notify["active"].connect(() => usb_window.device_port_service = USBDevicePortService.CDC);
            (builder.get_object ("usb_gadget_rndis_comboboxtext") as Gtk.ComboBoxText)
                .bind_property ("active-id", usb_window, "device-port-service-rndis-state", BindingFlags.SYNC_CREATE);
            (builder.get_object ("usb_gadget_cdc_comboboxtext") as Gtk.ComboBoxText)
                .bind_property ("active-id", usb_window, "device-port-service-cdc-state", BindingFlags.SYNC_CREATE);
            usb_window.notify["device-port-service"].connect (() => {
                switch (usb_window.device_port_service) {
                case USBDevicePortService.NONE:
                    if (!usb_gadget_none_radiobutton.active)
                        usb_gadget_none_radiobutton.active = true;
                    break;
                case USBDevicePortService.RNDIS:
                    if (!usb_gadget_rndis_radiobutton.active)
                        usb_gadget_rndis_radiobutton.active = true;
                    break;
                case USBDevicePortService.CDC:
                    if (!usb_gadget_cdc_radiobutton.active)
                        usb_gadget_cdc_radiobutton.active = true;
                    break;
                }
            });
            usb_window.device_port_service = USBDevicePortService.NONE;
        }
    }
}