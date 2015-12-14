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
 * NetworkConnectionIpv4Window.vala:
 *
 * Displays IPv4 properties of a network connection.
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    class NetworkConnectionIpv4Window : BrickManagerWindow {
        Label method_label;
        Label address_label;
        Label netmask_label;
        Label gateway_label;
        Button change_button;

        public string method {
            get { return method_label.text; }
            set { method_label.text = value; }
        }

        public string address {
            get { return address_label.text; }
            set { address_label.text = value; }
        }

        public string netmask {
            get { return netmask_label.text; }
            set { netmask_label.text = value; }
        }

        public string gateway {
            get { return gateway_label.text; }
            set { gateway_label.text = value; }
        }

        public string config_address { get; set; }
        public string config_netmask { get; set; }
        public string config_gateway { get; set; }

        public signal void change_requested (string method, string? address,
            string? netmask, string? gateway, string[]? dns_addresses);

        public NetworkConnectionIpv4Window (string title) {
            this.title = title;

            //TODO: This doesn't quite fit on the adafruit 1.8" screen

            var grid = new Grid (6, 2);
            content_vbox.add (grid);

            grid.add (new Label ("Method:") {
                margin_right = 18,
                horizontal_align = WidgetAlign.END
            });
            method_label = new Label () {
                margin_left = -12,
                horizontal_align = WidgetAlign.START
            };
            grid.add (method_label);

            grid.add (new Label ("IP address:") {
                margin_right = 18,
                horizontal_align = WidgetAlign.END
            });
            address_label = new Label () {
                margin_left = -12,
                horizontal_align = WidgetAlign.START
            };
            grid.add (address_label);

            grid.add (new Label ("Mask:") {
                margin_right = 18,
                horizontal_align = WidgetAlign.END
            });
            netmask_label = new Label () {
                margin_left = -12,
                horizontal_align = WidgetAlign.START
            };
            grid.add (netmask_label);

            grid.add (new Label ("Gateway:") {
                margin_right = 18,
                horizontal_align = WidgetAlign.END
            });
            gateway_label = new Label () {
                margin_left = -12,
                horizontal_align = WidgetAlign.START
            };
            grid.add (gateway_label);

            change_button = new Button.with_label ("Change...") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            grid.add_at (change_button, 4, 0, 2, 2);
            change_button.pressed.connect (on_change_button_pressed);
        }

        void on_change_button_pressed () {
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;

            var menu = new Ui.Menu () {
                spacing = 3,
                margin = 3
            };
            dialog.add (menu);

            var windows_menu_item = new Ui.MenuItem ("Load Windows defaults");
            windows_menu_item.button.border = 1;
            windows_menu_item.button.border_radius = 3;
            windows_menu_item.label.text_horizontal_align = Grx.TextHorizAlign.CENTER;
            windows_menu_item.button.pressed.connect (() => {
                change_requested ("manual", "192.168.137.3", "255.255.255.0",
                    "192.168.137.1", { "192.168.137.1" });
                weak_dialog.close ();
            });
            menu.add_menu_item (windows_menu_item);

            var mac_menu_item = new Ui.MenuItem ("Load OSX defaults");
            mac_menu_item.button.border = 1;
            mac_menu_item.button.border_radius = 3;
            mac_menu_item.label.text_horizontal_align = Grx.TextHorizAlign.CENTER;
            mac_menu_item.button.pressed.connect (() => {
                change_requested ("manual", "192.168.2.3", "255.255.255.0",
                    "192.168.2.1", { "192.168.2.1" });
                weak_dialog.close ();
            });
            menu.add_menu_item (mac_menu_item);

            var linux_menu_item = new Ui.MenuItem ("Load Linux defaults");
            linux_menu_item.button.border = 1;
            linux_menu_item.button.border_radius = 3;
            linux_menu_item.label.text_horizontal_align = Grx.TextHorizAlign.CENTER;
            linux_menu_item.button.pressed.connect (() => {
                change_requested ("manual", "10.42.0.3", "255.255.255.0",
                    "10.42.0.1", { "10.42.0.1" });
                weak_dialog.close ();
            });
            menu.add_menu_item (linux_menu_item);

            var custom_menu_item = new Ui.MenuItem ("Enter custom values");
            custom_menu_item.button.border = 1;
            custom_menu_item.button.border_radius = 3;
            custom_menu_item.label.text_horizontal_align = Grx.TextHorizAlign.CENTER;
            custom_menu_item.button.pressed.connect (() => {
                weak_dialog.close ();
                on_change_custom_button_pressed ();
            });
            menu.add_menu_item (custom_menu_item);

            var dchp_menu_item = new Ui.MenuItem ("Use DHCP");
            dchp_menu_item.button.border = 1;
            dchp_menu_item.button.border_radius = 3;
            dchp_menu_item.label.text_horizontal_align = Grx.TextHorizAlign.CENTER;
            dchp_menu_item.button.pressed.connect (() => {
                change_requested ("dhcp", null, null, null, { });
                weak_dialog.close ();
            });
            menu.add_menu_item (dchp_menu_item);

            dialog.show ();
        }

        void on_change_custom_button_pressed () {
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var dialog_vscroll = new Scroll.vertical () {
                can_focus = false,
                margin = 3
            };
            dialog.add (dialog_vscroll);
            var dialog_vbox = new Box.vertical ();
            dialog_vscroll.add (dialog_vbox);

            var address_label = new Label ("IP address");
            dialog_vbox.add (address_label);
            var address_entry = new TextEntry (_config_address ?? "");
            var address_entry_notify_has_focus_handler_id =
                address_entry.notify["has-focus"].connect (() => {
                    if (address_entry.has_focus) {
                        dialog_vscroll.scroll_to_child (address_label);
                    }
                });
            dialog_vbox.add (address_entry);
            var netmask_label = new Label ("Network mask");
            dialog_vbox.add (netmask_label);
            var netmask_entry = new TextEntry (_config_netmask ?? "");
            dialog_vbox.add (netmask_entry);
            var netmask_entry_notify_has_focus_handler_id =
                netmask_entry.notify["has-focus"].connect (() => {
                    if (netmask_entry.has_focus) {
                        dialog_vscroll.scroll_to_child (netmask_label);
                        dialog_vscroll.scroll_to_child (netmask_entry);
                    }
                });

            var gateway_label = new Label ("Gateway");
            dialog_vbox.add (gateway_label);
            var gateway_entry = new TextEntry (_config_gateway ?? "");
            dialog_vbox.add (gateway_entry);
            var gateway_entry_notify_has_focus_handler_id =
                gateway_entry.notify["has-focus"].connect (() => {
                    if (gateway_entry.has_focus) {
                        dialog_vscroll.scroll_to_child (gateway_entry);
                    }
                });

            var accept_button = new Button.with_label ("Apply") {
                horizontal_align = WidgetAlign.CENTER,
                margin_top = 3
            };
            var accept_button_notify_has_focus_handler_id =
                accept_button.notify["has-focus"].connect (() => {
                    if (accept_button.has_focus) {
                        dialog_vscroll.scroll_to_child (accept_button);
                    }
                });
            accept_button.pressed.connect (() => {
                // TODO: validate entries and make gateway to be null instead of empty string
                change_requested ("manual", address_entry.text,
                    netmask_entry.text, gateway_entry.text, null);
                weak_dialog.close ();
            });
            dialog_vbox.add (accept_button);
            dialog.weak_ref ((obj) => {
                SignalHandler.disconnect (address_entry,
                    address_entry_notify_has_focus_handler_id);
                SignalHandler.disconnect (netmask_entry,
                    netmask_entry_notify_has_focus_handler_id);
                SignalHandler.disconnect (gateway_entry,
                    gateway_entry_notify_has_focus_handler_id);
                SignalHandler.disconnect (accept_button,
                    accept_button_notify_has_focus_handler_id);
            });
            dialog.show ();
        }
    }
}
