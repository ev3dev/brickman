/*
 * systemd -- vala bindings for systemd d-bus
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
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

namespace Systemd.Logind {
    [DBus  (use_string_marshalling = true)]
    public enum SessionToKill {
        [DBus  (value = "leader")]
        LEADER,
        [DBus  (value = "all")]
        ALL;
    }

    [DBus  (use_string_marshalling = true)]
    public enum CanResponse {
        [DBus  (value = "na")]
        NOT_APPLICABLE,
        [DBus  (value = "yes")]
        YES,
        [DBus  (value = "no")]
        NO,
        [DBus  (value = "challenge")]
        CHALLENGE;
    }

    [DBus  (use_string_marshalling = true)]
    public enum InhibitMode {
        [DBus  (value = "block")]
        BLOCK,
        [DBus  (value = "delay")]
        DELAY;
    }

    public class Manager {
        static Gee.HashMap<ObjectPath, weak Manager> object_map;

        static construct {
            object_map = new Gee.HashMap<ObjectPath, weak Manager> ();
        }

        ObjectPath path;
        org.freedesktop.login1.Manager manager;

        public uint32 auto_vt_count { get { return manager.auto_vt_count; } }
        public string[] kill_only_users { owned get { return manager.kill_only_users; } }
        public string[] kill_exclude_users { owned get { return manager.kill_exclude_users; } }
        public bool kill_user_processes { get { return manager.kill_user_processes; } }
        public bool idle_hint { get { return manager.idle_hint; } }
        public uint64 idle_since_hint { get { return manager.idle_since_hint; } }
        public uint64 idle_since_hint_monotonic { get { return manager.idle_since_hint_monotonic; } }
        public string block_inhibited { owned get { return manager.block_inhibited; } }
        public string delay_inhibited { owned get { return manager.delay_inhibited; } }
        public uint64 inhibit_delay_max_usec { get { return manager.inhibit_delay_max_usec; } }
        public string handle_power_key { owned get { return manager.handle_power_key; } }
        public string handle_suspend_key { owned get { return manager.handle_suspend_key; } }
        public string handle_hibernate_key { owned get { return manager.handle_hibernate_key; } }
        public string handle_lid_switch { owned get { return manager.handle_lid_switch; } }
        public string idle_action { owned get { return manager.idle_action; } }
        public uint64 idle_action_usec { get { return manager.idle_action_usec; } }
        public bool preparing_for_shutdown { get { return manager.preparing_for_shutdown; } }
        public bool preparing_for_sleep { get { return manager.preparing_for_sleep; } }

        public static async Manager get_system_manager () throws IOError {
            return yield Manager.get_instance_for_path (
                    (ObjectPath)org.freedesktop.login1.Manager.OBJECT_PATH);
        }

        static async Manager get_instance_for_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            return yield new_async (path);
        }

        static async Manager new_async (ObjectPath path) throws IOError {
            var instance = new Manager ();
            instance.path = path;
            instance.manager = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.login1.SERVICE_NAME, path);
            object_map[path] = instance;
            weak Manager weak_instance = instance;
            //instance.manager.session_new.connect ((id, path) => weak_instance.on_session_new.begin (id, path));
            //instance.manager.session_removed.connect ((id, path) => weak_instance.on_session_removed.begin (id, path));
            //instance.manager.user_new.connect ((id, path) => weak_instance.on_user_new.begin (id, path));
            //instance.manager.user_removed.connect ((id, path) => weak_instance.on_user_removed.begin (id, path));
            //instance.manager.seat_new.connect ((id, path) => weak_instance.on_seat_new.begin (id, path));
            //instance.manager.seat_removed.connect ((id, path) => weak_instance.on_seat_removed.begin (id, path));
            instance.manager.prepare_for_shutdown.connect ((before) => weak_instance.on_prepare_for_shutdown (before));
            instance.manager.prepare_for_sleep.connect ((before) => weak_instance.on_prepare_for_sleep (before));
            instance.manager.properties_changed.connect (weak_instance.on_properties_changed);
            return instance;
        }

        ~Manager () {
            object_map.unset (path);
        }

        //public async ObjectPath get_session (string id) throws IOError;
        //public async ObjectPath get_session_by_pid (uint process_id) throws IOError;
        //public async ObjectPath get_user (uint32 user_id) throws IOError;
        //public async ObjectPath get_user_by_pid (uint pid) throws IOError;
        //public async ObjectPath get_seat (string seat_id) throws IOError;
        //public async SessionInfo[] list_sessions () throws IOError;
        //public async UserInfo[] list_users () throws IOError;
        //public async SeatInfo[] list_seats () throws IOError;
        //public async SeatInfo[] list_inhibitors () throws IOError;
        public async void activate_session (string session_id) throws IOError {
            yield manager.activate_session (session_id);
        }
        public async void activate_session_on_seat (string session_id, string seat_id) throws IOError {
            yield manager.activate_session_on_seat (session_id, seat_id);
        }
        public async void lock_session (string session_id) throws IOError {
            yield manager.lock_session (session_id);
        }
        public async void unlock_session (string session_id) throws IOError {
            yield manager.unlock_session (session_id);
        }
        public async void lock_sessions () throws IOError {
            yield manager.lock_sessions ();
        }
        public async void unlock_sessions () throws IOError {
            yield manager.unlock_sessions ();
        }
        public async void kill_session (string session_id, SessionToKill session, int32 @signal = Posix.SIGTERM) throws IOError {
            yield manager.kill_session (session_id, session, @signal);
        }
        public async void kill_user (string user_id, int32 @signal = Posix.SIGTERM) throws IOError {
            yield manager.kill_user (user_id, @signal);
        }
        public async void terminate_session (string session_id) throws IOError {
            yield manager.terminate_session (session_id);
        }
        public async void terminate_user (uint32 user_id) throws IOError {
            yield manager.terminate_user (user_id);
        }
        public async void terminate_seat (string seat_id) throws IOError {
            yield manager.terminate_seat (seat_id);
        }
        public async void set_user_linger (uint32 user_id, bool enable, bool interactive = false) throws IOError {
            yield manager.set_user_linger (user_id, enable, interactive);
        }
        public async void attach_Device (string seat_id, string sysfs_path, bool interactive = false) throws IOError {
            yield manager.attach_Device (seat_id, sysfs_path, interactive);
        }
        public async void flush_devices (bool interactive = false) throws IOError {
            yield manager.flush_devices (interactive);
        }
        public async void power_off (bool interactive = false) throws IOError {
            yield manager.power_off (interactive);
        }
        public async void reboot (bool interactive = false) throws IOError {
            yield manager.reboot (interactive);
        }
        public async void suspend (bool interactive = false) throws IOError {
            yield manager.suspend (interactive);
        }
        public async void hibernate (bool interactive = false) throws IOError {
            yield manager.hibernate (interactive);
        }
        public async void hybrid_sleep (bool interactive = false) throws IOError {
            yield manager.hybrid_sleep (interactive);
        }
        public async CanResponse can_power_off () throws IOError {
            return yield manager.can_power_off ();
        }
        public async CanResponse can_reboot () throws IOError {
            return yield manager.can_reboot ();
        }
        public async CanResponse can_suspend () throws IOError {
            return yield manager.can_suspend ();
        }
        public async CanResponse can_hybrid_sleep () throws IOError {
            return yield manager.can_hybrid_sleep ();
        }
        public async UnixInputStream inhibit (string who, string what, string why, InhibitMode mode) throws IOError {
            return yield manager.inhibit (who, what, why, mode);
        }

/*
        public signal void session_new (string session_id, Session session);
        async void on_session_new (string session_id, ObjectPath path) {
            var session = yield Session.get_instance_for_path (path);
            session_new (session_id, session);
        }
        public signal void session_removed (string session_id, Session session);
        async void on_session_removed (string session_id, ObjectPath path) {
            var session = yield Session.get_instance_for_path (path);
            session_removed (session_id, session);
        }
        public signal void user_new (string user_id, User user);
        async void on_user_new (string user_id, ObjectPath path) {
            var user = yield User.get_instance_for_path (path);
            user_new (user_id, user);
        }
        public signal void user_removed (string user_id, User user);
        async void on_user_removed (string user_id, ObjectPath path) {
            var user = yield User.get_instance_for_path (path);
            user_removed (user_id, user);
        }
        public signal void seat_new (string seat_id, Seat seat);
        async void on_seat_new (string seat_id, ObjectPath path) {
            var seat = yield Seat.get_instance_for_path (path);
            seat_new (seat_id, seat);
        }
        public signal void seat_removed (string seat_id, Seat seat);
        async void on_seat_removed (string seat_id, ObjectPath path) {
            var seat = yield Seat.get_instance_for_path (path);
            seat_removed (seat_id, seat);
        }
*/
        public signal void prepare_for_shutdown (bool before_shutdown);
        void on_prepare_for_shutdown (bool before_shutdown) {
            (before_shutdown);
        }
        public signal void prepare_for_sleep (bool before_shutdown);
        void on_prepare_for_sleep (bool before_shutdown) {
            (before_shutdown);
        }

        void on_properties_changed (string iface, HashTable<string, Variant?> changed_properties, string[] invalidated_properties) {
            // TODO: notify properties
        }
    }
}