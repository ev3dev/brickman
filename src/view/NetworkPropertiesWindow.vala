/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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
 * NetworkPropertiesWindow.vala:
 *
 * Displays properties of a network connection.
 */

using Gee;
using EV3devKit.UI;

namespace BrickManager {
    class NetworkPropertiesWindow : BrickManagerWindow {
        Notebook notebook;
        NotebookTab connection_tab;
        Label state_label;
        Label security_label;
        Label strength_label;
        CheckButton auto_connect_checkbox;
        Box connect_vbox;
        Button connect_button;
        Label connect_busy_label;
        NotebookTab ipv4_tab;
        Label ipv4_method_label;
        Label ipv4_address_label;
        Label ipv4_netmask_label;
        Label ipv4_gateway_label;
        Button ipv4_change_button;
        NotebookTab dns_tab;
        Scroll dns_scroll;
        NotebookTab enet_tab;
        Label enet_method_label;
        Label enet_interface_label;
        Label enet_address_label;
        Label enet_mtu_label;

        public string state {
            get { return state_label.text; }
            set { state_label.text = value; }
        }

        public string security {
            get { return security_label.text; }
            set { security_label.text = value; }
        }

        uchar _strength;
        public uchar strength {
            get { return _strength; }
            set {
                _strength = value;
                if (value == 0)
                    strength_label.text = "N/A";
                else
                    strength_label.text = "%u%%".printf (value);
            }
        }

        public bool auto_connect {
            get { return auto_connect_checkbox.checked; }
            set { auto_connect_checkbox.checked = value; }
        }

        bool _is_connected;
        public bool is_connected {
            get { return _is_connected; }
            set {
                if (value)
                    ((Label)connect_button.child).text = "Disconnect";
                else
                    ((Label)connect_button.child).text = "Connect";
                _is_connected = value;
            }
        }

        bool _is_connect_busy;
        public bool is_connect_busy {
            get { return _is_connect_busy; }
            set {
                if (value) {
                    connect_vbox.remove (connect_button);
                    connect_vbox.add (connect_busy_label);
                } else {
                    connect_vbox.remove (connect_busy_label);
                    connect_vbox.add (connect_button);
                }
                _is_connect_busy = value;
            }
        }

        public string ipv4_method {
            get { return ipv4_method_label.text; }
            set { ipv4_method_label.text = value; }
        }

        public string ipv4_address {
            get { return ipv4_address_label.text; }
            set { ipv4_address_label.text = value; }
        }

        public string ipv4_netmask {
            get { return ipv4_netmask_label.text; }
            set { ipv4_netmask_label.text = value; }
        }

        public string ipv4_gateway {
            get { return ipv4_gateway_label.text; }
            set { ipv4_gateway_label.text = value; }
        }

        public string ipv4_config_address { get; set; }
        public string ipv4_config_netmask { get; set; }
        public string ipv4_config_gateway { get; set; }

        public string[] dns_addresses {
            owned get {
                var list = new Gee.ArrayList<string> ();
                foreach (var child in dns_scroll.children)
                    list.add (((Label)child).text);
                return list.to_array ();
            }
            set {
                foreach (var child in dns_scroll.children)
                    dns_scroll.remove (child);
                foreach (var address in value)
                    dns_scroll.add (new Label (address));
            }
        }

        public string enet_method {
            get { return enet_method_label.text; }
            set { enet_method_label.text = value; }
        }

        public string enet_interface {
            get { return enet_interface_label.text; }
            set { enet_interface_label.text = value; }
        }

        public string enet_address {
            get { return enet_address_label.text; }
            set { enet_address_label.text = value; }
        }

        int _enet_mtu;
        public int enet_mtu {
            get { return _enet_mtu; }
            set {
                _enet_mtu = value;
                enet_mtu_label.text = "%d".printf (value);
            }
        }

        /**
         * Connect/disconnect requested
         *
         * User pressed the Connect/Disconnect button on the Connection tab
         */
        public signal void connect_requested (bool disconnect);

        public signal void dns_change_requested (string[] addresses);

        public signal void ipv4_change_requested (string method, string? address,
            string? netmask, string? gateway);

