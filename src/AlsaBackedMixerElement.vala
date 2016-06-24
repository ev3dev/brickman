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

/* AlsaBackedMixerElement.vala - Implementation of IMixerElementViewModel using ALSA API */

using Alsa;

namespace BrickManager {
    public class AlsaBackedMixerElement: IMixerElementViewModel, Object {
        const SimpleChannelId primary_channel_id = SimpleChannelId.MONO;

        unowned MixerElement alsa_element;
        SimpleElementId alsa_id;

        public AlsaBackedMixerElement(MixerElement element) {
            this.alsa_element = element;
            SimpleElementId.alloc(out alsa_id);
            element.get_id(alsa_id);
        }

        public string name {
            get {
                return alsa_id.get_name();
            }
        }

        public uint index {
            get {
                return alsa_id.get_index();
            }
        }

        public int volume {
            get {
                long volume = 0;
                alsa_element.get_playback_volume(primary_channel_id, out volume);

                long min_volume = 0, max_volume = 0;
                alsa_element.get_playback_volume_range(out min_volume, out max_volume);
                
                // Prevent division by zero
                if(max_volume == min_volume)
                    return 0;
                
                // Do calculations as floats so avoid odd-looking increments from truncation
                return (int)Math.round((volume - min_volume) * 100 / (float)(max_volume - min_volume));
            }
            set {
                long min_volume, max_volume;
                alsa_element.get_playback_volume_range(out min_volume, out max_volume);

                var constrained_volume = int.min(100, int.max(0, value));
                float scaled_volume = constrained_volume * (max_volume - min_volume) / 100f + min_volume;
                long rounded_volume = (long)Math.round(scaled_volume);

                alsa_element.set_playback_volume_all(rounded_volume);

                bool should_mute = rounded_volume <= min_volume;
                if (is_muted != should_mute) {
                    set_is_muted(should_mute);
                }
            }
        }

        public bool can_mute {
            get {
                return alsa_element.has_playback_switch();
            }
        }

        public bool is_muted {
            get {
                if (!can_mute) {
                    return false;
                }

                int mute_switch = 1;
                if(alsa_element.get_playback_switch(primary_channel_id, out mute_switch) != 0) {
                    critical("Error while getting mute switch state");
                }

                return mute_switch == 0;
            }
        }

        protected void set_is_muted(bool is_muted) {
            if(can_mute)
                alsa_element.set_playback_switch_all(is_muted ? 0 : 1);
        }
    }
}
