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
        public signal void volume_max ();
        public signal void volume_min ();
        public signal void volume_half ();
        public signal void mute_toggled (bool is_muted);

        ITestableMixerElement _current_element = null;
        bool _show_element_details = true;

        Ui.Label element_label;
        Ui.CheckboxMenuItem mute_checkbox;

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

            var volume_half_item = new Ui.MenuItem("Half volume");
            volume_half_item.button.pressed.connect(() => {
                if(_current_element != null)
                    volume_half();
            });
            controls_menu.add_menu_item(volume_half_item);

            var volume_max_item = new Ui.MenuItem("Maximum volume");
            volume_max_item.button.pressed.connect(() => {
                if(_current_element != null)
                    volume_max();
            });
            controls_menu.add_menu_item(volume_max_item);

            var volume_min_item = new Ui.MenuItem("Minimum volume");
            volume_min_item.button.pressed.connect(() => {
                if(_current_element != null)
                    volume_min();
            });
            controls_menu.add_menu_item(volume_min_item);

            mute_checkbox = new CheckboxMenuItem("Mute");
            mute_checkbox.checkbox.notify["checked"].connect(() => {
                if(_current_element != null && _current_element.can_mute)
                    mute_toggled(mute_checkbox.checkbox.checked);
            });
            controls_menu.add_menu_item(mute_checkbox);

            content_vbox.add (controls_menu);

            update_from_element();
        }

        public ITestableMixerElement current_element {
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
                if(mute_checkbox.checkbox.checked != false)
                    mute_checkbox.checkbox.checked = false;
                
                set_mute_button_enabled(false);
            }
            else {
                string elem_details_string = show_element_details ? " ([%u] %s)".printf(_current_element.index, _current_element.name) : "";
                element_label.text = "%ld%%%s".printf(_current_element.volume, elem_details_string);

                if(mute_checkbox.checkbox.checked != _current_element.is_muted)
                    mute_checkbox.checkbox.checked = _current_element.is_muted;

                set_mute_button_enabled(_current_element.can_mute);
            }
        }

        private void set_mute_button_enabled(bool is_enabled) {
            mute_checkbox.label.visible = is_enabled;
            mute_checkbox.button.visible = is_enabled;
            mute_checkbox.checkbox.visible = is_enabled;
            mute_checkbox.button.can_focus = is_enabled;
        }
    }
}
