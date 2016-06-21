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

/* AlsaInterface.vala - Definitions for interfacing with ALSA */

using Alsa;

namespace BrickManager {
    public interface IMixerElementViewModel : Object {
        public const int MIN_VOLUME = 0;
        public const int MAX_VOLUME = 100;
        public const int HALF_VOLUME = (MAX_VOLUME + MIN_VOLUME) / 2;

        public abstract string name { get; }
        public abstract uint index { get; }
        public abstract int volume { get; set; }
        public abstract bool can_mute { get; }
        public abstract bool is_muted { get; }
    }

    public class FakeMixerElement: IMixerElementViewModel, Object {
        private string _name;
        private uint _index;
        private int _volume;
        private bool _can_mute;
        private bool _is_muted;

        public string name {
            get {
                return _name;
            }
        }

        public uint index {
            get {
                return _index;
            }
        }

        public FakeMixerElement(string name, uint index, int volume, bool can_mute) {
            set_name(name);
            set_index(index);
            this.volume = volume;

            set_can_mute(can_mute);
        }

        public int volume {
            get {
                return _volume;
            }
            set {
                _volume = int.min(100, int.max(0, value));

                bool should_mute = _volume <= 0;
                if(_is_muted != should_mute)
                    set_is_muted(should_mute);
            }
        }

        public bool can_mute {
            get {
                return _can_mute;
            }
        }
        public bool is_muted {
            get {
                return _is_muted;
            }
        }

        public void set_name(string new_name) {
            this._name = new_name;
            notify_property("name");
        }

        public void set_index(uint new_index) {
            this._index = new_index;
            notify_property("index");
        }

        public void set_can_mute(bool can_mute) {
            this._can_mute = can_mute;
            notify_property("can_mute");
        }

        public void set_is_muted(bool is_muted) {
            this._is_muted = is_muted;
            notify_property("is_muted");
        }
    }
}