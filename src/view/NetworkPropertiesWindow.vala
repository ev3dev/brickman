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
using EV3devKit;

namespace BrickManager {
    class NetworkPropertiesWindow : BrickManagerWindow {
        Notebook notebook;
        NotebookTab info_tab;
        Grid info_tab_grid;
        CheckButton auto_connect_checkbox;
        Label state_label;
        Label security_label;
        Label strength_label;
        NotebookTab ipv4_tab;
        NotebookTab dns_tab;
        NotebookTab enet_tab;

        public bool auto_connect {
            get { return auto_connect_checkbox.checked; }
            set { auto_connect_checkbox.checked = value; }
        }

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
                strength_label.text = "%u%%".printf (value);
            }
        }

        public NetworkPropertiesWindow (string title) {
            this.title = title;
            notebook = new Notebook () {
                margin_top = 0
            };
            info_tab = new NotebookTab ("Info");
            notebook.add_tab (info_tab);

            info_tab_grid = new Grid (5, 2);
            info_tab.add (info_tab_grid);
            var auto_connect_hbox = new Box.horizontal () {
                horizontal_align = WidgetAlign.CENTER
            };
            info_tab_grid.add_at (auto_connect_hbox, 0, 0, 1, 2);
            auto_connect_hbox.add (new Label ("Auto. Connect:") {
                horizontal_align = WidgetAlign.END
            });
            auto_connect_checkbox = new CheckButton.checkbox () {
                horizontal_align = WidgetAlign.START
            };
            auto_connect_checkbox.notify["checked"].connect (() =>
                notify_property ("auto-connect"));
            auto_connect_hbox.add (auto_connect_checkbox);
            info_tab_grid.add (new Label ("State:") {
                horizontal_align = WidgetAlign.END
            });
            state_label = new Label () {
                horizontal_align = WidgetAlign.START
            };
            info_tab_grid.add (state_label);
            info_tab_grid.add (new Label ("Security:") {
                horizontal_align = WidgetAlign.END
            });
            security_label = new Label () {
                horizontal_align = WidgetAlign.START
            };
            info_tab_grid.add (security_label);
            info_tab_grid.add (new Label ("Strength:") {
                horizontal_align = WidgetAlign.END
            });
            strength_label = new Label () {
                horizontal_align = WidgetAlign.START
            };
            info_tab_grid.add (strength_label);

            ipv4_tab = new NotebookTab ("IPv4");
            notebook.add_tab (ipv4_tab);
            dns_tab = new NotebookTab ("DNS");
            notebook.add_tab (dns_tab);
            enet_tab = new NotebookTab ("Enet");
            notebook.add_tab (enet_tab);

            content_vbox.add (notebook);
        }
    }
}
