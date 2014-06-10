
[CCode (cheader_filename = "m2.h,m2ghu8g.h")]
namespace M2tk {

    /* enums */

    [CCode (cname = "uint8_t", cprefix = "M2_KEY_", has_type_id = false)]
    [Flags]
    public enum Key {
        NONE,
        LOOP_START,
        SELECT,
        SELECT2, /* must not be used as message, map to M2_KEY_SELECT */
        EXIT,
        NEXT,
        PREV,
        DATA_UP,
        DATA_DOWN,
        HOME,
        HOME2,
        ROT_ENC_A,
        ROT_ENC_B,
        Q1,
        Q2,
        Q3,
        Q4,
        Q5,
        Q6,
        LOOP_END,
        ANALOG,
        REFRESH,
        TOUCH_PRESS,
        TOUCH_RELEASE,
        [CCode (cname = "M2_KEY_HASH")]
        KEYPAD_HASH,
        [CCode (cname = "M2_KEY_STAR")]
        KEYPAD_STAR,
        [CCode (cname = "M2_KEY_0")]
        KEYPAD_0,
        [CCode (cname = "M2_KEY_1")]
        KEYPAD_1,
        [CCode (cname = "M2_KEY_2")]
        KEYPAD_2,
        [CCode (cname = "M2_KEY_3")]
        KEYPAD_3,
        [CCode (cname = "M2_KEY_4")]
        KEYPAD_4,
        [CCode (cname = "M2_KEY_5")]
        KEYPAD_5,
        [CCode (cname = "M2_KEY_6")]
        KEYPAD_6,
        [CCode (cname = "M2_KEY_7")]
        KEYPAD_7,
        [CCode (cname = "M2_KEY_8")]
        KEYPAD_8,
        [CCode (cname = "M2_KEY_9")]
        KEYPAD_9,
        [CCode (cname = "M2_KEY_EVENT_MASK")]
        EVENT
    }

    [CCode (cname = "uint8_t", cprefix = "M2_ES_MSG_", has_type_id = false)]
    public enum EventSourceMessage {
        GET_KEY,
        INIT
    }

    [CCode (cname = "uint8_t", cprefix = "M2_EP_MSG_", has_type_id = false)]
    public enum EventHandlerMessage {
        SELECT,
        NEXT,
        PREV,
        EXIT,
        DATA_UP,
        DATA_DOWN,
        TOUCH_PRESS,
        TOUCH_RELEASE,
        [CCode (cname = "M2_EP_MSG_HASH")]
        EP_MSGPAD_HASH,
        [CCode (cname = "M2_EP_MSG_STAR")]
        EP_MSGPAD_STAR,
        [CCode (cname = "M2_EP_MSG_0")]
        EP_MSGPAD_0,
        [CCode (cname = "M2_EP_MSG_1")]
        EP_MSGPAD_1,
        [CCode (cname = "M2_EP_MSG_2")]
        EP_MSGPAD_2,
        [CCode (cname = "M2_EP_MSG_3")]
        EP_MSGPAD_3,
        [CCode (cname = "M2_EP_MSG_4")]
        EP_MSGPAD_4,
        [CCode (cname = "M2_EP_MSG_5")]
        EP_MSGPAD_5,
        [CCode (cname = "M2_EP_MSG_6")]
        EP_MSGPAD_6,
        [CCode (cname = "M2_EP_MSG_7")]
        EP_MSGPAD_7,
        [CCode (cname = "M2_EP_MSG_8")]
        EP_MSGPAD_8,
        [CCode (cname = "M2_EP_MSG_9")]
        KEYPAD_9,
    }

