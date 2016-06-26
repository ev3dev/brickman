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

        public signal void mixer_element_selected (IMixerElementViewModel selected_element);

        public MixerElementSelectorWindow () {
            title = "Sound mixer elements";
            element_menu = new Ui.Menu ();
            content_vbox.add (element_menu);
        }

        protected string get_element_label_text (IMixerElementViewModel element) {
            string mute_string = (element.can_mute && element.is_muted) ? ", muted" : "";
            string index_string = element.index == 0 ? "" : " [%u]".printf(element.index);
            return "%s%s (%ld%%%s)".printf (element.name, index_string, element.volume, mute_string);
        }

        protected void sort_element_menu () {
            // TODO: we would get much better performance if we just inserted
            // the item in the correct place instead of sorting the entire list
            // each time an item is inserted.
            element_menu.sort_menu_items ((a, b) => {
                IMixerElementViewModel element_a = a.represented_object as IMixerElementViewModel;
                IMixerElementViewModel element_b = b.represented_object as IMixerElementViewModel;

                // Group by name, and sort by index within the same name
                if (element_a.name == element_b.name)
                    return (int)element_a.index - (int)element_b.index;
                else
                    return element_a.name.ascii_casecmp (element_b.name);
            });
        }

        public void add_element (IMixerElementViewModel element) {
            var menu_item = new Ui.MenuItem (get_element_label_text (element)) {
                represented_object = (Object)element
            };

            weak IMixerElementViewModel weak_element = element;
            // Update the menu item whenever the represented element changes
            element.notify.connect ((sender, property) => {
                menu_item.label.text = get_element_label_text (weak_element);
                sort_element_menu ();
            });

            // Emit a selection signal for this element when its menu item is selected
            menu_item.button.pressed.connect (() =>
                mixer_element_selected (weak_element));
            
            element_menu.add_menu_item (menu_item);
        }

        protected void remove_menu_item (Ui.MenuItem menu_item) {
            if (menu_item != null) {
                element_menu.remove_menu_item (menu_item);
            }
        }

        public void remove_element (IMixerElementViewModel element) {
            var menu_item = element_menu.find_menu_item<IMixerElementViewModel> (element, (menu_item, target_element) => {
                return target_element == (menu_item.represented_object as IMixerElementViewModel);
            });

            remove_menu_item (menu_item);
        }

        public void clear_elements () {
            var iter = element_menu.menu_item_iter ();
            while (iter.size > 0) {
                remove_menu_item (iter[0]);
            }
        }

        public bool has_single_element {
            get {
                return element_menu.menu_item_iter ().size == 1;
            }
        }

        public IMixerElementViewModel? first_element {
            get {
                if (element_menu.menu_item_iter ().size <= 0)
                    return null;
                
                return element_menu.menu_item_iter ().get (0).represented_object as IMixerElementViewModel;
            }
        }
    }
}
