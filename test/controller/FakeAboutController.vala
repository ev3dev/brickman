/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* FakeAboutController.vala - Fake About controller for testing */

using Ev3devKit.Ui;

namespace BrickManager {
    public class FakeAboutController : Object, IBrickManagerModule {
        Gtk.Notebook control_panel_notebook;
        Gtk.Entry kernel_version_entry;
        Gtk.Entry cpuinfo_model_entry;
        Gtk.Entry cpuinfo_revision_entry;
        Gtk.Entry cpuinfo_serial_number_entry;

        public string display_name { get { return "About"; } }

        public FakeAboutController (Gtk.Builder builder) {

            control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            kernel_version_entry = builder.get_object ("about-kernel-version-entry") as Gtk.Entry;
            cpuinfo_model_entry = builder.get_object ("about-cpuinfo-model-entry") as Gtk.Entry;
            cpuinfo_revision_entry = builder.get_object ("about-cpuinfo-revision-entry") as Gtk.Entry;
            cpuinfo_serial_number_entry = builder.get_object ("about-cpuinfo-serial-number-entry") as Gtk.Entry;
            var utsname = Posix.UTSName ();
            if (Posix.uname (ref utsname) == 0) {
                kernel_version_entry.text = utsname.release;
            } else {
                critical ("Failed to get kernel version.");
            }
            cpuinfo_model_entry.text = "Gtk Desktop";
            cpuinfo_revision_entry.text = "0000";
            cpuinfo_serial_number_entry.text = "0000000000000000";
        }

        public void show_main_window () {
            var about_window = new AboutWindow (display_name);

            about_window.shown.connect (() =>
                control_panel_notebook.page = (int)ControlPanel.Tab.ABOUT);

            kernel_version_entry.bind_property ("text", about_window,
                "kernel-version", BindingFlags.SYNC_CREATE);
            cpuinfo_model_entry.bind_property ("text", about_window,
                "model-name", BindingFlags.SYNC_CREATE);
            cpuinfo_revision_entry.bind_property ("text", about_window,
                "revision", BindingFlags.SYNC_CREATE);
            cpuinfo_serial_number_entry.bind_property ("text", about_window,
                "serial-number", BindingFlags.SYNC_CREATE);

            about_window.weak_ref (() => message ("about_window disposed."));
            about_window.show ();
        }
    }
}