    [CCode (cname = "uint8_t", cprefix = "M2_EL_MSG_", has_type_id = false)]
    public enum ElementCallbackMessage {
        GET_LIST_LEN,
        GET_LIST_ELEMENT,
        GET_LIST_BOX,
        GET_OPT,
        IS_DATA_ENTRY,
        DATA_UP,
        DATA_DOWN,
        DATA_SET_U8,
        IS_AUTO_SKIP,
        IS_READ_ONLY,
        GET_HEIGHT,
        GET_WIDTH,
        SELECT,
        NEW_FOCUS,
        NEW_DIALOG,
        SHOW,
        DBG_SHOW,
        SPACE,
        [CCode (cname = "M2_EL_MSG_HASH")]
        EP_MSGPAD_HASH,
        [CCode (cname = "M2_EL_MSG_STAR")]
        EP_MSGPAD_STAR,
        [CCode (cname = "M2_EL_MSG_0")]
        EP_MSGPAD_0,
        [CCode (cname = "M2_EL_MSG_1")]
        EP_MSGPAD_1,
        [CCode (cname = "M2_EL_MSG_2")]
        EP_MSGPAD_2,
        [CCode (cname = "M2_EL_MSG_3")]
        EP_MSGPAD_3,
        [CCode (cname = "M2_EL_MSG_4")]
        EP_MSGPAD_4,
        [CCode (cname = "M2_EL_MSG_5")]
        EP_MSGPAD_5,
        [CCode (cname = "M2_EL_MSG_6")]
        EP_MSGPAD_6,
        [CCode (cname = "M2_EL_MSG_7")]
        EP_MSGPAD_7,
        [CCode (cname = "M2_EL_MSG_8")]
        EP_MSGPAD_8,
        [CCode (cname = "M2_EL_MSG_9")]
        KEYPAD_9,
    }

    [CCode (cname = "uint8_t", cprefix = "M2_U8_MSG_", has_type_id = false)]
    public enum U8FuncMessage {
        GET_VALUE,
        SET_VALUE
    }

    [CCode (cname = "uint8_t", cprefix = "M2_S8_MSG_", has_type_id = false)]
    public enum S8FuncMessage {
        GET_VALUE,
        SET_VALUE
    }

    [CCode (cname = "uint8_t", cprefix = "M2_U32_MSG_", has_type_id = false)]
    public enum U32FuncMessage {
        GET_VALUE,
        SET_VALUE
    }

    [CCode (cname = "uint8_t", cprefix = "M2_STRLIST_MSG_", has_type_id = false)]
    public enum StringListMessage {
        GET_STR,
        SELECT,
        GET_EXTENDED_STR,
        NEW_DIALOG,
    }

    [CCode (cname = "uint8_t", cprefix = "M2_COMBOFN_MSG_", has_type_id = false)]
    public enum ComboFuncMessage {
        GET_VALUE,
        SET_VALUE,
        GET_STRING,
    }

    [CCode (cname = "uint8_t", cprefix = "M2_STRLIST_MSG_", has_type_id = false)]
    public enum StringListFuncMessage {
        GET_STR,
        SELECT,
        SET_EXTENDED_STR,
        NEW_DIALIG,
    }

    [CCode (cname = "uint8_t", has_type_id = false)]
    public enum FontIndex {
        [CCode (cname = "0")] F0,
        [CCode (cname = "1")] F1,
        [CCode (cname = "2")] F2,
        [CCode (cname = "3")] F3
    }

    [CCode (cname = "uint8_t", has_type_id = false)]
    [Flags]
    public enum FontSpec
    {
        [CCode (cname = "0")] F0,
        [CCode (cname = "1")] F1,
        [CCode (cname = "2")] F2,
        [CCode (cname = "3")] F3,
        [CCode (cname = "4")] HIGHLIGHT,
        [CCode (cname = "8")] CENTER
    }

    [CCode (cname = "int", has_type_id = false)]
    public enum IconType
    {
        [CCode (cname = "0")] FONT,
        [CCode (cname = "1")] BOX
    }

    [CCode (cname = "uint8_t", has_type_id = false)]
    public enum HideState {
        [CCode (cname = "0")] VISIBLE,
        [CCode (cname = "1")] HIDDEN_KEEP_SIZE,
        [CCode (cname = "2")] HIDDEN_NO_SIZE,
    }

    /* static instances */

    [CCode (cname = "&m2_null_element")]
    public static unowned Element null_element;

    /* main functions */

