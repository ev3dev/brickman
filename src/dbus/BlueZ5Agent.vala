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

/* BlueZ5Agent.vala - BlueZ 5 Agent implementation */

using EV3devKit;
using BlueZ5;

namespace BrickManager {
    [DBus (name = "org.bluez.Agent1")]
    public class BlueZ5Agent : Object {
        Screen screen;

        signal void canceled ();

        public BlueZ5Agent (Screen screen) {
            this.screen = screen;
        }

        public async void release () {
            critical ("Released.");
        }

        public async void request_pin_code (ObjectPath device_path)
            throws BlueZ5Error
        {
            var device = Device.get_for_object_path (device_path);
            //var dialog = new Dialog ();
            throw new BlueZ5Error.CANCELED ("Not implemented.");
        }

        public async void display_pin_code (ObjectPath device_path, string pincode)
            throws BlueZ5Error
        {
            var device = Device.get_for_object_path (device_path);
            var dialog = new MessageDialog ("Bluetooth", 
                "Pincode for %s:\n\n%s".printf (device.alias, pincode));
            weak MessageDialog weak_dialog = dialog;
            var user_canceled = false;
            var signal_id = canceled.connect(() => {
                screen.close_window (dialog);
                display_pin_code.callback ();
            });
            screen.show_window (dialog);
            yield;
            SignalHandler.disconnect (this, signal_id);
            // TODO: get user feedback for rejected
            //throw new BlueZ5Error.REJECTED ("User rejected request.");
        }

        public async void cancel () {
            canceled ();
        }
    }

    [DBus (name = "org.bluez.Error")]
    public errordomain BlueZ5Error {
        REJECTED,
        CANCELED
    }
}