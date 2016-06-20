/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright (C) 2016 Kaelin Laundry <wasabifan@outlook.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

/* FakeAudioController.vala - Fake Audio controller for testing */

using Ev3devKit;
using Ev3devKit.Ui;

namespace BrickManager {
    public class FakeAudioController : Object, IBrickManagerModule {
        private const int VOLUME_STEP = 5;

        MixerElementSelectorWindow mixer_select_window;
        MixerElementVolumeWindow volume_window;

        public string display_name { get { return "Audio"; } }

        public FakeAudioController (Gtk.Builder builder) {
            // Initialize windows that the controller needs
            mixer_select_window = new MixerElementSelectorWindow ();
            volume_window = new MixerElementVolumeWindow();

            // Register for callback so that we can focus on the correct control panel tab
            // the first time either window is invoked
            var control_panel_notebook = builder.get_object ("control-panel-notebook") as Gtk.Notebook;
            mixer_select_window.shown.connect (() =>
                control_panel_notebook.page = (int)ControlPanel.Tab.AUDIO);
            volume_window.shown.connect (() =>
                control_panel_notebook.page = (int)ControlPanel.Tab.AUDIO);
            
            // Initialize items in brickman for all current elements
            var mixer_elems_liststore = builder.get_object ("mixer-elements-liststore") as Gtk.ListStore;
            mixer_elems_liststore.foreach ((model, path, iter) => {
                update_fake_element_from_liststore(iter, mixer_elems_liststore);
                return false;
            });

            // Propagate changes from liststore to views
            mixer_elems_liststore.row_changed.connect ((path, iter) => {
                update_fake_element_from_liststore(iter, mixer_elems_liststore);
            });

            // Link liststore and control panel GUI
            (builder.get_object ("mixer-element-name-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    mixer_elems_liststore, path, new_text, ControlPanel.AudioMixerElementsColumn.NAME));
            (builder.get_object ("mixer-element-index-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    mixer_elems_liststore, path, new_text, ControlPanel.AudioMixerElementsColumn.INDEX));
            (builder.get_object ("mixer-element-volume-cellrenderertext") as Gtk.CellRendererText)
                .edited.connect ((path, new_text) => ControlPanel.update_listview_text_item (
                    mixer_elems_liststore, path, new_text, ControlPanel.AudioMixerElementsColumn.VOLUME));
            (builder.get_object ("mixer-element-can-mute-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    mixer_elems_liststore, toggle, path, ControlPanel.AudioMixerElementsColumn.CAN_MUTE));
            (builder.get_object ("mixer-element-mute-cellrenderertoggle") as Gtk.CellRendererToggle)
                .toggled.connect ((toggle, path) => ControlPanel.update_listview_toggle_item (
                    mixer_elems_liststore, toggle, path, ControlPanel.AudioMixerElementsColumn.MUTE));

            // Configure the add button
            (builder.get_object ("mixer-element-add-button") as Gtk.Button).clicked.connect (() => {
                Gtk.TreeIter iter;
                mixer_elems_liststore.append (out iter);

                // Doing this all at once ensures that the row_changed handler is only called once,
                // and never called with partial data.
                mixer_elems_liststore.set_valuesv(iter, new int[] {
                        ControlPanel.AudioMixerElementsColumn.NAME,
                        ControlPanel.AudioMixerElementsColumn.INDEX,
                        ControlPanel.AudioMixerElementsColumn.VOLUME,
                        ControlPanel.AudioMixerElementsColumn.CAN_MUTE,
                        ControlPanel.AudioMixerElementsColumn.MUTE
                    }, new Value[] { "New Element", 0, ITestableMixerElement.HALF_VOLUME, true, false });
            });

            // Store references to the remove button
            var mixer_element_remove_button = builder.get_object ("mixer-element-remove-button") as Gtk.Button;
            var mixer_element_treeview_selection = (builder.get_object ("mixer-elements-treeview") as Gtk.TreeView).get_selection ();

            // Configure the remove button action
            mixer_element_remove_button.clicked.connect (() => {
                Gtk.TreeModel model;
                Gtk.TreeIter iter;

                if (mixer_element_treeview_selection.get_selected (out model, out iter)) {
                    Value user_data;
                    model.get_value (iter, ControlPanel.AudioMixerElementsColumn.USER_DATA, out user_data);

                    var mixer_element = (FakeMixerElement)user_data.get_pointer ();
                    if (mixer_element != null)
                        mixer_select_window.remove_element (mixer_element);

                    mixer_elems_liststore.remove (iter);
                }
            });

            // Desensitize the remove button if nothing is selected
            mixer_element_treeview_selection.changed.connect (() => {
                mixer_element_remove_button.sensitive = mixer_element_treeview_selection.count_selected_rows () > 0;
            });

            // Invoke the button logic once to initialize it
            mixer_element_treeview_selection.changed ();

            // Configure the direct window link buttons
            (builder.get_object ("audio-mixer-select-window-button") as Gtk.Button).clicked.connect (() => 
                mixer_select_window.show());

            (builder.get_object ("audio-volume-window-button") as Gtk.Button).clicked.connect (() => {
                if(mixer_select_window.first_element == null)
                    return;

                volume_window.current_element = mixer_select_window.first_element;
                volume_window.show_element_details = !mixer_select_window.has_single_element;
                volume_window.show();
            });

            // Wire up handlers for volume window signals
            volume_window.volume_up.connect(() => {
                volume_window.current_element.volume += VOLUME_STEP;
                update_liststore_for_element(mixer_elems_liststore, volume_window.current_element);
            });

            volume_window.volume_down.connect(() => {
                volume_window.current_element.volume -= VOLUME_STEP;
                update_liststore_for_element(mixer_elems_liststore, volume_window.current_element);
            });

            volume_window.volume_half.connect(() => {
                volume_window.current_element.volume = ITestableMixerElement.HALF_VOLUME;
                update_liststore_for_element(mixer_elems_liststore, volume_window.current_element);
            });

            volume_window.volume_min.connect(() => {
                volume_window.current_element.volume = ITestableMixerElement.MIN_VOLUME;
                update_liststore_for_element(mixer_elems_liststore, volume_window.current_element);
            });

            volume_window.volume_max.connect(() => {
                volume_window.current_element.volume = ITestableMixerElement.MAX_VOLUME;
                update_liststore_for_element(mixer_elems_liststore, volume_window.current_element);
            });

            volume_window.mute_toggled.connect((is_muted) => {
                volume_window.current_element.is_muted = is_muted;
                update_liststore_for_element(mixer_elems_liststore, volume_window.current_element);
            });

            // Show volume window when mixer element is selected
            mixer_select_window.mixer_elem_selected.connect ((selected_element) => {
                volume_window.current_element = selected_element;
                volume_window.show_element_details = true;
                volume_window.show();
            });
        }

        /**
         * Updates the mixer element associated with the specified TreeIter object in the Control Panel
         * GUI with data from the backing ListStore. Will create the mixer element if one does not
         * already exist.
         */
        private void update_fake_element_from_liststore(Gtk.TreeIter iter, Gtk.ListStore mixer_elems_liststore) {
            Value name = get_liststore_value(mixer_elems_liststore, iter, ControlPanel.AudioMixerElementsColumn.NAME);
            Value index = get_liststore_value(mixer_elems_liststore, iter, ControlPanel.AudioMixerElementsColumn.INDEX);
            Value volume = get_liststore_value(mixer_elems_liststore, iter, ControlPanel.AudioMixerElementsColumn.VOLUME);
            Value can_mute = get_liststore_value(mixer_elems_liststore, iter, ControlPanel.AudioMixerElementsColumn.CAN_MUTE);
            Value mute = get_liststore_value(mixer_elems_liststore, iter, ControlPanel.AudioMixerElementsColumn.MUTE);
            Value user_data = get_liststore_value(mixer_elems_liststore, iter, ControlPanel.AudioMixerElementsColumn.USER_DATA);

            // The mixer elements will make sure that these numbers are within proper bounds later
            int parsed_index = (int)parse_double_with_default(index.get_string(), 0);        
            int parsed_volume = (int)parse_double_with_default(volume.get_string(), ITestableMixerElement.HALF_VOLUME);

            // This is guaranteed to be a fake mixer element; as such, it is referenced by the concrete implementation name
            FakeMixerElement? mixer_element = (FakeMixerElement?)user_data.get_pointer ();

            if(mixer_element == null) {
                mixer_element = new FakeMixerElement(name.get_string(), parsed_index, parsed_volume, can_mute.get_boolean(), mute.get_boolean());
                mixer_select_window.add_element(mixer_element);
                
                mixer_elems_liststore.set(iter, ControlPanel.AudioMixerElementsColumn.USER_DATA, mixer_element.ref ());
            }
            else {
                mixer_element.freeze_notify();
                mixer_element.set_name(name.get_string());
                mixer_element.set_index(parsed_index);
                mixer_element.volume = parsed_volume;
                mixer_element.set_can_mute(can_mute.get_boolean());
                mixer_element.is_muted = mute.get_boolean();
                mixer_element.thaw_notify();

                // If the original value was invalid and the mixer object modified it, replace the entered text with the valid version
                // This will invoke any active signal handlers again; while not optimal, running them twice shouldn't be a problem.
                if(index.get_string() != mixer_element.index.to_string() || volume.get_string() != mixer_element.volume.to_string()) {
                    update_liststore_for_element(mixer_elems_liststore, mixer_element, iter);
                }
            }
        }

        /**
         * Updates the ListStore entry associated with the specified mixer element with data from
         * the mixer element.
         */
        private void update_liststore_for_element(Gtk.ListStore mixer_elems_liststore, ITestableMixerElement element, Gtk.TreeIter? iter = null) {
            // Find the iter pointing to this element if one was not supplied
            if(iter == null) {
                mixer_elems_liststore.foreach((model, path, current_iter) => {
                    Value user_data = get_liststore_value(mixer_elems_liststore, current_iter, ControlPanel.AudioMixerElementsColumn.USER_DATA);
                    FakeMixerElement other_element = (FakeMixerElement)user_data.get_pointer();

                    if(other_element == element) {
                        iter = current_iter;
                        return true;
                    }

                    return false;
                });
            }

            mixer_elems_liststore.set_valuesv (iter,
                new int[] { 
                    ControlPanel.AudioMixerElementsColumn.NAME,
                    ControlPanel.AudioMixerElementsColumn.INDEX,
                    ControlPanel.AudioMixerElementsColumn.VOLUME,
                    ControlPanel.AudioMixerElementsColumn.CAN_MUTE,
                    ControlPanel.AudioMixerElementsColumn.MUTE
                }, new Value[] {
                    element.name,
                    element.index.to_string(),
                    element.volume.to_string(),
                    element.can_mute,
                    element.is_muted
            });
        }

        private Value get_liststore_value(Gtk.ListStore list_store, Gtk.TreeIter iter, int column) {
            Value ret_value;
            list_store.get_value (iter, column, out ret_value);
            return ret_value;
        }

        private double parse_double_with_default(string str, int default_value) {
            double parsed_result;
            if(double.try_parse(str, out parsed_result)) {
                return parsed_result;
            }

            return default_value;
        }

        public void show_main_window () {
            if(mixer_select_window.has_single_element) {
                volume_window.current_element = mixer_select_window.first_element;
                volume_window.show_element_details = false;
                volume_window.show();
            }
            else
                mixer_select_window.show ();
        }
    }
}
