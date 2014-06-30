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
    public class FakeEV3LCDDevice : DrawingArea {
        static HashMap<unowned Device, weak FakeEV3LCDDevice> device_map;

        static construct {
            device_map = new HashMap<unowned Device, weak FakeEV3LCDDevice> ();
        }

        const uint16 WIDTH = 178;
        const uint16 HEIGHT = 128;
        Device _u8g_device;

        public unowned Device u8g_device { get { return _u8g_device; } }
        public bool u8g_active { get; private set; default = false; }
        internal Cairo.Context drawing_context { get; set; }

        public FakeEV3LCDDevice () {
            _u8g_device = Device.create ((DeviceFunc)u8g_device_func, null);
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
            debug ("%s", msg.to_string ());
            switch (msg) {

            case DeviceMessage.INIT:
                lcd.u8g_active = true;
                break;
            case DeviceMessage.STOP:
                lcd.u8g_active = false;
                break;
            case DeviceMessage.CONTRAST:
                break;
            case DeviceMessage.SLEEP_ON:
                break;
            case DeviceMessage.SLEEP_OFF:
                break;
            case DeviceMessage.PAGE_FIRST:
                // TODO: clear graphics?
                break;
            case DeviceMessage.PAGE_NEXT:
                return 0;
            case DeviceMessage.GET_PAGE_BOX:
                unowned U8g.Box box = (U8g.Box)arg;
                box.x0 = 0;
                box.y0 = 0;
                box.x1 = WIDTH;
                box.y1 = HEIGHT;
                break;
            case DeviceMessage.SET_TPIXEL:
                break;
            case DeviceMessage.SET_4TPIXEL:
                break;
            case DeviceMessage.SET_PIXEL:
                unowned Pixel pixel = (Pixel)arg;
                lcd.draw_pixel (pixel);
                break;
            case DeviceMessage.SET_8PIXEL:
                unowned Pixel pixel = (Pixel)arg;
                lcd.draw_8_pixel (pixel);
                break;
            case DeviceMessage.SET_COLOR_ENTRY:
                break;
            case DeviceMessage.SET_XY_CB:
                break;
            case DeviceMessage.GET_WIDTH:
                *(uint16*)arg = WIDTH;
                break;
            case DeviceMessage.GET_HEIGHT:
                *(uint16*)arg = HEIGHT;
                break;
            case DeviceMessage.GET_MODE:
                return (uint8)U8g.Mode.BW;
            }
            return 1;
        }

        void set_color (Pixel pixel) {
            var color = (double)pixel.color;
            color = 0.1;
            debug ("color %f", color);
            drawing_context.set_source_rgb (color, color, color);
        }

        void draw_pixel (Pixel pixel) {
            if (pixel.x >= get_allocated_width ())
                return;
            if (pixel.y >= get_allocated_height ())
                return;

            set_color (pixel);
            drawing_context.rectangle (pixel.x, pixel.y, 10, 10);
            drawing_context.fill ();
        }

        void draw_8_pixel (Pixel pixel) {
            int width = 1;
            int height = 1;
            switch (pixel.direction) {
            case PixelDirection.RIGHT:
                width = 8;
                break;
            case PixelDirection.DOWN:
                height = 8;
                break;
            case PixelDirection.LEFT:
                width = 8;
                pixel.x -= 8;
                break;
            case PixelDirection.UP:
                height = 8;
                pixel.y -= 8;
                break;
            }
            if (pixel.x >= get_allocated_width ())
                return;
            if (pixel.y >= get_allocated_height ())
                return;

            set_color (pixel);
            drawing_context.rectangle (pixel.x, pixel.y, width, height);
            drawing_context.fill ();
        }
    }
}
