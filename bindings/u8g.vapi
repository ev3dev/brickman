[CCode (cheader_filename = "u8g.h")]
namespace U8g {

    [CCode (cname = "u8g_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Graphics {
        // MallocStruct is used by the constructor to allocate memory
        // since the upstream library does not contain a function to do
        // this.
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
        [CCode (cname = "u8g_GetWidth")]
        public ushort get_width();
        [CCode (cname = "u8g_GetHeight")]
        public ushort get_height();
        [CCode (cname = "u8g_GetMode")]
        public uint8 get_mode();
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
        [CCode (cname = "u8g_EndDraw")]
        public void end_draw();
        [CCode (cname = "u8g_SetFont")]
        public void set_font(Font font);
    }

    [CCode (cname = "u8g_dev_t", has_type_id = false)]
    [Compact]
    public class Device {
        [CCode (cname = "&u8g_dev_linux_fb")]
        public static Device linux_framebuffer;
    }

    [CCode (cname = "const u8g_fntpgm_uint8_t")]
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
