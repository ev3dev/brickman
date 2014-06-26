/*
 * brickdm -- Brick Display Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * based in part on GNOME Power Manager:
 * Copyright (C) 2008-2011 Richard Hughes <richard@hughsie.com>
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
 * Device.vala:
 *
 * DBus interface for org.freedesktop.UPower.Device
 */

namespace UPower {

    [DBus (name = "org.freedesktop.UPower.Device")]
    interface Device : Object {
        public signal void changed ();

        public abstract string native_path { owned get; }
        public abstract string vendor { owned get; }
        public abstract string model { owned get; }
        public abstract string serial { owned get; }
        public abstract uint64 update_time { get; }
        abstract uint _device_type { get; }
        public abstract DeviceType device_type { get { return (DeviceType)_device_type; } }
        public abstract bool power_supply { get; }
        public abstract bool has_history { get; }
        public abstract bool has_statistics { get; }
        public abstract bool online { get; }
        public abstract double energy { get; }
        public abstract double energy_empty { get; }
        public abstract double energy_full { get; }
        public abstract double energy_full_design { get; }
        public abstract double energy_rate { get; }
        public abstract double voltage { get; }
        public abstract int64 time_to_empty { get; }
        public abstract int64 time_to_full { get; }
        public abstract double percentage { get; }
        public abstract bool is_present { get; }
        abstract uint _state { get; }
        public DeviceState state { get { return (DeviceState)_state; } }
        public abstract bool is_rechargeable { get; }
        public abstract double capacity { get; }
        public abstract uint _technology { get; }
        public DeviceTechnology technology { get { return (DeviceTechnology)_technology; } }
        public abstract bool recall_notice { get; }
        public abstract string recall_vendor { owned get; }
        public abstract string recall_url { owned get; }

        public abstract async void refresh () throws IOError;
        public abstract async UPower.HistoryItem[] get_history (string type, uint timespan, uint resolution) throws IOError;
        public abstract async UPower.StatsItem[] get_statistics (string type) throws IOError;
    }

    public struct HistoryItem {
        uint time;
        double value;
        uint state;
    }

    public struct StatsItem {
        double value;
        double accuracy;
    }

    public enum DeviceType {
        UNKNOWN,
        LINE_POWER,
        BATTERY,
        UPS,
        MONITOR,
        MOUSE,
        KEYBOARD,
        PDA,
        PHONE;

        public string to_string() {
            switch (this) {
                case UNKNOWN:
                    return "unknown";
                case LINE_POWER:
                    return "line power";
                case UPS:
                    return "UPS";
                case MONITOR:
                    return "monitor";
                case MOUSE:
                    return "mouse";
                case KEYBOARD:
                    return "keyboard";
                case PDA:
                    return "PDA";
                case PHONE:
                    return "phone";
                default:
                    assert_not_reached();
            }
        }
    }

    public enum DeviceState {
        UNKNOWN,
        CHARGING,
        DISCHARGING,
        EMPTY,
        FULLY_CHARGED,
        PENDING_CHARGE,
        PENDING_DISCHARGE;

        public string to_string() {
            switch (this) {
                case UNKNOWN:
                    return "unknown";
                case CHARGING:
                    return "charging";
                case DISCHARGING:
                    return "discharging";
                case EMPTY:
                    return "empty";
                case FULLY_CHARGED:
                    return "fully charged";
                case PENDING_CHARGE:
                    return "pending charge";
                case PENDING_DISCHARGE:
                    return "pending discharge";
                default:
                    assert_not_reached();
            }
        }
    }

    public enum DeviceTechnology {
        UNKNOWN,
        LITHIUM_ION,
        LITHIUM_POLYMER,
        LITHIUM_IRON_PHOSPHATE,
        LEAD_ACID,
        NICKEL_CADMIUM,
        NICKEL_METAL_HYDRIDE;

        public string to_string() {
            switch (this) {
                case UNKNOWN:
                    return "unknown";
                case LITHIUM_ION:
                    return "LiON";
                case LITHIUM_POLYMER:
                    return "LiPo";
                case LITHIUM_IRON_PHOSPHATE:
                    return "LFP";
                case LEAD_ACID:
                    return "lead–acid";
                case NICKEL_CADMIUM:
                    return "NiCd";
                case NICKEL_METAL_HYDRIDE:
                    return "NiMH";
                default:
                    assert_not_reached();
            }
        }
    }
}