    [CCode (cname = "m2_Init")]
    static void init(Element root_element,
        EventSourceFunc? event_source,
        EventHandlerFunc? event_handler,
        GraphicsFunc graphics_handler);
    [CCode (cname = "m2_CheckKey")]
    public static void check_key();
    [CCode (cname = "m2_HandleKey")]
    public static uint8 handle_key();
    [CCode (cname = "m2_Draw")]
    public static void draw();
    [CCode (cname = "m2_SetKey")]
    public static void put_key(uint8 key);
    [CCode (cname = "m2_GetKey")]
    public static uint8 get_key();
    [CCode (cname = "m2_SetFont")]
    public static void set_font(FontIndex index, U8g.Font? font);
    [CCode (cname = "m2_GetRoot")]
    static unowned Element get_root();
    [CCode (cname = "m2_SetRootExtended")]
    static void set_root(Element element, uint8 next_count = 0,
        uint8 callback_value = 0);
    [CCode (cname = "m2_SetHome")]
    static void set_home(Element element);
    [CCode (cname = "m2_SetHome2")]
    static void set_home2(Element element);
    [CCode (cname = "m2_SetRootChangeCallback")]
    public static void set_root_change_callback(RootChangeFunc cb);

    /* private functions */

    [CCode (cname = "m2_fn_arg_call")]
    static uint8 call_element_function(uint8 msg);

    /* u8g functions */

    [CCode (cname = "m2_gh_u8g_fb", has_type_id = false)]
    public static uint8 U8gFrameBoxGraphicsHandler(GraphicsArgs arg);
    [CCode (cname = "m2_gh_u8g_bf", has_type_id = false)]
    public static uint8 U8gBoxFrameGraphicsHandler(GraphicsArgs arg);
    [CCode (cname = "m2_gh_u8g_bfs", has_type_id = false)]
    public static uint8 U8gBoxShadowFrameGraphicsHandler(GraphicsArgs arg);
    [CCode (cname = "m2_gh_u8g_ffs", has_type_id = false)]
    public static uint8 U8gFrameShadowFrameGraphicsHandler(GraphicsArgs arg);

    [CCode (cname = "m2_u8g_font_icon")]
    static uint8 U8fFontIconHandler(GraphicsArgs arg);
    [CCode (cname = "m2_u8g_box_icon")]
    static uint8 U8gBoxIconHandler(GraphicsArgs arg);
    [CCode (cname = "m2_SetU8g")]
    static void set_u8g_internal(U8g.Graphics u8g, GraphicsFunc draw_icon);
    public static void set_u8g(U8g.Graphics u8g, IconType icon_type)
    {
        if (icon_type == IconType.FONT)
            set_u8g_internal(u8g, U8fFontIconHandler);
        else
            set_u8g_internal(u8g, U8gBoxIconHandler);
    }
    [CCode (cname = "m2_SetU8gInvisibleFrameXBorder")]
    public static void set_u8g_invisible_frame_x_border(uint8 width);
    [CCode (cname = "m2_SetU8gAdditionalTextXBorder")]
    public static void set_u8g_additional_text_x_border(uint8 width);
    [CCode (cname = "m2_SetU8gAdditionalReadOnlyXBorder")]
    public static void set_u8g_additional_read_only_x_border(uint8 width);

    /* delegates */

    [CCode (cname = "m2_es_fnptr", has_target = false, has_type_id = false)]
    public delegate uint8 EventSourceFunc(M2 m2, EventSourceMessage msg);

    [CCode (cname = "m2_eh_fnptr", has_target = false, has_type_id = false)]
    public delegate uint8 EventHandlerFunc(M2 m2, EventHandlerMessage msg, uint8 arg1, uint8 arg2);

    [CCode (cname = "m2_gfx_fnptr", has_target = false, has_type_id = false)]
    public delegate uint8 GraphicsFunc(GraphicsArgs arg);

    [CCode (cname = "m2_root_change_fnptr", has_target = false, has_type_id = false)]
    public delegate void RootChangeFunc(Element? new_root, Element? old_root, uint8 change_value);

    [CCode (cname = "m2_get_str_fnptr", has_target = false, has_type_id = false)]
    public delegate string GetStringFunc(uint8 index);

    [CCode (cname = "m2_el_fnptr", has_target = false, has_type_id = false)]
    delegate uint8 ElementFunc(ElementFuncArgs arg);

    [CCode (cname = "m2_button_fnptr", has_target = false, has_type_id = false)]
    public delegate void ButtonFunc(ElementFuncArgs arg);

    [CCode (cname = "m2_labelfn_fnptr", has_target = false, has_type_id = false)]
    public delegate string LabelFunc(Element element);

    [CCode (cname = "m2_u8fn_fnptr", has_target = false, has_type_id = false)]
    public delegate uint8 U8Func(Element element, U8FuncMessage msg, uint8 value);

