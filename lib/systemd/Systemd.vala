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

namespace Systemd {
    [DBus (use_string_marshaling = true)]
    public enum UnitMode {
        [DBus (value = "replace")]
        REPLACE,
        [DBus (value = "fail")]
        FAIL,
        [DBus (value = "isolate")]
        ISOLATE,
        [DBus (value = "ignore-dependencies")]
        IGNORE_DEPENENCIES,
        [DBus (value = "ignore-requirements")]
        IGNORE_REQUIREMENTS,
    }

    [DBus (use_string_marshaling = true)]
    public enum JobResult {
        [DBus (value = "done")]
        DONE, 
        [DBus (value = "canceled")]
        CANCELED, 
        [DBus (value = "timeout")]
        TIMEOUT, 
        [DBus (value = "failed")]
        FAILED, 
        [DBus (value = "dependency")]
        DEPENENCY, 
        [DBus (value = "skipped")]
        SKIPPED
    }

    public class UnitInfo {
        org.freedesktop.systemd1.Manager.UnitInfo info;

        public string id { get { return info.id; } }
        public string description { get { return info.description; } }
        public string load_state { get { return info.load_state; } }
        public string active_state { get { return info.active_state; } }
        public string sub_state { get { return info.sub_state; } }
        public string following { get { return info.following; } }
        public Unit unit { get; private set; }
        public uint32 job_id { get { return info.job_id; } }
        public string job_type { get { return info.job_type; } }
        public Job job { get; private set; }

        public static async UnitInfo new_async (org.freedesktop.systemd1.Manager.UnitInfo info) throws IOError {
            var instance = new UnitInfo ();
            instance.info = info;
            instance._unit = yield Unit.get_instance_for_path (info.unit_path);
            instance._job = yield Job.get_instance_for_path (info.job_path);
            return instance;
        }
    }

    public class JobInfo {
        org.freedesktop.systemd1.Manager.JobInfo info;

        public uint32 id { get { return info.id; } }
        public string name { get { return info.name; } }
        public string type_ { get { return info.type; } }
        public string state { get { return info.state; } }
        public Job job { get; private set; }
        public Unit unit { get; private set; }

        internal static async JobInfo new_async (org.freedesktop.systemd1.Manager.JobInfo info) throws IOError {
            var instance = new JobInfo ();
            instance.info = info;
            instance._job = yield Job.get_instance_for_path (info.job_path);
            instance._unit = yield Unit.get_instance_for_path (info.unit_path);
            return instance;
        }
    }

    public class Manager : Object {
        static Gee.HashMap<ObjectPath, weak Manager> object_map;

        static construct {
            object_map = new Gee.HashMap<ObjectPath, weak Manager> ();
        }

        ObjectPath path;
        org.freedesktop.systemd1.Manager manager;

        public static async Manager get_system_manager () throws IOError {
            return yield Manager.get_instance_for_path (
                    (ObjectPath)org.freedesktop.systemd1.Manager.OBJECT_PATH);
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
                org.freedesktop.systemd1.SERVICE_NAME, path);
            object_map[path] = instance;
            yield instance.manager.subscribe ();
            weak Manager weak_instance = instance;
            instance.manager.unit_new.connect ((id, path) => weak_instance.on_unit_new.begin (id, path));
            instance.manager.unit_removed.connect ((id, path) => weak_instance.on_unit_removed.begin (id, path));
            instance.manager.job_new.connect ((id, path) => weak_instance.on_job_new.begin (id, path));
            instance.manager.job_removed.connect ((id, path, result) => weak_instance.on_job_removed.begin (id, path, result));
            instance.manager.properties_changed.connect (weak_instance.on_properties_changed);
            return instance;
        }

        ~Manager () {
            object_map.unset (path);
        }

        public string[] environment { owned get { return manager.environment; } }

        public async UnitInfo[] list_units () throws IOError {
            var units = yield manager.list_units ();
            var result = new UnitInfo[units.length];
            var i = 0;
            foreach (var info in units) {
                result[i++] = yield UnitInfo.new_async (info);
            }
            return result;
        }
        public async JobInfo[] list_jobs () throws IOError {
            var jobs = yield manager.list_jobs ();
            var result = new JobInfo[jobs.length];
            var i = 0;
            foreach (var job in jobs) {
                result[i++] = yield JobInfo.new_async (job);
            }
            return result;
        }

