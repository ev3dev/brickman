/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2015 David Lechner <david@lechnology.com>
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
 * FileBrowserWindow.vala - Displays contents of a directory
 */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class FileBrowserWindow : BrickManagerWindow {
        Label current_directory_label;
        Ui.Menu file_menu;
        File? selected_file;

        public unowned CompareDataFunc<Ui.MenuItem>? sort_files_func;

        public string current_directory {
            get { return current_directory_label.text; }
            set { current_directory_label.text = value; }
        }

        public signal void file_selected (File file);

        public FileBrowserWindow (string display_name) {
            title = display_name;
            current_directory_label = new Label ("???") {
                text_horizontal_align = Grx.TextHAlign.LEFT,
                vertical_align = WidgetAlign.START,
                padding_bottom = 2,
                border_bottom = 1
            };
            content_vbox.add (current_directory_label);
            file_menu = new Ui.Menu ();
            content_vbox.add (file_menu);
        }

        public void add_file (string file_name, File file) {
            // make sure we don't end up with duplicates
            remove_file (file);

            var menu_item = new Ui.MenuItem (file_name) {
                represented_object = file
            };
            menu_item.button.pressed.connect (() => {
                selected_file = file;
                file_selected (file);
            });
            file_menu.add_menu_item (menu_item);
            // TODO: we would get much better performance if we just inserted
            // the item in the correct place instead of sorting the entire list
            // each time an item is inserted.
            file_menu.sort_menu_items (sort_files_func);

            // if this file was the most recently selected, make sure it retains
            // focus.
            if (selected_file != null && file.equal (selected_file)) {
                menu_item.button.focus ();
            }
        }

        public void remove_file (File file) {
            var menu_item = file_menu.find_menu_item<File> (file, (mi, f1) => {
                var f2 = mi.represented_object as File;
                return f1.equal (f2);
            });
            if (menu_item != null) {
                file_menu.remove_menu_item (menu_item);
            }
        }

        public void clear_files () {
            file_menu.remove_all_menu_items ();
        }
    }
}
