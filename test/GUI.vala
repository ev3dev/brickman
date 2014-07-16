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
 * GUI.vala:
 *
 * Version of Brick Display Manager that runs in GTK for testing.
 */

using Gee;
using Gtk;
using M2tk;
using U8g;

namespace BrickDisplayManager {
    public class RootInfo {
        public unowned M2tk.Element element;
        public uint8 value;
    }

    class GUI : Object {
        const string control_panel_glade_file = "ControlPanel.glade";

        enum NetworkTechnologyColumn {
            PRESENT,
            POWERED,
            CONNECTED,
            NAME,
            TYPE,
            USER_DATA,
            COLUMN_COUNT;
        }

        static HashMap<weak GM2tk, weak GUI> gui_map;

        static construct {
            gui_map = new HashMap<weak GM2tk, weak GUI> ();
        }

        Deque<RootInfo> root_stack = new LinkedList<RootInfo> ();
        Deque<uint?> key_queue = new LinkedList<uint?> ();

        GM2tk m2tk;
        HomeScreen home_screen;
        NetworkStatusScreen network_status_screen;
        BatteryInfoScreen battery_info_screen;
        ShutdownScreen shutdown_screen;
        BatteryStatusBarItem battery_status_bar_item;
        StatusBar status_bar;
        bool dirty = true;
        bool active { get { return lcd.u8g_active; } }
        ListStore connman_technology_liststore;

        public FakeEV3LCDDevice lcd { get; private set; }
        public Window control_panel { get; private set; }

