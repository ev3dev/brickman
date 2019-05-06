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

/* IMixerElementViewModel.vala - Interface for object controlling a mixer element */

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
}
