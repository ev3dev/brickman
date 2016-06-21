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
 * MixerElementSelectorWindow.vala - Lists ALSA mixer elements
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {

    public class MixerElementSelectorWindow : BrickManagerWindow {
        Ui.Menu element_menu;

        public signal void mixer_elem_selected (IMixerElementViewModel selected_element);

        private class MixerElementWithSignalIds: Object {
            public IMixerElementViewModel element;
            public ulong notify_signal_handler_id = 0;
            public ulong button_press_signal_handler_id = 0;
        }

        public MixerElementSelectorWindow () {
            title = "Audio mixer elements";
            element_menu = new Ui.Menu ();
            content_vbox.add (element_menu);
        }

        protected string get_element_label_text(IMixerElementViewModel element) {
            string mute_string = (element.can_mute && element.is_muted) ? ", muted" : "";
            return "[%u] %s (%ld%%%s)".printf(element.index, element.name, element.volume, mute_string);
        }

        protected void sort_element_menu() {
            // TODO: we would get much better performance if we just inserted
            // the item in the correct place instead of sorting the entire list
            // each time an item is inserted.
            element_menu.sort_menu_items ((a, b) => {
                IMixerElementViewModel element_a = (a.represented_object as MixerElementWithSignalIds).element;
                IMixerElementViewModel element_b = (b.represented_object as MixerElementWithSignalIds).element;

                // Group by name, and sort by index within the same name
                if(element_a.name == element_b.name)
                    return (int)element_a.index - (int)element_b.index;
                else
                    return element_a.name.ascii_casecmp(element_b.name);
            });
        }

        public void add_element (IMixerElementViewModel element) {
            var menu_item = new Ui.MenuItem (get_element_label_text(element));

            var represented_object = new MixerElementWithSignalIds() {
                element = element
            };

            // Update the menu item whenever the represented element changes
            represented_object.notify_signal_handler_id = element.notify.connect((sender, property) => {
                menu_item.label.text = get_element_label_text(element);
                sort_element_menu();
            });

            // Emit a selection signal for this element when its menu item is selected
            represented_object.button_press_signal_handler_id = menu_item.button.pressed.connect (() =>
                mixer_elem_selected (element));

            menu_item.represented_object = (Object)represented_object;
            element_menu.add_menu_item (menu_item);
        }

        protected void remove_menu_item (Ui.MenuItem menu_item) {
            if (menu_item != null) {
                var represented_object = menu_item.represented_object as MixerElementWithSignalIds;
                represented_object.element.disconnect(represented_object.notify_signal_handler_id);
                menu_item.button.disconnect(represented_object.button_press_signal_handler_id);

                element_menu.remove_menu_item (menu_item);
            }
        }

        public void remove_element (IMixerElementViewModel element) {
            var menu_item = element_menu.find_menu_item<IMixerElementViewModel> (element, (menu_item, target_element) => {
                var other_element = (menu_item.represented_object as MixerElementWithSignalIds).element;
                return target_element == other_element;
            });

            remove_menu_item(menu_item);
        }

        public void clear_elements () {
            var iter = element_menu.menu_item_iter ();
            while (iter.size > 0)
                remove_menu_item(iter[0]);
        }

        public bool has_single_element {
            get {
                return element_menu.menu_item_iter().size == 1;
            }
        }

        public IMixerElementViewModel? first_element {
            get {
                if(element_menu.menu_item_iter().size <= 0)
                    return null;
                
                return (element_menu.menu_item_iter().get(0).represented_object as MixerElementWithSignalIds).element;
            }
        }
    }
}