        public GUI () {
            lcd = new FakeEV3LCDDevice ();
            lcd.key_press_event.connect((e) => {
                key_queue.offer_head(e.keyval);
                return true;
            });

            GM2tk.init_graphics(lcd.u8g_device, U8gGraphics.font_icon_handler);
            U8gGraphics.set_toggle_font_icon (Font.m2tk_icon_9, 73, 72);
            U8gGraphics.set_radio_font_icon (Font.m2tk_icon_9, 82, 80);
            U8gGraphics.set_additional_text_x_padding (3);
            U8gGraphics.forground_text_color = 0;
            U8gGraphics.background_text_color = FakeEV3LCDDevice.BACKGROUND_COLOR;

            home_screen = new HomeScreen ();
            home_screen.menu_item_selected.connect ((index, user_data) => {
                var screen = user_data as Screen;
                m2tk.set_root (screen, 0, index);
            });
            network_status_screen = new NetworkStatusScreen ();
            battery_info_screen = new BatteryInfoScreen ();
            shutdown_screen = new ShutdownScreen ();
            shutdown_screen.power_off_button_pressed.connect (on_shutdown_button_pressed);
            shutdown_screen.reboot_button_pressed.connect (on_restart_button_pressed);
            battery_status_bar_item = new BatteryStatusBarItem ();
            status_bar = new StatusBar ();

            home_screen.add_menu_item ("Network", network_status_screen);
            home_screen.add_menu_item ("Battery", battery_info_screen);
            home_screen.add_menu_item ("Shutdown", shutdown_screen);

            network_status_screen.manage_connections_selected.connect (
                () => m2tk.set_root (home_screen));

            status_bar.add_right (battery_status_bar_item);

            m2tk = new GM2tk (home_screen, event_source, event_handler,
                box_shadow_frame_graphics_handler);
            gui_map[m2tk] = this;
            m2tk.home2 = shutdown_screen;
            m2tk.font[0] = Font.x11_7x13;
            m2tk.font[1] = Font.m2tk_icon_9;
            m2tk.font[2] = Font.cu12_67_75;
            m2tk.root_element_changed.connect (on_root_element_changed);

            var builder = new Builder ();
            try {
                builder.add_from_file (control_panel_glade_file);
                control_panel = builder.get_object ("control_panel_window") as Window;
                builder.get_object ("networking_loading_checkbutton")
                    .bind_property("active", network_status_screen, "loading",
                    BindingFlags.SYNC_CREATE);
                builder.get_object ("connman_offline_mode_checkbutton")
                    .bind_property("active", network_status_screen, "airplane-mode",
                    BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                builder.get_object ("connman_state_comboboxtext")
                    .bind_property("active-id", network_status_screen, "state",
                    BindingFlags.SYNC_CREATE);
                connman_technology_liststore = builder.get_object ("connman_technology_liststore") as ListStore;
                connman_technology_liststore.foreach ((model, path, iter) => {
                    Value name;
                    connman_technology_liststore.get_value (iter, NetworkTechnologyColumn.NAME, out name);
                    var item = new NetworkTechnologyItem (name.dup_string ());
                    item.notify.connect ((sender, pspec) => {
                        switch (pspec.name) {
                        case "powered":
                            connman_technology_liststore.set (iter, NetworkTechnologyColumn.POWERED, item.powered);
                            break;
                        }
                    });
                    network_status_screen.add_technology(item, item);
                    connman_technology_liststore.set (iter, NetworkTechnologyColumn.PRESENT, true);
                    connman_technology_liststore.set (iter, NetworkTechnologyColumn.USER_DATA, item);
                    return false;
                });
                connman_technology_liststore.row_changed.connect ((path, iter) => {
                    Value present;
                    connman_technology_liststore.get_value (iter, NetworkTechnologyColumn.PRESENT, out present);
                    Value powered;
                    connman_technology_liststore.get_value (iter, NetworkTechnologyColumn.POWERED, out powered);
                    Value user_data;
                    connman_technology_liststore.get_value (iter, NetworkTechnologyColumn.USER_DATA, out user_data);
                    var tech = (NetworkTechnologyItem)user_data.get_pointer ();
                    if (network_status_screen.has_technology (tech) && !present.get_boolean ())
                        network_status_screen.remove_technology (tech);
                    else if (!network_status_screen.has_technology (tech) && present.get_boolean ())
                        network_status_screen.add_technology (tech, tech);
                    if (tech.powered != powered.get_boolean ())
                        tech.powered = powered.get_boolean ();
                });
                (builder.get_object ("connman_technology_present_cellrenderertoggle") as CellRendererToggle)
                    .toggled.connect ((toggle, path) => update_listview_toggle_item (toggle, path, NetworkTechnologyColumn.PRESENT));
                (builder.get_object ("connman_technology_powered_cellrenderertoggle") as CellRendererToggle)
                    .toggled.connect ((toggle, path) => update_listview_toggle_item (toggle, path, NetworkTechnologyColumn.POWERED));
                (builder.get_object ("connman_technology_connected_cellrenderertoggle") as CellRendererToggle)
                    .toggled.connect ((toggle, path) => update_listview_toggle_item (toggle, path, NetworkTechnologyColumn.CONNECTED));
                builder.connect_signals (this);
                control_panel.show_all ();
            } catch (Error err) {
                critical ("ControlPanel init failed: %s", err.message);
            }

            Timeout.add(50, on_draw_timer);
        }

        ~GUI () {
            gui_map.unset(m2tk);
        }

        public static GUI from_gm2tk (GM2tk m2) {
            return gui_map[m2];
        }

        void on_root_element_changed (Element new_root, Element old_root,
            uint8 value)
        {
            if (value != uint8.MAX) {
                var info = new RootInfo ();
                info.element = old_root;
                info.value = value;
                root_stack.offer_head (info);
            }
        }

        /**
         * This function should be exactly the same as the
         * on_draw_timer() function in the real GUI.vala
         */
        bool on_draw_timer () {
            if (active) {
                m2tk.check_key ();
                dirty |= m2tk.handle_key ();
                dirty |= m2tk.root.dirty;
                dirty |= status_bar.dirty;
                if (dirty) {
                    unowned Graphics u8g = GM2tk.graphics;
                    u8g.begin_draw ();
                    m2tk.draw ();
                    if (status_bar.visible)
                        status_bar.draw (u8g);
                    u8g.end_draw ();
                    dirty = false;
                    if (m2tk.root.dirty)
                        m2tk.root.dirty = false;
                    if (status_bar.dirty)
                        status_bar.dirty = false;
                }
            }
            return true;
        }

        [CCode (instance_pos = -1)]
        public void on_show_network_status_screen_button (Gtk.Button button) {
            m2tk.set_root (network_status_screen);
        }

        [CCode (instance_pos = -1)]
        public void on_quit_button_pressed (Gtk.Button button) {
            on_shutdown_button_pressed ();
        }

        void update_listview_toggle_item (CellRendererToggle toggle, string path, int column) {
            TreePath tree_path = new TreePath.from_string (path);
            TreeIter iter;
            connman_technology_liststore.get_iter (out iter, tree_path);
            connman_technology_liststore.set (iter, column, !toggle.active);
        }

        static uint8 event_source(M2 m2, EventSourceMessage msg) {
            switch(msg) {
            case EventSourceMessage.GET_KEY:
                GM2tk gm2tk = GM2tk.from_m2 (m2);
                GUI gui = from_gm2tk (gm2tk);
                if (gui.key_queue.peek_head () == null)
                    return Key.NONE;
                switch (gui.key_queue.poll_head ()) {
                /* Actual keys on the EV3 */
                case Gdk.Key.Down:
                    return Key.EVENT | Key.DATA_DOWN;
                case Gdk.Key.Up:
                    return Key.EVENT | Key.DATA_UP;
                case Gdk.Key.Left:
                    return Key.EVENT | Key.PREV;
                case Gdk.Key.Right:
                    return Key.EVENT | Key.NEXT;
                case Gdk.Key.Return:
                    return Key.EVENT | Key.SELECT;
                case Gdk.Key.BackSpace:
                    return Key.EVENT | Key.EXIT;

                /* Other keys in case a keyboard or keypad is plugged in */
                case Gdk.Key.Back:
                    return Key.EVENT | Key.PREV;
                case Gdk.Key.Next:
                  return Key.EVENT | Key.NEXT;
                case Gdk.Key.KP_Enter:
                case Gdk.Key.Open:
                   return Key.EVENT | Key.SELECT;
                case Gdk.Key.Cancel:
                    return Key.EVENT | Key.EXIT;
                case Gdk.Key.Home:
                    return Key.EVENT | Key.HOME;
                //case Gdk.Key.SHOME:
                //    return Key.EVENT | Key.HOME2;
                case Gdk.Key.F1:
                    return Key.EVENT | Key.Q1;
                case Gdk.Key.F2:
                    return Key.EVENT | Key.Q2;
                case Gdk.Key.F3:
                    return Key.EVENT | Key.Q3;
                case Gdk.Key.F4:
                    return Key.EVENT | Key.Q4;
                case Gdk.Key.F5:
                    return Key.EVENT | Key.Q5;
                case Gdk.Key.F6:
                    return Key.EVENT | Key.Q6;
                case Gdk.Key.KP_0:
                    return Key.EVENT | Key.KEYPAD_0;
                case Gdk.Key.KP_1:
                    return Key.EVENT | Key.KEYPAD_1;
                case Gdk.Key.KP_2:
                    return Key.EVENT | Key.KEYPAD_2;
                case Gdk.Key.KP_3:
                    return Key.EVENT | Key.KEYPAD_3;
                case Gdk.Key.KP_4:
                    return Key.EVENT | Key.KEYPAD_4;
                case Gdk.Key.KP_5:
                    return Key.EVENT | Key.KEYPAD_5;
                case Gdk.Key.KP_6:
                    return Key.EVENT | Key.KEYPAD_6;
                case Gdk.Key.KP_7:
                    return Key.EVENT | Key.KEYPAD_7;
                case Gdk.Key.KP_8:
                    return Key.EVENT | Key.KEYPAD_8;
                case Gdk.Key.KP_9:
                    return Key.EVENT | Key.KEYPAD_9;
                case Gdk.Key.KP_Multiply:
                    return Key.EVENT | Key.KEYPAD_STAR;
                case Gdk.Key.KP_Divide:
                    return Key.EVENT | Key.KEYPAD_HASH;
              }
              return Key.NONE;
            case EventSourceMessage.INIT:
                break;
            }
            return 0;
        }

        /**
         * This function should be exactly the same as in the real
         * GUI.vala
         */
        static uint8 event_handler(M2 m2, EventHandlerMessage msg,
            uint8 arg1, uint8 arg2)
        {
            unowned Nav nav = m2.nav;

            switch(msg) {
            case EventHandlerMessage.SELECT:
                return nav.user_down(true);

            case EventHandlerMessage.EXIT:
                // if there is no valid parent, then go to the previous root
                if (nav.user_up() == 0) {
                    var gm2tk = GM2tk.from_m2 (m2);
                    var gui = GUI.from_gm2tk (gm2tk);
                    var info = gui.root_stack.poll_head();
                    if (info != null) {
                        m2.set_root(info.element, info.value, uint8.MAX);
                    } else {
                        m2.set_root (m2.home2);
                    }
                }
                return 1;

            case EventHandlerMessage.NEXT:
                return nav.user_next();

            case EventHandlerMessage.PREV:
                return nav.user_prev();

            case EventHandlerMessage.DATA_DOWN:
                if (nav.data_down() == 0)
                    return nav.user_next();
                return 1;

            case EventHandlerMessage.DATA_UP:
                if (nav.data_up() == 0)
                    return nav.user_prev ();
                return 1;
            }

            if (msg >= Key.Q1 && msg <= Key.LOOP_END) {
                if (nav.quick_key((Key)msg - Key.Q1 + 1) != 0)
                {
                    if (nav.is_data_entry)
                        return nav.data_up ();
                    return nav.user_down (true);
                }
            }

            if (msg >= ElementMessage.SPACE) {
                nav.data_char (msg);      // assign the char
                return nav.user_next ();  // go to next position
            }
            return 0;
        }
    }

   void on_shutdown_button_pressed () {
      Gtk.main_quit ();
    }

    void on_restart_button_pressed () {
      // TODO: show fake error message
    }
}
