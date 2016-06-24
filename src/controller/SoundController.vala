/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2016 Kaelin Laundry <wasabifan@outlook.com>
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

/* SoundController.vala - Controller for sound volume control */

using Ev3devKit.Devices;
using Ev3devKit.Ui;
using Alsa;

namespace BrickManager {
    public class SoundController : Object, IBrickManagerModule {
        const int VOLUME_STEP = 10;

        Mixer mixer;
        MixerElementSelectorWindow mixer_select_window;
        MixerElementVolumeWindow volume_window;

        public string display_name { get { return "Sound"; } }

        private void initialize_mixer() {
            mixer = null;

            int err = Mixer.open(out mixer);
            if(err != 0) {
                critical("Failed to open mixer: %s", Alsa.strerror(err));
                return;
            }

            err = mixer.attach();
            if(err != 0) {
                critical("Failed to attach mixer: %s", Alsa.strerror(err));
                return;
            }

            err = mixer.register();
            if(err != 0) {
                critical("Failed to register mixer: %s", Alsa.strerror(err));
                return;
            }

            err = mixer.load();
            if(err != 0) {
                critical("Failed to load mixer: %s", Alsa.strerror(err));
                return;
            }
        }

        void create_main_window () {
            mixer_select_window = new MixerElementSelectorWindow ();

            mixer_select_window.mixer_elem_selected.connect ((selected_element) => {
                if(volume_window == null)
                    create_volume_window();

                volume_window.current_element = selected_element;
                volume_window.show_element_details = true;
                volume_window.show();
            });
        }

        void create_volume_window() {
            volume_window = new MixerElementVolumeWindow();

            weak MixerElementVolumeWindow weak_volume_window = volume_window;
            // Wire up handlers for volume window signals
            volume_window.volume_up.connect(() =>
                weak_volume_window.current_element.volume += VOLUME_STEP);

            volume_window.volume_down.connect(() =>
                weak_volume_window.current_element.volume -= VOLUME_STEP);

            volume_window.volume_min.connect(() =>
                weak_volume_window.current_element.volume = IMixerElementViewModel.MIN_VOLUME);
        }
        
        public void show_main_window () {
            if (mixer_select_window == null) {
                create_main_window ();
            }

            // Whenever the sound item is launched from the main menu,
            // repopulate the mixer list
            mixer_select_window.clear_elements();
            // Re-initializing will return updated data, including volume
            initialize_mixer();
            for (MixerElement element = mixer.first_elem(); element != null; element = element.next()) {
                mixer_select_window.add_element(new AlsaBackedMixerElement(element));
            }

            if (mixer_select_window.has_single_element) {
                if (volume_window == null)
                    create_volume_window();

                volume_window.current_element = mixer_select_window.first_element;
                volume_window.show_element_details = false;
                volume_window.show();
            } else {
                mixer_select_window.show ();
            }
        }
    }
}
