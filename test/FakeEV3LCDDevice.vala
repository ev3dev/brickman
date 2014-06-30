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
 * FakeEV3LCDDevice.vala:
 *
 * U8g.Device that simulates the EV3 LCD.
 */

using Gee;
using Gtk;
using U8g;

namespace BrickDisplayManager {
    public class FakeEV3LCDDevice : Gtk.Image {
        static HashMap<unowned Device, weak FakeEV3LCDDevice> device_map;

        static construct {
            device_map = new HashMap<unowned Device, weak FakeEV3LCDDevice> ();
        }

        const uint16 WIDTH = 178;
        const uint16 HEIGHT = 128;
        Device _u8g_device;
        PageBuffer buffer;

        public unowned Device u8g_device { get { return _u8g_device; } }
        public bool u8g_active { get; private set; default = false; }

        public FakeEV3LCDDevice () {
            set_from_pixbuf(new Gdk.Pixbuf (Gdk.Colorspace.RGB, false, 8, WIDTH, HEIGHT));
            debug ("width %d", pixbuf.width);
            debug ("height %d", pixbuf.height);
            debug ("rowstride %d", pixbuf.rowstride);
            buffer = new PageBuffer () {
                width = (uint16)pixbuf.width,
                data = pixbuf.pixels
            };
            buffer.page.init(1, (uint16)pixbuf.height);
            _u8g_device = Device.create ((DeviceFunc)u8g_device_func, buffer);
            device_map[_u8g_device] = this;
        }

        ~FakeEV3LCDDevice () {
            device_map.unset (_u8g_device);
        }

        public static FakeEV3LCDDevice from_device (Device device) {
            return device_map[device];
        }

        static uint8 u8g_device_func (Graphics u8g, Device device,
            DeviceMessage msg, void* arg)
        {
            var lcd = from_device (device);
            switch (msg) {

            case DeviceMessage.INIT:
                lcd.u8g_active = true;
                return 1;
            case DeviceMessage.STOP:
                lcd.u8g_active = false;
                return 1;
            case DeviceMessage.PAGE_FIRST:
                lcd.buffer.data = (char *)lcd.pixbuf.pixels;
                break;
            case DeviceMessage.PAGE_NEXT:
                lcd.buffer.data = (char *)lcd.buffer.data + lcd.pixbuf.rowstride;
                break;
            case DeviceMessage.SET_TPIXEL:
            case DeviceMessage.SET_4TPIXEL:
            case DeviceMessage.SET_PIXEL:
            case DeviceMessage.SET_8PIXEL:
                unowned Pixel pixel = (Pixel)arg;
                // m2tk only support 8-bit color, so we have to make it 24
                // red is already set
                pixel.green = pixel.color;
                pixel.blue = pixel.color;
                break;
            }
            return Device.pbxh24_base (u8g, device, msg, arg);
        }
    }
}
