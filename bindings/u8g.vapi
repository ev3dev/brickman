[CCode (cheader_filename = "u8g.h")]
namespace U8g {

    [CCode (cname = "u8g_dev_fnptr", has_target = false, has_type_id = false)]
    public delegate uint8 DeviceFunc (Graphics u8g, Device device, DeviceMessage msg, void* arg);
    [CCode (cname = "u8g_com_fnptr", has_target = false, has_type_id = false)]
    public delegate uint8 CommFunc (Graphics u8g, uint8 msg, uint8 arg_val, void* arg_data);

    [CCode (cname = "uint8_t", cprefix = "U8G_DEV_MSG_", has_type_id = false)]
    public enum DeviceMessage {
        INIT,
        STOP,
        CONTRAST,
        SLEEP_ON,
        SLEEP_OFF,
        PAGE_FIRST,
        PAGE_NEXT,
        GET_PAGE_BOX,
        SET_TPIXEL,
        SET_4TPIXEL,
        SET_PIXEL,
        SET_8PIXEL,
        SET_COLOR_ENTRY,
        SET_XY_CB,
        GET_WIDTH,
        GET_HEIGHT,
        GET_MODE;
    }

    [CCode (cname = "uint8_t", cprefix = "U8G_MODE_", has_type_id = false)]
    public enum Mode {
        UNKNOWN,
        BW,
        GRAY2BIT,
        R2G3B2,
        INDEX,
        HICOLOR,
        TRUECOLOR;

        [CCode (cname = "U8G_MODE_GET_BITS_PER_PIXEL")]
        public int get_bits_per_pixel ();

        [CCode (cname = "U8G_MODE_IS_COLOR")]
        public bool is_color ();

        [CCode (cname = "U8G_MODE_IS_INDEX_MODE")]
        public bool is_index_mode ();
    }

    [CCode (cname = "uint8_t", has_type_id = false)]
    public enum PixelDirection {
        [CCode (cname = "0")]
        RIGHT,
        [CCode (cname = "1")]
        DOWN,
        [CCode (cname = "2")]
        LEFT,
        [CCode (cname = "3")]
        UP;
    }