    [CCode (cname = "m2_s8fn_fnptr", has_target = false, has_type_id = false)]
    public delegate char S8Func(Element element, S8FuncMessage msg, char value);

    [CCode (cname = "m2_u32fn_fnptr", has_target = false, has_type_id = false)]
    public delegate uint U32Func(Element element, U32FuncMessage msg, uint value);

    [CCode (cname = "m2_u32fn_fnptr", has_target = false, has_type_id = false)]
    public delegate string ComboFunc(Element element, ComboFuncMessage msg, ref uint8 value);

    [CCode (cname = "m2_strlist_cb_fnptr", has_target = false, has_type_id = false)]
    public delegate string StringListFunc(uint8 index, StringListFuncMessage msg);

    /* structs */

    [CCode (cname = "m2_menu_entry", destroy_function = "",  has_type_id = false)]
    public struct MenuEntry {
        string label;
        Element element;
    }

    [CCode (cname = "m2_xmenu_entry", destroy_function = "",  has_type_id = false)]
    public struct ExtendedMenuEntry {
        string label;
        Element element;
        StringListFunc func;
    }

    /* classes */

    [CCode (cname = "m2_t", cprefix = "m2_", has_type_id = false)]
    [Compact]
    public class M2 {
        public Nav nav { get; }
    }

    [CCode (cname = "m2_nav_t", cprefix = "m2_nav_", has_type_id = false)]
    [Compact]
    public class Nav {
        public uint8 user_up();
        public uint8 user_down(bool is_msg);
        public uint8 user_prev();
        public uint8 user_first();
        public uint8 user_next();
        public uint8 data_up();
        public uint8 data_down();
        public uint8 quick_key(Key quick_key)
            requires(quick_key >= Key.Q1 && quick_key <= Key.LOOP_END);
        uint8 prepare_fn_arg_current_element();
        public uint8 data_char(uint8 c) {
            prepare_fn_arg_current_element();
            return call_element_function(c); // assign the char
        }
        public bool is_data_entry {
            [CCode (cname = "m2_nav_is_data_entry")] get;
        }
    }

    [CCode (cname = "m2_gfx_arg_t", has_type_id = false)]
    [Compact]
    public class GraphicsArgs {
    }

    [CCode (cname = "m2_el_fnfmt_t", free_function = "g_free", has_type_id = false)]
    [Compact]
    public class Element {
        [CCode (cname = "fmt")]
        internal unowned string? format;

        public uint8 width {
            [CCode (cname = "m2_fn_get_width")]get;
        }

        public uint8 height {
            [CCode (cname = "m2_fn_get_height")]get;
        }
    }

    [CCode (cname = "m2_el_fnarg_t", has_type_id = false)]
    [Compact]
    public class ElementFuncArgs {
        public Element element;
        public ElementCallbackMessage msg;
        public uint8 arg;
        public void* data;
        public Nav? nav;
    }

    [CCode (cname = "m2_el_space_t", free_function = "g_free", has_type_id = false)]
    public class Space : Element {
        [CCode (cname = "m2_el_space_t", destroy_function = "", has_type_id = false)]
        struct SpaceStruct {}

