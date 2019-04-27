/*
 * systemd -- vala bindings for systemd d-bus
 *
 * Copyright (C) 2014-2015 David Lechner <david@lechnology.com>
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
    [DBus (use_string_marshalling = true)]
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
        IGNORE_REQUIREMENTS;

        public static extern UnitMode from_string (string value) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum UnitActiveState {
        [DBus (value = "active")]
        ACTIVE,
        [DBus (value = "reloading")]
        RELOADING,
        [DBus (value = "inactive")]
        INACTIVE,
        [DBus (value = "failed")]
        FAILED,
        [DBus (value = "activating")]
        ACTIVATING,
        [DBus (value = "deactivating")]
        DEACTIVATING;

        public static extern UnitActiveState from_string (string value) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum UnitFileState {
        [DBus (value = "enabled")]
        ENABLED,
        [DBus (value = "enabled-runtime")]
        ENABLED_RUNTIME,
        [DBus (value = "linked")]
        LINKED,
        [DBus (value = "linked-runtime")]
        LINKED_RUNTIME,
        [DBus (value = "masked")]
        MASKED,
        [DBus (value = "masked-runtime")]
        MASKED_RUNTIME,
        [DBus (value = "static")]
        STATIC,
        [DBus (value = "disabled")]
        DISABLED,
        [DBus (value = "invalid")]
        INVALID;

        public static extern UnitFileState from_string (string value) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
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
        DEPENDENCY, 
        [DBus (value = "skipped")]
        SKIPPED;

        public static extern JobResult from_string (string value) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum Who {
        [DBus (value = "main")]
        MAIN,
        [DBus (value = "control")]
        CONTROL,
        [DBus (value = "all")]
        ALL;

        public static extern Who from_string (string value) throws DBusError;
    }

    [DBus (use_string_marshalling = true)]
    public enum UnitLinkChangeType {
        [DBus (value = "symlink")]
        SYMLINK,
        [DBus (value = "unlink")]
        UNLINK;

        public static extern UnitLinkChangeType from_string (string value) throws DBusError;
    }

    public struct UnitFileInfo {
        string name;
        UnitFileState state;
    }

    public struct UnitLinkChangeInfo {
        UnitLinkChangeType change_type;
        string symlink_name;
        string destination_name;
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
        static HashTable<ObjectPath, weak Manager> object_map;

        static construct {
            object_map = new HashTable<ObjectPath, weak Manager> (str_hash, str_equal);
        }

        ObjectPath path;
        org.freedesktop.systemd1.Manager manager;
        org.freedesktop.DBus.Properties properties;

        public static async Manager get_system_manager () throws IOError {
            return yield Manager.get_instance_for_path (
                    new ObjectPath (org.freedesktop.systemd1.Manager.OBJECT_PATH));
        }

        static async Manager get_instance_for_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.contains (path)) {
                return object_map[path];
            }
            return yield new_async (path);
        }

        static async Manager new_async (ObjectPath path) throws IOError {
            var instance = new Manager ();
            instance.path = path;
            instance.manager = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            instance.properties = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            object_map[path] = instance;
            weak Manager weak_instance = instance;
            instance.manager.unit_new.connect ((id, path) => weak_instance.on_unit_new.begin (id, path));
            instance.manager.unit_removed.connect ((id, path) => weak_instance.on_unit_removed.begin (id, path));
            instance.manager.job_new.connect ((id, path, unit) => weak_instance.on_job_new.begin (id, path, unit));
            instance.manager.job_removed.connect ((id, path, unit, result) => weak_instance.on_job_removed.begin (id, path, unit, result));
            instance.properties.properties_changed.connect (weak_instance.on_properties_changed);
            return instance;
        }

        ~Manager () {
            object_map.remove (path);
        }

        public string[] environment { owned get { return manager.environment; } }

        /**
         * Get the unit object path for a unit name.
         * @param name The unit name
         * @return A Unit object.
         * @throws IOError Unit has not been loaded yet or DBus error
         */
        public async Unit get_unit (string name) throws DBusError, IOError {
            var path = yield manager.get_unit (name);
            return yield Unit.get_instance_for_path (path);
        }

        public async Unit get_unit_by_pid (uint32 pid) throws DBusError, IOError {
            var path = yield manager.get_unit_by_pid (pid);
            return yield Unit.get_instance_for_path (path);
        }

        public async Unit load_unit (string name) throws DBusError, IOError {
            var path = yield manager.load_unit (name);
            return yield Unit.get_instance_for_path (path);
        }

        public async Job start_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield manager.start_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job start_unit_replace (string old_unit, string new_unit, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield manager.start_unit_replace (old_unit, new_unit, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job stop_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield manager.stop_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job reload_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield manager.reload_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError{
            var path = yield manager.restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job try_restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError{
            var path = yield manager.try_restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job reload_or_restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError{
            var path = yield manager.reload_or_restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async Job reload_or_try_restart_unit (string name, UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError{
            var path = yield manager.reload_or_try_restart_unit (name, mode);
            return yield Job.get_instance_for_path (path);
        }

        public async void kill_unit (string name, Who who, int32 @signal = Posix.Signal.KILL) throws DBusError, IOError {
            yield manager.kill_unit (name, who, @signal);
        }

        public async Job get_job (uint32 id) throws DBusError, IOError {
            var path = yield manager.get_job (id);
            return yield Job.get_instance_for_path (path);
        }

        public async void clear_jobs () throws DBusError, IOError {
            yield manager.clear_jobs ();
        }

        public async void reset_failed_unit (string name) throws DBusError, IOError {
            yield manager.reset_failed_unit (name);
        }

        public async UnitInfo[] list_units () throws DBusError, IOError {
            var units = yield manager.list_units ();
            var result = new UnitInfo[units.length];
            var i = 0;
            foreach (var info in units) {
                result[i++] = yield UnitInfo.new_async (info);
            }
            return result;
        }

        public async JobInfo[] list_jobs () throws DBusError, IOError {
            var jobs = yield manager.list_jobs ();
            var result = new JobInfo[jobs.length];
            var i = 0;
            foreach (var job in jobs) {
                result[i++] = yield JobInfo.new_async (job);
            }
            return result;
        }

        public async void subscribe () throws DBusError, IOError {
            yield manager.subscribe ();
        }

        public async void unsubscribe () throws DBusError, IOError {
            yield manager.unsubscribe ();
        }

        public async Unit create_snapshot (string name, bool cleanup = true) throws DBusError, IOError {
            var path = yield manager.create_snapshot (name, cleanup);
            return yield Unit.get_instance_for_path (path);
        }

        public async void remove_snapshot (string name) throws DBusError, IOError {
            yield manager.remove_snapshot (name);
        }

        public async void reload () throws DBusError, IOError {
            yield manager.reload ();
        }
        public async void reexecute () throws DBusError, IOError {
            yield manager.reexecute ();
        }
        public async void exit () throws DBusError, IOError {
            yield manager.exit ();
        }

        public async void set_environment (string[] names) throws DBusError, IOError {
            yield manager.set_environment (names);
        }
        public async void unset_environment (string[] names) throws DBusError, IOError {
            yield manager.unset_environment (names);
        }

        public async void unset_and_set_environment (string[] unset, string[] @set) throws DBusError, IOError {
            yield manager.unset_and_set_environment (unset, @set);
        }

        public async UnitFileInfo[] list_unit_files () throws DBusError, IOError {
            var info = yield manager.list_unit_files ();
            var result = new UnitFileInfo[info.length];
            for (int i = 0; i < info.length; i++) {
                result[i].name = info[i].name;
                try {
                    result[i].state = UnitFileState.from_string (info[i].state);
                } catch (DBusError err) {
                    critical (err.message);
                }
            }
            return result;
        }

        public async UnitFileState get_unit_file_state (string file) throws DBusError, IOError {
            return yield manager.get_unit_file_state (file);
        }

        /**
         * Enables one or more units in the system (by creating symlinks to them
         * in /etc or /run).
         *
         * @param files List of unit files to enable (either just file names or
         * full absolute paths if the unit files are residing outside the usual
         * unit search paths).
         * @param runtime Whether the unit shall be enabled for runtime only
         * (true, /run), or persistently (false, /etc).
         * @param force Whether symlinks pointing to other units shall be
         * replaced if necessary.
         * @param carries_install_info Signals whether the unit files contained
         * any enablement information (i.e. an [Install]) section.
         * @return The changes list.
         */
        public async UnitLinkChangeInfo[] enable_unit_files (string[] files, bool runtime = false, bool force = false, out bool carries_install_info) throws DBusError, IOError {
            var info = yield manager.enable_unit_files (files, runtime, force, out carries_install_info);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] disable_unit_files (string[] files, bool runtime = false) throws DBusError, IOError {
            var info = yield manager.disable_unit_files (files, runtime);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] reenable_unit_files (string[] files, bool runtime = false, bool force = false, out bool carries_install_info) throws DBusError, IOError {
            var info =  yield manager.reenable_unit_files (files, runtime, force, out carries_install_info);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] link_unit_files (string[] files, bool runtime = false) throws DBusError, IOError {
            var info =  yield manager.link_unit_files (files, runtime);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] preset_unit_files (string[] files, bool runtime = false, bool force = false, out bool carries_install_info) throws DBusError, IOError {
            var info =  yield manager.preset_unit_files (files, runtime, force, out carries_install_info);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] mask_unit_files (string[] files, bool runtime = false) throws DBusError, IOError {
            var info =  yield manager.mask_unit_files (files, runtime);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] unmask_unit_files (string[] files, bool runtime = false) throws DBusError, IOError {
            var info =  yield manager.unmask_unit_files (files, runtime);
            return marshal_unit_link_change_info (info);
        }

        public async UnitLinkChangeInfo[] set_default_target (string[] files) throws DBusError, IOError {
            var info =  yield manager.set_default_target (files);
            return marshal_unit_link_change_info (info);
        }

        public async string get_default_target () throws DBusError, IOError {
            return yield manager.get_default_target ();
        }

//      public async void set_unit_properties (string name, bool runtime, UnitProperty[] properties) throws DBusError, IOError {
//          yield manager.set_unit_properties (name, runtime, properties);
//      }

//      public async Unit start_transiend_unit (string name, string mode, UnitProperty[] properties, UnitPropertyGroup[] aux) throws DBusError, IOError {
//          var path = yield manager.start_transiend_unit (name, mode, properties, aux);
//          return yield Unit.get_instance_from_path (path);
//      }

        public signal void unit_new (string id);
        async void on_unit_new (string id, ObjectPath path) {
            unit_new (id);
        }

        public signal void unit_removed (string id);
        async void on_unit_removed (string id, ObjectPath path) {
            unit_removed (id);
        }

        public signal void job_new (uint32 id, Job job, string unit);
        async void on_job_new (uint32 id, ObjectPath path, string unit) {
            try {
                var job = yield Job.get_instance_for_path (path);
                job_new (id, job, unit);
            } catch (IOError err) {
                critical (err.message);
            }
        }
        public signal void job_removed (uint32 id, string unit, JobResult result);
        async void on_job_removed (uint32 id, ObjectPath path, string unit, JobResult result) {
            job_removed (id, unit, result);
        }

        UnitLinkChangeInfo[] marshal_unit_link_change_info (org.freedesktop.systemd1.Manager.UnitLinkChangeInfo[] info) {
            var result = new UnitLinkChangeInfo[info.length];
            for (int i = 0; i < info.length; i++) {
                try {
                    result[i].change_type = UnitLinkChangeType.from_string (info[i].change_type);
                } catch (DBusError err) {
                    critical (err.message);
                }
                result[i].symlink_name = info[i].symlink_name;
                result[i].destination_name = info[i].destination_name;
                i++;
            }
            return result;
        }

        void on_properties_changed (string iface, HashTable<string,
            Variant?> changed_properties, string[] invalidated_properties)
        {
            //foreach (var property in invalidated_properties)
            // TODO: no properties in this class yet
        }
    }
/*
    [Compact]
    public class JobLink {
        org.freedesktop.systemd1.Unit.JobLink job_link;

        public uint32 id { get { return id; } }
        public Job job { get; private set; }

        public static async JobLink new_async (org.freedesktop.systemd1.Unit.JobLink job_link) throws DBusError, IOError {
            var instance = new JobLink ();
            instance.job_link = job_link;
            instance._job = yield Job.get_instance_for_path (job_link.path);
            return instance;
        }
    }
*/
    public class Unit : Object {
        static HashTable<ObjectPath, weak Unit> object_map;

        static construct {
            object_map = new HashTable<ObjectPath, weak Unit> (str_hash, str_equal);
        }

        ObjectPath path;
        org.freedesktop.systemd1.Unit unit;
        org.freedesktop.DBus.Properties properties;

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
        public UnitActiveState active_state { get { return unit.active_state; } }
        public string sub_state { owned get { return unit.sub_state; } }
        public string fragment_path { owned get { return unit.fragment_path; } }
        public UnitFileState unit_file_state { get { return unit.unit_file_state; } }
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
            if (object_map != null && object_map.contains (path)) {
                return object_map[path];
            }
            return yield new_async (path);
        }

        static async Unit new_async (ObjectPath path) throws IOError {
            var instance = new Unit ();
            instance.path = path;
            instance.unit = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            instance.properties = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            object_map[path] = instance;
            instance.properties.properties_changed.connect (instance.on_properties_changed);
            return instance;
        }

        ~Unit () {
            object_map.remove (path);
        }

        public async Job start (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.start (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job stop (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.stop (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.reload (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job restart (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.restart (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job try_restart (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.try_restart (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_or_restart (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.reload_or_restart (mode);
            return yield Job.get_instance_for_path (path);
        }
        public async Job reload_or_try_restart (UnitMode mode = UnitMode.REPLACE) throws DBusError, IOError {
            var path = yield unit.reload_or_try_restart (mode);
            return yield Job.get_instance_for_path (path);
        }

        public async void reset_failed () throws DBusError, IOError {
            yield unit.reset_failed ();
        }

        void on_properties_changed (string iface, HashTable<string,
            Variant?> changed_properties, string[] invalidated_properties)
        {
            changed_properties.foreach ((k, v) => {
                notify_dbus_property (k);
            });
            foreach (var property in invalidated_properties) {
                notify_dbus_property (property);
            }
        }

        void notify_dbus_property (string property) {
            switch (property) {
            case "Id":
                notify_property ("id");
                break;
            case "Names":
                notify_property ("names");
                break;
            case "Following":
                notify_property ("following");
                break;
            case "Requires":
                notify_property ("requires");
                break;
            case "RequiresOverridable":
                notify_property ("requires-overridable");
                break;
            case "Requisite":
                notify_property ("requisite");
                break;
            case "RequisiteOverridable":
                notify_property ("requisite-overridable");
                break;
            case "Wants":
                notify_property ("wants");
                break;
            case "BindsTo":
                notify_property ("binds-to");
                break;
            case "PartOf":
                notify_property ("part-of");
                break;
            case "RequiredBy":
                notify_property ("required-by");
                break;
            case "RequiredByOverridable":
                notify_property ("required-by-overridable");
                break;
            case "WantedBy":
                notify_property ("wanted-by");
                break;
            case "BoundBy":
                notify_property ("bound-by");
                break;
            case "ConsistsOf":
                notify_property ("consists-of");
                break;
            case "Conflicts":
                notify_property ("conflicts");
                break;
            case "ConflictedBy":
                notify_property ("conflicted-by");
                break;
            case "Before":
                notify_property ("before");
                break;
            case "After":
                notify_property ("after");
                break;
            case "OnFailure":
                notify_property ("on-failure");
                break;
            case "Triggers":
                notify_property ("triggers");
                break;
            case "TriggeredBy":
                notify_property ("triggered-by");
                break;
            case "PropagatesReloadTo":
                notify_property ("propagates-reload-to");
                break;
            case "ReloadPropagatedFrom":
                notify_property ("reload-propagated-from");
                break;
            case "RequiresMountsFor":
                notify_property ("requires-mounts-for");
                break;
            case "Description":
                notify_property ("description");
                break;
            case "SourcePath":
                notify_property ("source-path");
                break;
            case "DropInPaths":
                notify_property ("drop-in-paths");
                break;
            case "Documentation":
                notify_property ("documentation");
                break;
            case "LoadState":
                notify_property ("load-state");
                break;
            case "ActiveState":
                notify_property ("active-state");
                break;
            case "SubState":
                notify_property ("sub-state");
                break;
            case "FragmentPath":
                notify_property ("fragment-path");
                break;
            case "UnitFileState":
                notify_property ("unit-file-state");
                break;
            case "InactiveExitTimestamp":
                notify_property ("inactive-exit-timestamp");
                break;
            // case "InactiveExitTimestampMonotonic":
            //     notify_property ("inactive-exit-timestamp-monotonic");
            //     break;
            case "ActiveEnterTimestamp":
                notify_property ("active-enter-timestamp");
                break;
            // case "ActiveEnterTimestampMonotonic":
            //     notify_property ("active-enter-timestamp-monotonic");
            //     break;
            case "ActiveExitTimestamp":
                notify_property ("active-exit-timestamp");
                break;
            // case "ActiveExitTimestampMonotonic":
            //     notify_property ("active-exit-timestamp-monotonic");
            //     break;
            case "InactiveEnterTimestamp":
                notify_property ("inactive-enter-timestamp");
                break;
            // case "InactiveEnterTimestampMonotonic":
            //     notify_property ("inactive-enter-timestamp-monotonic");
            //     break;
            case "CanStart":
                notify_property ("can-start");
                break;
            case "CanStop":
                notify_property ("can-stop");
                break;
            case "CanReload":
                notify_property ("can-reload");
                break;
            case "CanIsolate":
                notify_property ("can-isolate");
                break;
            // case "Job":
            //     notify_property ("job");
            //     break;
            case "StopWhenUnneeded":
                notify_property ("stop-when-unneeded");
                break;
            case "RefuseManualStart":
                notify_property ("refuse-manual-start");
                break;
            case "RefuseManualStop":
                notify_property ("refuse-manual-stop");
                break;
            case "AllowIsolate":
                notify_property ("allow-isolate");
                break;
            case "DefaultDependencies":
                notify_property ("default-dependencies");
                break;
            case "OnFailureIsolate":
                notify_property ("on-failure-isolate");
                break;
            case "IgnoreOnIsolate":
                notify_property ("ignore-on-isolate");
                break;
            case "IgnoreOnSnapshot":
                notify_property ("ignore-on-snapshot");
                break;
            case "NeedDaemonReload":
                notify_property ("need-daemon-reload");
                break;
            case "JobTimeoutUSec":
                notify_property ("job-timeout-usec");
                break;
            // case "ConditionTimestamp":
            //     notify_property ("condition-timestamp");
            //     break;
            // case "ConditionTimestampMonotonic":
            //     notify_property ("condition-timestamp-monotonic");
            //     break;
            // case "ConditionResult":
            //     notify_property ("condition-result");
            //     break;
            // case "Conditions":
            //     notify_property ("conditions");
            //     break;
            // case "LoadError":
            //     notify_property ("load-error");
            //     break;
            // case "Transient":
            //     notify_property ("transient");
            //     break;
            }
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
        static HashTable<ObjectPath, weak Job> object_map;

        static construct {
            object_map = new HashTable<ObjectPath, weak Job> (str_hash, str_equal);
        }

        ObjectPath path;
        org.freedesktop.systemd1.Job job;
        org.freedesktop.DBus.Properties properties;

        public uint32 id { get { return job.id; } }
        public string state { owned get { return job.state; } }
        public string job_type { owned get { return job.job_type; } }
        //public UnitLink unit { owned get { return new UnitLink (job.unit); } }

        internal static async Job get_instance_for_path (ObjectPath path) throws IOError {
            if (object_map != null && object_map.contains (path)) {
                return object_map[path];
            }
            return yield new_async (path);
        }

        static async Job new_async (ObjectPath path) throws IOError {
            var instance = new Job ();
            instance.path = path;
            instance.job = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            instance.properties = yield Bus.get_proxy (BusType.SYSTEM,
                org.freedesktop.systemd1.SERVICE_NAME, path);
            object_map[path] = instance;
            instance.properties.properties_changed.connect (instance.on_properties_changed);
            return instance;
        }

        ~Job () {
            object_map.remove (path);
        }

        public async void cancel () throws DBusError, IOError {
            yield job.cancel ();
        }

        void on_properties_changed (string iface, HashTable<string,
            Variant?> changed_properties, string[] invalidated_properties)
        {
            changed_properties.foreach ((k, v) => {
                notify_dbus_property (k);
            });
            foreach (var property in invalidated_properties) {
                notify_dbus_property (property);
            }
        }

        void notify_dbus_property (string property) {
            switch (property) {
            case "Id":
                notify_property ("id");
                break;
            // case "Unit":
            //     notify_property ("unit");
            //     break;
            case "JobType":
                notify_property ("job-type");
                break;
            case "State":
                notify_property ("state");
                break;
            }
        }
    }
}