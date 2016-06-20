/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* BatteryController.vala - Controller for monitoring battery */

using Ev3devKit.Devices;
using Ev3devKit.Ui;
using Alsa;

namespace BrickManager {
    public class AudioController : Object, IBrickManagerModule {
        private const int VOLUME_STEP = 5;

        Mixer mixer;
        MixerElementSelectorWindow mixer_select_window;
        MixerElementVolumeWindow volume_window;

        public string display_name { get { return "Audio"; } }

        protected void initialize_mixer() {
            mixer = null;
            Mixer.open(out mixer);
            mixer.attach();
            mixer.register();
            mixer.load();
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

            // Wire up handlers for volume window signals
            volume_window.volume_up.connect(() =>
                volume_window.current_element.volume += VOLUME_STEP);

            volume_window.volume_down.connect(() =>
                volume_window.current_element.volume -= VOLUME_STEP);

            volume_window.volume_half.connect(() =>
                volume_window.current_element.volume = ITestableMixerElement.HALF_VOLUME);

            volume_window.volume_min.connect(() =>
                volume_window.current_element.volume = ITestableMixerElement.MIN_VOLUME);

            volume_window.volume_max.connect(() =>
                volume_window.current_element.volume = ITestableMixerElement.MAX_VOLUME);

            volume_window.mute_toggled.connect((is_muted) =>
                volume_window.current_element.is_muted = is_muted);
        }
        
        public void show_main_window () {
            if (mixer_select_window == null) {
                create_main_window ();
            }

            // Whenever the audio item is launched from the main menu,
            // repopulate the mixer list
            mixer_select_window.clear_elements();
            // Re-initializing will return updated data, including volume
            initialize_mixer();
            for(MixerElement element = mixer.first_elem(); element != null; element = element.next()) {
                mixer_select_window.add_element(new AlsaBackedMixerElement(element));
            }

            if(mixer_select_window.has_single_element) {
                if(volume_window == null)
                    create_volume_window();

                volume_window.current_element = mixer_select_window.first_element;
                volume_window.show_element_details = false;
                volume_window.show();
            }
            else
                mixer_select_window.show ();
        }
    }
}
