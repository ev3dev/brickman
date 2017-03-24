/*
 * systemd -- vala bindings for systemd d-bus
 *
 * Copyright  (C) 2014 David Lechner <david@lechnology.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace org.freedesktop.login1 {
    public const string SERVICE_NAME = "org.freedesktop.login1";

    [DBus  (name = "org.freedesktop.login1.Manager")]
    public interface Manager : DBusProxy {
        public const string OBJECT_PATH = "/org/freedesktop/login1";

        public struct SessionInfo {
            string id;
            uint32 user_id;
            string user_name;
            string seat_id;
            ObjectPath session;
        }

        public struct UserInfo {
            uint32 id;
            string name;
            ObjectPath user;
        }

        public struct SeatInfo {
            string id;
            ObjectPath seat;
        }

        public struct InhibitorInfo {
            string what;
            string who;
            string why;
            string mode;
            uint32 user_id;
            uint32 process_id;
        }

        public abstract async ObjectPath get_session (string id) throws IOError;
        public abstract async ObjectPath get_session_by_pid (uint process_id) throws IOError;
        public abstract async ObjectPath get_user (uint32 user_id) throws IOError;
        public abstract async ObjectPath get_user_by_pid (uint pid) throws IOError;
        public abstract async ObjectPath get_seat (string seat_id) throws IOError;
        public abstract async SessionInfo[] list_sessions () throws IOError;
        public abstract async UserInfo[] list_users () throws IOError;
        public abstract async SeatInfo[] list_seats () throws IOError;
        public abstract async SeatInfo[] list_inhibitors () throws IOError;
        public abstract async void activate_session (string session_id) throws IOError;
        public abstract async void activate_session_on_seat (string session_id, string seat_id) throws IOError;
        public abstract async void lock_session (string session_id) throws IOError;
        public abstract async void unlock_session (string session_id) throws IOError;
        public abstract async void lock_sessions () throws IOError;
        public abstract async void unlock_sessions () throws IOError;
        public abstract async void kill_session (string session_id, Systemd.Logind.SessionToKill session, int32 @signal) throws IOError;
        public abstract async void kill_user (uint32 user_id, int32 @signal) throws IOError;
        public abstract async void terminate_session (string session_id) throws IOError;
        public abstract async void terminate_user (uint32 user_id) throws IOError;
        public abstract async void terminate_seat (string seat_id) throws IOError;
        public abstract async void set_user_linger (uint32 user_id, bool enable, bool interactive) throws IOError;
        public abstract async void attach_Device (string seat_id, string sysfs_path, bool interactive) throws IOError;
        public abstract async void flush_devices (bool interactive) throws IOError;
        public abstract async void power_off (bool interactive) throws IOError;
        public abstract async void reboot (bool interactive) throws IOError;
        public abstract async void suspend (bool interactive) throws IOError;
        public abstract async void hibernate (bool interactive) throws IOError;
        public abstract async void hybrid_sleep (bool interactive) throws IOError;
        public abstract async Systemd.Logind.CanResponse can_power_off () throws IOError;
        public abstract async Systemd.Logind.CanResponse can_reboot () throws IOError;
        public abstract async Systemd.Logind.CanResponse can_suspend () throws IOError;
        public abstract async Systemd.Logind.CanResponse can_hybrid_sleep () throws IOError;
        // FIXME: This does not build on stretch
        // logind-interfaces.c: In function 'org_freedesktop_login1_manager_proxy_inhibit_async':
        // logind-interfaces.c:3185:2: error: '_fd_list' undeclared (first use in this function)
#if 0
        public abstract async UnixInputStream inhibit (string who, string what, string why, Systemd.Logind.InhibitMode mode) throws IOError;
#endif

        public abstract signal void session_new (string session_id, ObjectPath session);
        public abstract signal void session_removed (string session_id, ObjectPath session);
        public abstract signal void user_new (uint32 user_id, ObjectPath user);
        public abstract signal void user_removed (uint32 user_id, ObjectPath user);
        public abstract signal void seat_new (string seat_id, ObjectPath seat);
        public abstract signal void seat_removed (string seat_id, ObjectPath seat);
        public abstract signal void prepare_for_shutdown (bool before_shutdown);
        public abstract signal void prepare_for_sleep (bool before_shutdown);

        [DBus  (name = "NAutoVTs")]
        public abstract uint32 auto_vt_count { get; }
        public abstract string[] kill_only_users { owned get; }
        public abstract string[] kill_exclude_users { owned get; }
        public abstract bool kill_user_processes { get; }
        public abstract bool idle_hint { get; }
        public abstract uint64 idle_since_hint { get; }
        public abstract uint64 idle_since_hint_monotonic { get; }
        public abstract string block_inhibited { owned get; }
        public abstract string delay_inhibited { owned get; }
        public abstract uint64 inhibit_delay_max_usec { get; }
        public abstract string handle_power_key { owned get; }
        public abstract string handle_suspend_key { owned get; }
        public abstract string handle_hibernate_key { owned get; }
        public abstract string handle_lid_switch { owned get; }
        public abstract string idle_action { owned get; }
        public abstract uint64 idle_action_usec { get; }
        public abstract bool preparing_for_shutdown { get; }
        public abstract bool preparing_for_sleep { get; }
    }
}