    [CCode (cname = "u8g_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Graphics {
        [CCode (cname = "u8g_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "g_malloc0")]
        public Graphics(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));
        [CCode (cname = "u8g_Init")]
        public uint8 init(Device dev);
        [CCode (cname = "u8g_DrawPixel")]
        public void draw_pixel(uint16 x, uint16 y);
        [CCode (cname = "u8g_Stop")]
        public uint8 stop();
        [CCode (cname = "u8g_SetColorEntry")]
        public uint8 color_index {
            [CCode (cname = "u8g_GetColorIndex")] get;
            [CCode (cname = "u8g_SetColorIndex")] set;
        }
        [CCode (cname = "u8g_SetRGB")]
        public void set_rgb (uint8 red, uint8 green, uint8 blue);
        [CCode (cname = "u8g_GetDefaultForegroundColor")]
        public uint8 get_default_forground_color();
        [CCode (cname = "u8g_SetDefaultForegroundColor")]
        public void set_default_forground_color();
        [CCode (cname = "u8g_GetDefaultBackgroundColor")]
        public uint8 get_default_background_color();
        [CCode (cname = "u8g_SetDefaultBackgroundColor")]
        public void set_default_background_color();
        [CCode (cname = "u8g_GetDefaultMidColor")]
        public uint8 get_default_mid_color();
        [CCode (cname = "u8g_SetDefaultMidColor")]
        public void set_default_mid_color();
        public ushort width {
            [CCode (cname = "u8g_GetWidth")]get;
        }
        public ushort height {
            [CCode (cname = "u8g_GetHeight")]get;
        }
        public ushort mode {
            [CCode (cname = "u8g_GetMode")]get;
        }
        [CCode (cname = "u8g_BeginDraw")]
        public void begin_draw();
        [CCode (cname = "u8g_DrawBox")]
        public void draw_box(ushort x, ushort y, ushort width, ushort height);
        [CCode (cname = "u8g_DrawFrame")]
        public void draw_frame(ushort x, ushort y, ushort width, ushort height);
        [CCode (cname = "u8g_DrawLine")]
        public void draw_line(ushort x1, ushort y1, ushort x2, ushort y2);
        [CCode (cname = "u8g_DrawStr")]
        public void draw_str(ushort x, ushort y, string str);
        [CCode (cname = "u8g_GetStrWidth")]
        public ushort get_string_width(string str);
        [CCode (cname = "u8g_EndDraw")]
        public void end_draw();
        [CCode (cname = "u8g_SetFont")]
        public void set_font(Font font);
    }

    [CCode (cname = "u8g_dev_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Device {
        [CCode (cname = "u8g_dev_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "&u8g_dev_linux_fb")]
        public static Device linux_framebuffer;

        DeviceFunc dev_fn;
        void* dev_mem;
        CommFunc com_fn;

        [CCode (cname = "g_malloc0")]
        Device (size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Device create (DeviceFunc func, void* data) {
            var device = new Device ();
            device.dev_fn = func;
            device.dev_mem = data;
            device.com_fn = null;
            return device;
        }

        [CCode (cname = "u8g_dev_pb8h1f_base_fn")]
        public static uint8 pb8h1f_base (Graphics u8g, Device dev, DeviceMessage msg, void* arg);
        [CCode (cname = "u8g_dev_pb8h8_base_fn")]
        public static uint8 pb8h8_base (Graphics u8g, Device dev, DeviceMessage msg, void* arg);
        [CCode (cname = "u8g_dev_pbxh16_base_fn")]
        public static uint8 pbxh16_base (Graphics u8g, Device dev, DeviceMessage msg, void* arg);
        [CCode (cname = "u8g_dev_pbxh24_base_fn")]
        public static uint8 pbxh24_base (Graphics u8g, Device dev, DeviceMessage msg, void* arg);
    }

    [CCode (cname = "u8g_page_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Page {
        [CCode (cname = "u8g_page_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "page_height")]
        public uint16 height;
        public uint16 total_height;
        [CCode (cname = "page_y0")]
        public uint16 y0;
        [CCode (cname = "page_y1")]
        public uint16 y1;
        [CCode (cname = "page")]
        public uint8 index;

        [CCode (cname = "g_malloc0")]
        public Page (size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        [CCode (cname = "u8g_page_Init")]
        public void init (uint16 height, uint16 total_height);
    }

    [CCode (cname = "u8g_pb_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class PageBuffer {
        [CCode (cname = "u8g_pb_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "&self->p")]
        static Page p;
        public Page page { get { return p; } }
        public uint16 width;
        [CCode (cname = "buf")]
        public void* data;

        [CCode (cname = "g_malloc0")]
        public PageBuffer (size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));
    }

    [CCode (cname = "u8g_box_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Box {
        [CCode (cname = "u8g_box_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        public uint16 x0;
        public uint16 y0;
        public uint16 x1;
        public uint16 y1;

        [CCode (cname = "g_malloc0")]
        public Box (size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));
    }

    [CCode (cname = "u8g_dev_arg_pixel_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Pixel {
        [CCode (cname = "u8g_dev_arg_pixel_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        public uint16 x;
        public uint16 y;
        public uint8 pixel;
        [CCode (cname = "dir")]
        public PixelDirection direction;
        public uint8 color;
        [CCode (cname = "hi_color")]
        uint8 _hi_color;
        [CCode (cname = "color")]
        public uint8 red;
        [CCode (cname = "hi_color")]
        public uint8 green;
        public uint8 blue;

        public uint16 hi_color { get { return (uint16)_hi_color << 8 + color; } }

        [CCode (cname = "g_malloc0")]
        public Pixel (size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));
    }

    [CCode (cname = "u8g_fntpgm_uint8_t")]
    public class Font {
        /* u8g */
        [CCode (cname = "u8g_font_m2icon_5")]
        public static Font m2tk_icon_5;
        [CCode (cname = "u8g_font_m2icon_7")]
        public static Font m2tk_icon_7;
        [CCode (cname = "u8g_font_m2icon_9")]
        public static Font m2tk_icon_9;
        [CCode (cname = "u8g_font_u8glib_4")]
        public static Font u8glib_4;
        /* x11 */
        [CCode (cname = "u8g_font_cursor")]
        public static Font x11_cursor;
        [CCode (cname = "u8g_font_micro")]
        public static Font x11_micro;
        [CCode (cname = "u8g_font_4x6")]
        public static Font x11_4x6;
        [CCode (cname = "u8g_font_5x7")]
        public static Font x11_5x7;
        [CCode (cname = "u8g_font_5x8")]
        public static Font x11_5x8;
        [CCode (cname = "u8g_font_6x10")]
        public static Font x11_6x10;
        [CCode (cname = "u8g_font_6x12")]
        public static Font x11_6x12;
        [CCode (cname = "u8g_font_6x13")]
        public static Font x11_6x13;
        [CCode (cname = "u8g_font_7x13")]
        public static Font x11_7x13;
        [CCode (cname = "u8g_font_7x14")]
        public static Font x11_7x14;
        [CCode (cname = "u8g_font_8x13")]
        public static Font x11_8x13;
        [CCode (cname = "u8g_font_9x15")]
        public static Font x11_9x15;
        [CCode (cname = "u8g_font_9x18")]
        public static Font x11_9x18;
        [CCode (cname = "u8g_font_10x20")]
        public static Font x11_10x20;
        /* 04 */
        [CCode (cname = "u8g_font_04b_03")]
        public static Font dsg4_04b_03;
        [CCode (cname = "u8g_font_04b_03b")]
        public static Font dsg4_04b_03b;
        [CCode (cname = "u8g_font_04b_24")]
        public static Font dsg4_04b_24;
    }
}