        public async Unit get_unit (string name) throws IOError {
            var path = yield manager.get_unit (name);
            return yield Unit.get_instance_for_path (path);
        }
        public async Unit get_unit_by_pid (uint32 pid) throws IOError {
            var path = yield manager.get_unit_by_pid (pid);
            return yield Unit.get_instance_for_path (path);
        }
        public async Unit load_unit (string name) throws IOError {
            var path = yield manager.load_unit (name);
            return yield Unit.get_instance_for_path (path);
        }
        public async Job get_job (uint32 id) throws IOError {
            var path = yield manager.get_job (id);
            return yield Job.get_instance_for_path (path);
        }

        public async Job start_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError {
            var path = yield manager.start_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job start_unit_replace (string old_unit, string new_unit, UnitMode mode = UnitMode.REPLACE) throws IOError {
            var path = yield manager.start_unit_replace (old_unit, new_unit, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job stop_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError {
            var path = yield manager.stop_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError {
            var path = yield manager.reload_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError{
            var path = yield manager.restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job try_restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError{
            var path = yield manager.try_restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_or_restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError{
            var path = yield manager.reload_or_restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_or_try_restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws IOError{
            var path = yield manager.reload_or_try_restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async void reset_failed_unit (string name) throws IOError {
            yield manager.reset_failed_unit (name);
        }

        public async void clear_jobs () throws IOError {
            yield manager.clear_jobs ();
        }

        public async void reload () throws IOError {
            yield manager.reload ();
        }
        public async void reexecute () throws IOError {
            yield manager.reexecute ();
        }
        public async void exit () throws IOError {
            yield manager.exit ();
        }

        public async Unit create_snapshot (string name, bool cleanup = true) throws IOError {
            var path = yield manager.create_snapshot (name, cleanup);
            return yield Unit.get_instance_for_path (path);
        }

        public async void set_environment (string[] names) throws IOError {
            yield manager.set_environment (names);
        }
        public async void unset_environment (string[] names) throws IOError {
            yield manager.unset_environment (names);
        }

        public signal void unit_new (string id, Unit unit);
        async void on_unit_new (string id, ObjectPath path) {
            try {
                var unit = yield Unit.get_instance_for_path (path);
                unit_new (id, unit);
            } catch (IOError err) {
                critical (err.message);
            }
        }
        public signal void unit_removed (string id, Unit unit);
        async void on_unit_removed (string id, ObjectPath path) {
            try {
                var unit = yield Unit.get_instance_for_path (path);
                unit_removed (id, unit);
            } catch (IOError err) {
                critical (err.message);
            }
        }
        public signal void job_new (uint32 id, Unit unit);
        async void on_job_new (uint32 id, ObjectPath path) {
            try {
                var unit = yield Unit.get_instance_for_path (path);
                job_new (id, unit);
            } catch (IOError err) {
                critical (err.message);
            }
        }
        public signal void job_removed (uint32 id, Unit unit, JobResult result);
        async void on_job_removed (uint32 id, ObjectPath path, JobResult result) {
            try {
                var unit = yield Unit.get_instance_for_path (path);
                job_removed (id, unit, result);
            } catch (IOError err) {
                critical (err.message);
            }
        }

        void on_properties_changed (string iface, HashTable<string, Variant?> changed_properties, string[] invalidated_properties) {
            // TODO: notify properties
        }
    }
/*
    [Compact]
    public class JobLink {
        org.freedesktop.systemd1.Unit.JobLink job_link;

        public uint32 id { get { return id; } }
        public Job job { get; private set; }

        public static async JobLink new_async (org.freedesktop.systemd1.Unit.JobLink job_link) throws IOError {
            var instance = new JobLink ();
            instance.job_link = job_link;
            instance._job = yield Job.get_instance_for_path (job_link.path);
            return instance;
        }
    }
*/
    public class Unit : Object {
        static Gee.HashMap<ObjectPath, weak Unit> object_map;

        static construct {
            object_map = new Gee.HashMap<ObjectPath, weak Unit> ();
        }

        ObjectPath path;
        org.freedesktop.systemd1.Unit unit;

        public string id { owned get { return unit.id; } }
        public string[] names { owned get { return unit.names; } }
        public string following { owned get { return unit.following; } }
        public string[] requires { owned get { return unit.requires; } }
        public string[] requires_overridable { owned get { return unit.requires_overridable; } }
        public string[] requisite { owned get { return unit.requisite; } }
        public string[] requisite_overridable { owned get { return unit.requisite_overridable; } }
        public string[] wants { owned get { return unit.wants; } }
        public string[] required_by { owned get { return unit.required_by; } }
        public string[] required_by_overridable { owned get { return unit.required_by_overridable; } }
        public string[] wanted_by { owned get { return unit.wanted_by; } }
        public string[] conflicts { owned get { return unit.conflicts; } }
        public string[] conflicted_by { owned get { return unit.conflicted_by; } }
        public string[] before { owned get { return unit.before; } }
        public string[] after { owned get { return unit.after; } }
        public string[] on_failure { owned get { return unit.on_failure; } }
        public string description { owned get { return unit.description; } }
        public string load_state { owned get { return unit.load_state; } }
        public string active_state { owned get { return unit.active_state; } }
        public string sub_state { owned get { return unit.sub_state; } }
        public string fragment_path { owned get { return unit.fragment_path; } }
        public uint64 inactive_exit_timestamp { get { return unit.inactive_exit_timestamp; } }
        public uint64 active_enter_timestamp { get { return unit.active_enter_timestamp; } }
        public uint64 active_exit_timestamp { get { return unit.active_exit_timestamp; } }
        public uint64 inactive_enter_timestamp { get { return unit.inactive_enter_timestamp; } }
        public bool can_start { get { return unit.can_start; } }
        public bool can_stop { get { return unit.can_stop; } }
        public bool can_reload { get { return unit.can_reload; } }
        //public JobLink job { owned get { return new JobLink (unit.job); } }
        public bool recursive_stop { get { return unit.recursive_stop; } }
        public bool stop_when_unneeded { get { return unit.stop_when_unneeded; } }
        public bool refuse_manual_start { get { return unit.refuse_manual_start; } }
        public bool refuse_manual_stop { get { return unit.refuse_manual_stop; } }
        public bool default_dependencies { get { return unit.default_dependencies; } }
        public string default_control_group { owned get { return unit.default_control_group; } }
        public string[] control_groups { owned get { return unit.control_groups; } }
        public bool need_daemon_reload { get { return unit.need_daemon_reload; } }
        public uint64 job_timeout_usec { get { return unit.job_timeout_usec; } }

        internal static async Unit get_instance_for_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            return yield new_async (path);
        }

        static async Unit new_async (ObjectPath path) throws IOError {
            var instance = new Unit ();
            instance.path = path;
            instance.unit = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            object_map[path] = instance;
            instance.unit.properties_changed.connect (instance.on_properties_changed);
            return instance;
        }

        ~Unit () {
            object_map.unset (path);
        }

        public async Job start (UnitMode mode) throws IOError {
            var path = yield unit.start (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job stop (UnitMode mode) throws IOError {
            var path = yield unit.stop (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload (UnitMode mode) throws IOError {
            var path = yield unit.reload (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job restart (UnitMode mode) throws IOError {
            var path = yield unit.restart (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job try_restart (UnitMode mode) throws IOError {
            var path = yield unit.try_restart (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_or_restart (UnitMode mode) throws IOError {
            var path = yield unit.reload_or_restart (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_or_try_restart (UnitMode mode) throws IOError {
            var path = yield unit.reload_or_try_restart (mode);
            return yield Job.get_instance_for_path (path);
        }

        public async void reset_failed () throws IOError {
            yield unit.reset_failed ();
        }

        void on_properties_changed (string iface, HashTable<string, Variant?> changed_properties, string[] invalidated_properties) {
            // TODO: notify properties
        }
    }
/*
    [Compact]
    public class UnitLink {
        org.freedesktop.systemd1.Job.UnitLink unit_link;

        public uint32 id { get { return id; } }
        public Unit unit { get; private set; }

        public static async UnitLink new_async (org.freedesktop.systemd1.Job.UnitLink unit_link) throws IOError {
            var instance = new UnitLink ();
            instance.unit_link = unit_link;
            instance._unit = yield Unit.get_instance_for_path (unit_link.path);
            return instance;
        }
    }
*/
    public class Job : Object {
        static Gee.HashMap<ObjectPath, weak Job> object_map;

        static construct {
            object_map = new Gee.HashMap<ObjectPath, weak Job> ();
        }

        ObjectPath path;
        org.freedesktop.systemd1.Job job;

        public uint32 id { get { return job.id; } }
        public string state { owned get { return job.state; } }
        public string job_type { owned get { return job.job_type; } }
        //public UnitLink unit { owned get { return new UnitLink (job.unit); } }

        internal static async Job get_instance_for_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.has_key (path))
                return object_map[path];
            return yield new_async (path);
        }

        static async Job new_async (ObjectPath path) throws IOError {
            var instance = new Job ();
            instance.path = path;
            instance.job = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            object_map[path] = instance;
            instance.job.properties_changed.connect (instance.on_properties_changed);
            return instance;
        }

        ~Job () {
            object_map.unset (path);
        }

        public async void cancel () throws IOError {
            yield job.cancel ();
        }

        void on_properties_changed (string iface, HashTable<string, Variant?> changed_properties, string[] invalidated_properties) {
            // TODO: notify properties
        }
    }
}