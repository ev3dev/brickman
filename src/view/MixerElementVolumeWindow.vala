/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2016 Kaelin Laundry <wasabifan@outlook.com>
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
 * MixerElementVolumeWindow.vala - Allows control of mixer element volume
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class MixerElementVolumeWindow : BrickManagerWindow {
        public signal void volume_up ();
        public signal void volume_down ();
        public signal void volume_min ();

        IMixerElementViewModel _current_element = null;
        bool _show_element_details = true;

        Ui.Label element_label;

        public MixerElementVolumeWindow () {
            title = "Volume control";

            element_label = new Ui.Label();
            content_vbox.add(element_label);

            var controls_menu = new Ui.Menu();

            var volume_up_item = new Ui.MenuItem("+ Volume up");
            volume_up_item.button.pressed.connect(() => {
                if(_current_element != null)
                    volume_up();
            });
            controls_menu.add_menu_item(volume_up_item);

            var volume_down_item = new Ui.MenuItem("- Volume down");
            volume_down_item.button.pressed.connect(() => {
                if(_current_element != null)
                    volume_down();
            });
            controls_menu.add_menu_item(volume_down_item);

            var volume_min_item = new Ui.MenuItem("Mute");
            volume_min_item.button.pressed.connect(() => {
                if(_current_element != null)
                    volume_min();
            });
            controls_menu.add_menu_item(volume_min_item);

            content_vbox.add (controls_menu);

            update_from_element();
        }

        public IMixerElementViewModel current_element {
            get {
                return _current_element;
            }

            set {
                if(_current_element != null) {
                    _current_element.notify.disconnect(update_from_element);
                }

                _current_element = value;
                _current_element.notify.connect(update_from_element);
                update_from_element();
            }
        }

        public bool show_element_details {
            get {
                return _show_element_details;
            }
            set {
                _show_element_details = value;
                update_from_element();
            }
        }

        private void update_from_element() {
            if(_current_element == null) {
                element_label.text = "???";
            }
            else {
                string elem_details_string = show_element_details ? " ([%u] %s)".printf(_current_element.index, _current_element.name) : "";
                string volume_string = _current_element.is_muted ? "muted" : "%ld%%".printf(_current_element.volume);
                element_label.text = volume_string + elem_details_string;
            }
        }
    }
}
