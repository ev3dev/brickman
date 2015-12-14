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
 * NetworkConnectionDnsWindow.vala:
 *
 * Displays DNS properties of a network connection.
 */

using Ev3devKit.Ui;

namespace BrickManager {
    class NetworkConnectionDnsWindow : BrickManagerWindow {
        Box scroll_vbox;

        public string[] addresses {
            owned get {
                var list = new GenericArray<string> ();
                foreach (var child in scroll_vbox.children) {
                    list.add (((Label)child).text);
                }
                return list.data;
            }
            set {
                while (scroll_vbox.child != null) {
                    scroll_vbox.remove (scroll_vbox.child);
                }
                foreach (var address in value) {
                    scroll_vbox.add (new Label (address));
                }
            }
        }

        public signal void change_requested (string[] addresses);

        public NetworkConnectionDnsWindow (string title) {
            this.title = title;

            var addresses_label = new Label ("DNS Addresses:") {
                vertical_align = WidgetAlign.CENTER
            };
            content_vbox.add (addresses_label);
            var scroll = new Scroll.vertical () {
                can_focus = false,
                margin_left = 3,
                margin_right = 3
            };
            content_vbox.add (scroll);

            scroll_vbox = new Box.vertical ();
            scroll.add (scroll_vbox);

            var button_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER,
                margin_top = 2,
                margin_bottom = 3
            };
            content_vbox.add (button_hbox);

            var add_button = new Button.with_label ("Add") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            add_button.pressed.connect (on_add_button_pressed);
            button_hbox.add (add_button);

            var remove_button = new Button.with_label ("Remove All") {
                horizontal_align = WidgetAlign.CENTER,
                vertical_align = WidgetAlign.CENTER
            };
            remove_button.pressed.connect (on_remove_button_pressed);
            button_hbox.add (remove_button);
        }

        void on_add_button_pressed () {
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
                var new_list = new GenericArray<string> ();
                foreach (var addr in addresses) {
                    new_list.add (addr);
                }
                new_list.add (text_entry.text);
                change_requested (new_list.data);
                weak_dialog.close ();
            });
            dialog_vbox.add (add_button);
            dialog.show ();
        }

        void on_remove_button_pressed () {
            change_requested ({ });
        }
    }
}
