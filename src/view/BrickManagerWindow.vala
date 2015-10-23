/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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
 * BrickManagerWindow.vala:
 *
 * Common base class for windows in Brick Manager (so they all look kind of the same)
 */

using Ev3devKit.Ui;

 namespace BrickManager {
    public abstract class BrickManagerWindow : Window {
        static Grx.Font _small_font;
        static Grx.Font _big_font;

        public static unowned Grx.Font small_font;
        public static unowned Grx.Font big_font;

        static construct {
            _small_font = Grx.Font.load ("helv11");
            small_font = _small_font ?? Grx.Font.default;
            _big_font = Grx.Font.load ("xm9x15b");
            big_font = _big_font ?? Grx.Font.default;
        }

        Stack window_stack;
        Label title_label;
        Label loading_label;
        Label not_available_label;

        public string title {
            get { return title_label.text; }
            set { title_label.text = value; }
        }

        bool _loading = false;
        public bool loading {
            get { return _loading; }
            set {
                if (value == _loading) {
                    return;
                }
                _loading = value;
                set_active_child ();
            }
        }

        bool _available = true;
        public bool available {
            get { return _available; }
            set {
                if (value == _available) {
                    return;
                }
                _available = value;
                set_active_child ();
            }
        }

        public Box content_vbox { get; private set; }

        protected BrickManagerWindow () {
            var window_vbox = new Box.vertical ();
            add (window_vbox);

            title_label = new Label () {
                vertical_align = WidgetAlign.START,
                padding = 3,
                border_bottom = 1
            };
            window_vbox.add (title_label);

            window_stack = new Stack ();
            window_vbox.add (window_stack);

            content_vbox = new Box.vertical ();
            window_stack.add (content_vbox);

            loading_label = new Label ("Loading...") {
                margin_bottom = 30
            };
            window_stack.add (loading_label);

            not_available_label = new Label ("Not available") {
                margin_bottom = 30
            };
            window_stack.add (not_available_label);
        }

        void set_active_child () {
            window_stack.active_child = _available
            ? (_loading ? (Widget)loading_label : content_vbox)
            : not_available_label;
        }
    }
 }