        public NetworkPropertiesWindow (string title) {
            this.title = title;
            notebook = new Notebook () {
                margin_top = 0
            };

            /* Connection Tab */

            connection_tab = new NotebookTab ("Conn.");
            notebook.add_tab (connection_tab);
            var connection_tab_grid = new Grid (6, 2);
            connection_tab.add (connection_tab_grid);
            connection_tab_grid.add (new Label ("State:") {
                horizontal_align = WidgetAlign.END,
                font = small_font,
                margin_right = 4
            });
            state_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            connection_tab_grid.add (state_label);
            connection_tab_grid.add (new Label ("Security:") {
                horizontal_align = WidgetAlign.END,
                font = small_font,
                margin_right = 4
            });
            security_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            connection_tab_grid.add (security_label);
            connection_tab_grid.add (new Label ("Strength:") {
                horizontal_align = WidgetAlign.END,
                font = small_font,
                margin_right = 4
            });
            strength_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            connection_tab_grid.add (strength_label);
            var auto_connect_vbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER
            };
            connection_tab_grid.add_at (auto_connect_vbox, 3, 0, 1, 2);
            auto_connect_vbox.add (new Label ("Connect automatically:") {
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            auto_connect_checkbox = new CheckButton.checkbox () {
                horizontal_align = WidgetAlign.START,
                margin_bottom = -2
            };
            auto_connect_checkbox.notify["checked"].connect (() =>
                notify_property ("auto-connect"));
            auto_connect_vbox.add (auto_connect_checkbox);
            var connect_hbox = new Box.horizontal ();
            connection_tab_grid.add_at (connect_hbox, 4, 0, 2, 2);
            connect_vbox = new Box.vertical () {
                vertical_align = WidgetAlign.CENTER
            };
            connect_hbox.add (connect_vbox);
            connect_button = new Button.with_label ("Connect") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER,
                margin = 3
            };
            connect_button.pressed.connect (on_connect_button_pressed);
            connect_vbox.add (connect_button);
            connect_busy_label = new Label ("Busy");

            /* IPv4 Tab */

            ipv4_tab = new NotebookTab ("IPv4");
            notebook.add_tab (ipv4_tab);
            var ipv4_grid = new Grid (6, 2);
            ipv4_tab.add (ipv4_grid);
            ipv4_grid.add (new Label ("Method:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            ipv4_method_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            ipv4_grid.add (ipv4_method_label);
            ipv4_grid.add (new Label ("IP address:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            ipv4_address_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            ipv4_grid.add (ipv4_address_label);
            ipv4_grid.add (new Label ("Mask:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            ipv4_netmask_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            ipv4_grid.add (ipv4_netmask_label);
            ipv4_grid.add (new Label ("Gateway:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            ipv4_gateway_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            ipv4_grid.add (ipv4_gateway_label);
            ipv4_change_button = new Button.with_label ("Change...") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            ipv4_change_button.pressed.connect (on_ipv4_change_button_pressed);
            ipv4_grid.add_at (ipv4_change_button, 4, 0, 2, 2);

            /* DNS Tab */

            dns_tab = new NotebookTab ("DNS");
            notebook.add_tab (dns_tab);
            var dns_vbox = new Box.vertical ();
            dns_tab.add (dns_vbox);
            var dns_addresses_label = new Label ("Addresses:") {
                vertical_align = WidgetAlign.CENTER
            };
            dns_vbox.add (dns_addresses_label);
            dns_scroll = new Scroll.vertical () {
                can_focus = false,
                margin_left = 3,
                margin_right = 3
            };
            dns_vbox.add (dns_scroll);
            var dns_button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER,
                margin_top = 2,
                margin_bottom = 3
            };
            dns_vbox.add (dns_button_hbox);
            var dns_add_button = new Button.with_label ("Add") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            dns_add_button.pressed.connect (on_dns_add_button_pressed);
            dns_button_hbox.add (dns_add_button);
            var dns_remove_button = new Button.with_label ("Remove All") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            dns_remove_button.pressed.connect (on_dns_remove_button_pressed);
            dns_button_hbox.add (dns_remove_button);

            /* Enet Tab */

            enet_tab = new NotebookTab ("Enet");
            notebook.add_tab (enet_tab);
            var enet_grid = new Grid (6, 2);
            enet_tab.add (enet_grid);
            enet_grid.add (new Label ("Method:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            enet_method_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            enet_grid.add (enet_method_label);
            enet_grid.add (new Label ("Interface:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            enet_interface_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            enet_grid.add (enet_interface_label);
            enet_grid.add (new Label ("MAC address:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            enet_address_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            enet_grid.add (enet_address_label);
            enet_grid.add (new Label ("MTU:") {
                margin_right = 4,
                horizontal_align = WidgetAlign.END,
                font = small_font
            });
            enet_mtu_label = new Label () {
                horizontal_align = WidgetAlign.START,
                font = small_font
            };
            enet_grid.add (enet_mtu_label);

            content_vbox.add (notebook);
        }

        void on_connect_button_pressed () {
            if (!_is_connect_busy)
                connect_requested (_is_connected);
        }

        void on_ipv4_change_button_pressed () {
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var button_vbox = new Box.vertical () {
                margin = 4
            };
            dialog.add (button_vbox);
            var windows_button = new Button.with_label ("Load Windows defaults", small_font) {
                padding_top = -1
            };
            windows_button.pressed.connect (() => {
                ipv4_change_requested ("manual", "192.168.137.3", "255.255.255.0", "192.168.137.1");
                dns_change_requested ({ "192.168.137.1" });
                weak_dialog.close ();
            });
            button_vbox.add (windows_button);
            var mac_button = new Button.with_label ("Load Mac defaults", small_font) {
                padding_top = -1
            };
            mac_button.pressed.connect (() => {
                ipv4_change_requested ("manual", "192.168.2.3", "255.255.255.0", "192.168.2.1");
                dns_change_requested ({ "192.168.2.1" });
                weak_dialog.close ();
            });
            button_vbox.add (mac_button);
            var linux_button = new Button.with_label ("Load Linux defaults", small_font) {
                padding_top = -1
            };
            linux_button.pressed.connect (() => {
                ipv4_change_requested ("manual", "10.42.0.3", "255.255.255.0", "10.42.0.1");
                dns_change_requested ({ "10.42.0.1" });
                weak_dialog.close ();
            });
            button_vbox.add (linux_button);
            var custom_button = new Button.with_label ("Enter custom values", small_font) {
                padding_top = -1
            };
            custom_button.pressed.connect (() => {
                weak_dialog.close ();
                on_ipv4_change_custom_button_pressed ();
            });
            button_vbox.add (custom_button);
            var dchp_button = new Button.with_label ("Use DHCP", small_font) {
                padding_top = -1
            };
            dchp_button.pressed.connect (() => {
                ipv4_change_requested ("dhcp", null, null, null);
                dns_change_requested ({ });
                weak_dialog.close ();
            });
            button_vbox.add (dchp_button);
            dialog.show ();
        }

        void on_ipv4_change_custom_button_pressed () {
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var dialog_vscroll = new Scroll.vertical () {
                can_focus = false,
                margin = 3,
                border = 0
            };
            dialog.add (dialog_vscroll);
            var dialog_vbox = new Box.vertical ();
            dialog_vscroll.add (dialog_vbox);
            var address_label = new Label ("IP address");
            dialog_vbox.add (address_label);
            var address_entry = new TextEntry (_ipv4_config_address ?? "");
            var address_entry_notify_has_focus_handler_id =
                address_entry.notify["has-focus"].connect (() => {
                    if (address_entry.has_focus)
                        dialog_vscroll.scroll_to_child (address_label);
                });
            dialog_vbox.add (address_entry);
            var netmask_label = new Label ("Network mask");
            dialog_vbox.add (netmask_label);
            var netmask_entry = new TextEntry (_ipv4_config_netmask ?? "");
            dialog_vbox.add (netmask_entry);
            var gateway_label = new Label ("Gateway");
            dialog_vbox.add (gateway_label);
            var gateway_entry = new TextEntry (_ipv4_config_gateway ?? "");
            dialog_vbox.add (gateway_entry);
            var accept_button = new Button.with_label ("Apply") {
                horizontal_align = WidgetAlign.CENTER,
                margin_top = 3
            };
            var accept_button_notify_has_focus_handler_id =
                accept_button.notify["has-focus"].connect (() => {
                    if (accept_button.has_focus)
                        dialog_vscroll.scroll_to_child (accept_button);
                });
            accept_button.pressed.connect (() => {
                // TODO: validate entries and make gateway to be null instead of empty string
                ipv4_change_requested ("manual", address_entry.text,
                    netmask_entry.text, gateway_entry.text);
                weak_dialog.close ();
            });
            dialog_vbox.add (accept_button);
            dialog.weak_ref ((obj) => {
                SignalHandler.disconnect (address_entry,
                    address_entry_notify_has_focus_handler_id);
                SignalHandler.disconnect (accept_button,
                    accept_button_notify_has_focus_handler_id);
            });
            dialog.show ();
        }

        void on_dns_add_button_pressed () {
            var dialog = new Dialog ();
            weak Dialog weak_dialog = dialog;
            var dialog_vbox = new Box.vertical () {
                spacing = 6,
                margin = 3
            };
            dialog.add (dialog_vbox);
            var message_label = new Label ("Enter DNS address.");
            dialog_vbox.add (message_label);
            var text_entry = new TextEntry ();
            dialog_vbox.add (text_entry);
            dialog_vbox.add (new Spacer ());
            var add_button = new Button.with_label ("Add") {
                horizontal_align = WidgetAlign.CENTER
            };
            add_button.pressed.connect (() => {
                // TODO: validate values
                var new_list = new Gee.ArrayList<string> ();
                new_list.add_all_array (dns_addresses);
                new_list.add (text_entry.text);
                dns_change_requested (new_list.to_array ());
                weak_dialog.close ();
            });
            dialog_vbox.add (add_button);
            dialog.show ();
        }

        void on_dns_remove_button_pressed () {
            dns_change_requested ({ });
        }
    }
}