        [CCode (cname = "m2_el_space_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;

        [CCode (cname = "g_malloc")]
        Space(size_t size = sizeof(SpaceStruct))
            requires (size == sizeof(SpaceStruct));

        public static Space create(string? format = null)
        {
            var element = new Space();
            element.func = (ElementFunc)Func;
            element.format = format;
            return element;
        }
    }

    [CCode (cname = "m2_el_space_t", free_function = "g_free", has_type_id = false)]
    public class Box : Element {
        [CCode (cname = "m2_el_space_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_box_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;

        [CCode (cname = "g_malloc")]
        Box(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Box create(string? format = null) {
            var element = new Box();
            element.func = (ElementFunc)Func;
            element.format = format;
            return element;
        }
    }

    [CCode (cname = "m2_el_spacecb_t", free_function = "g_free", has_type_id = false)]
    public class SpaceWithFunc : Element {
        [CCode (cname = "m2_el_spacecb_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_spacecb_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "el_space.ff.fn")]
        ElementFunc func;
        [CCode (cname = "el_space.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "new_dialog_callback")]
        ButtonFunc callback;

        [CCode (cname = "g_malloc")]
        SpaceWithFunc(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static SpaceWithFunc create(ButtonFunc callback, string? format = null)
        {
            var element = new SpaceWithFunc();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.callback = callback;
            return element;
        }
    }

    [CCode (cname = "m2_el_str_t", free_function = "g_free", has_type_id = false)]
    public class StringUp : Element {
        [CCode (cname = "m2_el_str_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_str_up_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "str")]
        internal unowned string text;

        [CCode (cname = "g_malloc")]
        StringUp(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static StringUp create(string text, string? format = null) {
            var element = new StringUp();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.text = text;
            return element;
        }
    }

    [CCode (cname = "m2_el_str_t", free_function = "g_free", has_type_id = false)]
    public class Label : Element {
        [CCode (cname = "m2_el_str_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_label_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "str")]
        internal unowned string text;

        [CCode (cname = "g_malloc")]
        Label(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Label create(string text, string? format = null) {
            var element = new Label();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.text = text;
            return element;
        }
    }

    [CCode (cname = "m2_el_labelfn_t", free_function = "g_free", has_type_id = false)]
    public class LabelWithFunc : Element {
        [CCode (cname = "m2_el_labelfn_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_labelfn_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "label_callback")]
        LabelFunc callback;

        [CCode (cname = "g_malloc")]
        LabelWithFunc(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static LabelWithFunc create(LabelFunc func, string? format = null)
        {
            var element = new LabelWithFunc();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_root_t", free_function = "g_free", has_type_id = false)]
    public class Root : Element {
        [CCode (cname = "m2_el_root_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_root_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "el_str.ff.fn")]
        ElementFunc func;
        [CCode (cname = "el_str.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "el_str.str")]
        internal unowned string text;
        [CCode (cname = "element")]
        internal unowned Element? element;

        [CCode (cname = "g_malloc")]
        Root(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Root create(Element? new_root_element, string text, string? format = null) {
            var element = new Root();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.text = text;
            element.element = new_root_element;
            return element;
        }
    }

    [CCode (cname = "m2_el_button_t", free_function = "g_free", has_type_id = false)]
    public class Button : Element {
        [CCode (cname = "m2_el_button_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_button_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "el_str.ff.fn")]
        ElementFunc func;
        [CCode (cname = "el_str.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "el_str.str")]
        internal unowned string text;
        [CCode (cname = "button_callback")]
        public ButtonFunc callback;

        [CCode (cname = "g_malloc")]
        Button(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Button create(ButtonFunc callback, string text, string? format = null) {
            var element = new Button();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.text = text;
            element.callback = callback;
            return element;
        }
    }

    [CCode (cname = "m2_el_s8_ptr_t", free_function = "g_free", has_type_id = false)]
    public class S8Num : Element {
        [CCode (cname = "m2_el_s8_ptr_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_s8num_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "s8.ff.fn")]
        ElementFunc func;
        [CCode (cname = "s8.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "s8.min")]
        public char min;
        [CCode (cname = "s8.max")]
        public char max;
        [CCode (cname = "val")]
        public char *value;

        [CCode (cname = "g_malloc")]
        S8Num(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static S8Num create(ref char value, char min, char max, string? format = null) {
            var element = new S8Num();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.min = min;
            element.max = max;
            element.value = &value;
            return element;
        }
    }

    [CCode (cname = "m2_el_s8_fn_t", free_function = "g_free", has_type_id = false)]
    public class S8NumWithFunc : Element {
        [CCode (cname = "m2_el_s8_fn_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_s8numfn_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "s8.ff.fn")]
        ElementFunc func;
        [CCode (cname = "s8.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "s8.min")]
        public char min;
        [CCode (cname = "s8.max")]
        public char max;
        [CCode (cname = "s8_callback")]
        public S8Func callback;

        [CCode (cname = "g_malloc")]
        S8NumWithFunc(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static S8NumWithFunc create(S8Func func, char min, char max, string? format = null) {
            var element = new S8NumWithFunc();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.min = min;
            element.max = max;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_u8_ptr_t", free_function = "g_free", has_type_id = false)]
    public class U8Num : Element {
        [CCode (cname = "m2_el_u8_ptr_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_u8num_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "u8.ff.fn")]
        ElementFunc func;
        [CCode (cname = "u8.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "u8.min")]
        public uint8 min;
        [CCode (cname = "u8.max")]
        public uint8 max;
        [CCode (cname = "val")]
        public uint8 *value;

        [CCode (cname = "g_malloc")]
        U8Num(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static U8Num create(ref uint8 value, uint8 min, uint8 max, string? format = null) {
            var element = new U8Num();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.min = min;
            element.max = max;
            element.value = &value;
            return element;
        }
    }

    [CCode (cname = "m2_el_u8_fn_t", free_function = "g_free", has_type_id = false)]
    public class U8NumWithFunc : Element {
        [CCode (cname = "m2_el_u8_fn_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_u8numfn_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "u8.ff.fn")]
        ElementFunc func;
        [CCode (cname = "u8.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "u8.min")]
        public uint8 min;
        [CCode (cname = "u8.max")]
        public uint8 max;
        [CCode (cname = "u8_callback")]
        public U8Func callback;

        [CCode (cname = "g_malloc")]
        U8NumWithFunc(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static U8NumWithFunc create(U8Func func, uint8 min, uint8 max, string? format = null) {
            var element = new U8NumWithFunc();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.min = min;
            element.max = max;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_list_t", free_function = "g_free", has_type_id = false)]
    public class VList : Element {
        [CCode (cname = "m2_el_list_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_vlist_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "len")]
        internal uint8 length;
        [CCode (cname = "el_list")]
        internal Element *list;

        [CCode (cname = "g_malloc")]
        VList(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static VList create(Element[] list, string? format = null)
            requires (list.length <= (uint8)(-1))
        {
            var element = new VList();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.length = (uint8)list.length;
            element.list = list;
            return element;
        }
    }

    [CCode (cname = "m2_el_list_t", free_function = "g_free", has_type_id = false)]
    public class HList : Element {
        [CCode (cname = "m2_el_list_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_hlist_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "len")]
        internal uint8 length;
        [CCode (cname = "el_list")]
        internal Element *list;

        [CCode (cname = "g_malloc")]
        HList(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static HList create(Element[] list, string? format = null)
            requires (list.length <= (uint8)(-1))
        {
            var element = new HList();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.length = (uint8)list.length;
            element.list = list;
            return element;
        }
    }

    [CCode (cname = "m2_el_list_t", free_function = "g_free", has_type_id = false)]
    public class GridList : Element {
        [CCode (cname = "m2_el_list_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_gridlist_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "len")]
        internal uint8 length;
        [CCode (cname = "el_list")]
        internal Element *list;

        [CCode (cname = "g_malloc")]
        GridList(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static GridList create(Element[] list, string? format = null)
            requires (list.length <= (uint8)(-1))
        {
            var element = new GridList();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.length = (uint8)list.length;
            element.list = list;
            return element;
        }
    }

    [CCode (cname = "m2_el_list_t", free_function = "g_free", has_type_id = false)]
    public class XYList : Element {
        [CCode (cname = "m2_el_list_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_xylist_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "len")]
        uint8 length;
        [CCode (cname = "el_list")]
        Element *list;

        [CCode (cname = "g_malloc")]
        XYList(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static XYList create(Element[] list, string? format = null)
            requires (list.length <= (uint8)(-1))
        {
            var element = new XYList();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.length = (uint8)list.length;
            element.list = list;
            return element;
        }
    }

    [CCode (cname = "m2_el_text_t", free_function = "g_free", has_type_id = false)]
    public class Text : Element {
        [CCode (cname = "m2_el_text_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_text_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "text")]
        char *text;
        [CCode (cname = "len")]
        uint8 length;

        [CCode (cname = "g_malloc")]
        Text(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Text create(char[] text, string? format = null) {
            var element = new Text();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.text = text;
            element.length = (uint8)text.length;
            return element;
        }
    }

    [CCode (cname = "m2_el_u32_t", free_function = "g_free", has_type_id = false)]
    public class U32Num : Element {
        [CCode (cname = "m2_el_u32_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_u32_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "val")]
        uint *value;

        [CCode (cname = "g_malloc")]
        U32Num(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static U32Num create(ref uint value, string? format = null) {
            var element = new U32Num();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.value = &value;
            return element;
        }
    }

    [CCode (cname = "m2_el_u32fn_t", free_function = "g_free", has_type_id = false)]
    public class U32NumWithFunc : Element {
        [CCode (cname = "m2_el_u32fn_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_u32fn_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "u32_callback")]
        U32Func callback;

        [CCode (cname = "g_malloc")]
        U32NumWithFunc(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static U32NumWithFunc create(U32Func func, string? format = null) {
            var element = new U32NumWithFunc();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_align_t", free_function = "g_free", has_type_id = false)]
    public class Align : Element {
        [CCode (cname = "m2_el_align_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_align_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "element")]
        internal unowned Element child;

        [CCode (cname = "g_malloc")]
        Align(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Align create(Element child, string? format = null) {
            var element = new Align();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.child = child;
            return element;
        }
    }

    [CCode (cname = "m2_el_hide_t", free_function = "g_free", has_type_id = false)]
    public class Hide : Element {
        [CCode (cname = "m2_el_hide_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_hide_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "align.ff.fn")]
        ElementFunc func;
        [CCode (cname = "align.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "align.element")]
        unowned Element child;
        [CCode (cname = "val")]
        HideState *state;

        [CCode (cname = "g_malloc")]
        Hide(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Hide create(Element child, ref HideState state, string? format = null) {
            var element = new Hide();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.child = child;
            element.state = &state;
            return element;
        }
    }

    [CCode (cname = "m2_el_setval_t", free_function = "g_free", has_type_id = false)]
    public class Toggle : Element {
        [CCode (cname = "m2_el_setval_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_toggle_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "val")]
        bool *value;

        [CCode (cname = "g_malloc")]
        Toggle(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Toggle create(ref bool value, string? format = null) {
            var element = new Toggle();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.value = &value;
            return element;
        }
    }

    [CCode (cname = "m2_el_radio_fn", free_function = "g_free", has_type_id = false)]
    public class Radio : Element {
        [CCode (cname = "m2_el_radio_fn", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_toggle_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "val")]
        bool *value;

        [CCode (cname = "g_malloc")]
        Radio(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Radio create(ref bool value, string? format = null) {
            var element = new Radio();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.value = &value;
            return element;
        }
    }

    [CCode (cname = "m2_el_combo_t", free_function = "g_free", has_type_id = false)]
    public class Combo : Element {
        [CCode (cname = "m2_el_combo_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_combo_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "setval.ff.fn")]
        ElementFunc func;
        [CCode (cname = "setval.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "setval.val")]
        uint8 *value;
        [CCode (cname = "cnt")]
        uint8 count;
        [CCode (cname = "get_str_fnptr")]
        GetStringFunc callback;

        [CCode (cname = "g_malloc")]
        Combo(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Combo create(GetStringFunc func, uint8 count, ref uint8 value, string? format = null) {
            var element = new Combo();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.value = &value;
            element.count = count;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_combofn_t", free_function = "g_free", has_type_id = false)]
    public class ComboWithFunc : Element {
        [CCode (cname = "m2_el_combofn_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_combofn_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "setval.ff.fn")]
        ElementFunc func;
        [CCode (cname = "setval.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "setval.val")]
        uint8 *value;
        [CCode (cname = "cnt")]
        uint8 count;
        [CCode (cname = "fnptr")]
        ComboFunc callback;

        [CCode (cname = "g_malloc")]
        ComboWithFunc(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static ComboWithFunc create(ComboFunc func, uint8 count, ref uint8 value, string? format = null) {
            var element = new ComboWithFunc();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.value = &value;
            element.count = count;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_slbase_t", free_function = "g_free", has_type_id = false)]
    public class VScrollBar : Element {
        [CCode (cname = "m2_el_slbase_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_vsb_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "ff.fn")]
        ElementFunc func;
        [CCode (cname = "ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "top")]
        uint8 *top;
        [CCode (cname = "len")]
        uint8 *length;

        [CCode (cname = "g_malloc")]
        VScrollBar(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static VScrollBar create(ref uint8 count, ref uint8 top, string? format = null) {
            var element = new VScrollBar();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.top = &top;
            element.length = &count;
            return element;
        }
    }

    [CCode (cname = "m2_el_strlist_t", free_function = "g_free", has_type_id = false)]
    public class StringList : Element {
        [CCode (cname = "m2_el_strlist_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_strlist_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "slbase.ff.fn")]
        ElementFunc func;
        [CCode (cname = "slbase.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "slbase.top")]
        uint8 *top;
        [CCode (cname = "slbase.len")]
        uint8 *length;
        [CCode (cname = "strlist_cb_fnptr")]
        StringListFunc callback;

        [CCode (cname = "g_malloc")]
        StringList(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static StringList create(StringListFunc func, ref uint8 count, ref uint8 top, string? format = null) {
            var element = new StringList();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.top = &top;
            element.length = &count;
            element.callback = func;
            return element;
        }
    }

    [CCode (cname = "m2_el_2lmenu_t", free_function = "g_free", has_type_id = false)]
    public class Menu : Element {
        [CCode (cname = "m2_el_2lmenu_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_2lmenu_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "slbase.ff.fn")]
        ElementFunc func;
        [CCode (cname = "slbase.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "slbase.top")]
        uint8 *top;
        [CCode (cname = "slbase.len")]
        uint8 *length;
        [CCode (cname = "menu_entries")]
        MenuEntry *menu_items;
        [CCode (cname = "menu_char")]
        uint8 menu_char;
        [CCode (cname = "expanded_char")]
        uint8 expanded_char;
        [CCode (cname = "submenu_char")]
        uint8 submenu_char;

        [CCode (cname = "g_malloc")]
        Menu(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Menu create(MenuEntry[] menu_items, ref uint8 first, ref uint8 count, uint8 menu_char, uint8 expanded_char, uint8 submenu_char, string? format = null) {
            var element = new Menu();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.top = &first;
            element.length = &count;
            element.menu_items = menu_items;
            element.menu_char = menu_char;
            element.expanded_char = expanded_char;
            element.submenu_char = submenu_char;
            return element;
        }
    }

    [CCode (cname = "m2_el_2lmenu_t", free_function = "g_free", has_type_id = false)]
    public class ExtendedMenu : Element {
        [CCode (cname = "m2_el_2lmenu_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_x2lmenu_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "slbase.ff.fn")]
        ElementFunc func;
        [CCode (cname = "slbase.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "slbase.top")]
        uint8 *top;
        [CCode (cname = "slbase.len")]
        uint8 *length;
        [CCode (cname = "menu_entries")]
        ExtendedMenuEntry *menu_items;
        [CCode (cname = "menu_char")]
        uint8 menu_char;
        [CCode (cname = "expanded_char")]
        uint8 expanded_char;
        [CCode (cname = "submenu_char")]
        uint8 submenu_char;

        [CCode (cname = "g_malloc")]
        ExtendedMenu(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static ExtendedMenu create(ExtendedMenuEntry[] menu_items, ref uint8 first, ref uint8 count, uint8 menu_char, uint8 expanded_char, uint8 submenu_char, string? format = null) {
            var element = new ExtendedMenu();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.top = &first;
            element.length = &count;
            element.menu_items = menu_items;
            element.menu_char = menu_char;
            element.expanded_char = expanded_char;
            element.submenu_char = submenu_char;
            return element;
        }
    }

    [CCode (cname = "m2_el_info_t", free_function = "g_free", has_type_id = false)]
    public class Info : Element {
        [CCode (cname = "m2_el_info_t", destroy_function = "", has_type_id = false)]
        struct MallocStruct {}

        [CCode (cname = "m2_el_x2lmenu_fn")]
        static uint8 Func(ElementFuncArgs arg);

        [CCode (cname = "infobase.slbase.ff.fn")]
        ElementFunc func;
        [CCode (cname = "infobase.slbase.ff.fmt")]
        internal unowned string? format;
        [CCode (cname = "infobase.slbase.top")]
        uint8 *top;
        [CCode (cname = "infobase.slbase.len")]
        uint8 *length;
        [CCode (cname = "infobase.select_callback")]
        ButtonFunc callback;
        [CCode (cname = "info_str")]
        internal unowned string text;

        [CCode (cname = "g_malloc")]
        Info(size_t size = sizeof(MallocStruct))
            requires (size == sizeof(MallocStruct));

        public static Info create(ButtonFunc func, string? text, ref uint8 first, ref uint8 count, string? format = null) {
            var element = new Info();
            element.func = (ElementFunc)Func;
            element.format = format;
            element.top = &first;
            element.length = &count;
            element.callback = func;
            element.text = text;
            return element;
        }
    }
}
