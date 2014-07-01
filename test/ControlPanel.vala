/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
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
 * ControlPanel.vala:
 *
 * Control Panel for driving FakeEV3LCDDevice
 */

using Gee;
using Gtk;

namespace BrickDisplayManager {
    public class ControlPanel : Gtk.Window {
        const string glade_file = "ControlPanel.glade";

        public CheckButton networking_loading_checkbutton;
        public ComboBoxText connman_state_comboboxtext;
        public CheckButton connman_offline_mode_checkbutton;
        public ListStore connman_technology_liststore;

        public ControlPanel () {
            deletable = false;
            resizable = false;
            gravity = Gdk.Gravity.EAST;

            var builder = new Builder ();
            try {
                builder.add_from_file (glade_file);
                var top_level_widget =
                    builder.get_object ("top_level_widget") as Widget;
                networking_loading_checkbutton =
                    builder.get_object ("networking_loading_checkbutton") as CheckButton;
                connman_state_comboboxtext =
                    builder.get_object ("connman_state_comboboxtext") as ComboBoxText;
                connman_offline_mode_checkbutton =
                    builder.get_object ("connman_offline_mode_checkbutton") as CheckButton;
                connman_technology_liststore =
                    builder.get_object ("connman_technology_liststore") as ListStore;
                var connman_technology_powered_cellrenderertoggle =
                    builder.get_object ("connman_technology_powered_cellrenderertoggle") as CellRendererToggle;
                connman_technology_powered_cellrenderertoggle.toggled.connect (on_cellrenderertoggle_toggled);
                var connman_technology_connected_cellrenderertoggle =
                    builder.get_object ("connman_technology_connected_cellrenderertoggle") as CellRendererToggle;
                connman_technology_connected_cellrenderertoggle.toggled.connect (on_cellrenderertoggle_toggled);
                var quit_button = builder.get_object ("quit_button") as Gtk.Button;
                quit_button.clicked.connect (() => Gtk.main_quit ());
                //builder.connect_signals (this);
                add (top_level_widget);
            } catch (Error err) {
                critical ("ControlPanel init failed: %s", err.message);
            }
        }

        void on_cellrenderertoggle_toggled (CellRendererToggle toggle, string path) {
            foreach(var prop in toggle.get_class().list_properties()) {
                Value val = Value(prop.value_type);
                toggle.get_property(prop.name, ref val);
                debug ("%s - %s", prop.name, val.strdup_contents());
            }
            TreePath tree_path = new TreePath.from_string (path);
            TreeIter iter;
            connman_technology_liststore.get_iter (out iter, tree_path);
            connman_technology_liststore.set (iter, 0, !toggle.active);
        }
    }
}
