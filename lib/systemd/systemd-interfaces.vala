/*
 * systemd -- vala bindings for systemd d-bus
 *
 * Copyright (C) 2014 David Lechner <david@lechnology.com>
 *
 * This file *was* part of systemd
 *
 * Copyright 2010 Lennart Poettering
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

namespace org.freedesktop.systemd1 {
    public const string SERVICE_NAME = "org.freedesktop.systemd1";

    [DBus (name = "org.freedesktop.systemd1.Manager")]
    public interface Manager : DBusProxy {
        public const string OBJECT_PATH = "/org/freedesktop/systemd1";

        public struct UnitInfo {
            string id;
            string description;
            string load_state;
            string active_state;
            string sub_state;
            string following;
            ObjectPath unit_path;
            uint32 job_id;
            string job_type;
            ObjectPath job_path;
        }

        public struct UnitFileInfo {
            string name;
            string state;
        }

        public struct UnitLinkChangeInfo {
            string change_type;
            string symlink_name;
            string destination_name;
        }

        public struct UnitProperty {
            string name;
            Variant value;
        }

        public struct UnitPropertyGroup {
            string name;
            UnitProperty[] properties;
        }

        public struct JobInfo {
            uint32 id;
            string name;
            string type;
            string state;
            ObjectPath job_path;
            ObjectPath unit_path;
        }

        public abstract string version { owned get; }
        public abstract string features { owned get; }
        public abstract string tainted { owned get; }
        public abstract uint64 firmware_timestamp { get; }
        public abstract uint64 firmware_timestamp_monotonic { get; }
        public abstract uint64 loader_timestamp { get; }
        public abstract uint64 loader_timestamp_monotonic { get; }
        public abstract uint64 kernel_timestamp { get; }
        public abstract uint64 kernel_timestamp_monotonic { get; }
        [DBus (name = "InitRDTimestamp")]
        public abstract uint64 init_rd_timestamp { get; }
        [DBus (name = "InitRDTimestampMonotonic")]
        public abstract uint64 init_rd_timestamp_monotonic { get; }
        public abstract uint64 userspace_timestamp { get; }
        public abstract uint64 userspace_timestamp_monotonic { get; }
        public abstract uint64 finish_timestamp { get; }
        public abstract uint64 finish_timestamp_monotonic { get; }
        public abstract uint64 generators_start_timestamp { get; }
        public abstract uint64 generators_start_timestamp_monotonic { get; }
        public abstract uint64 generators_finish_timestamp { get; }
        public abstract uint64 generators_finish_timestamp_monotonic { get; }
        public abstract uint64 units_load_start_timestamp { get; }
        public abstract uint64 units_load_start_timestamp_monotonic { get; }
        public abstract uint64 units_load_finish_timestamp { get; }
        public abstract uint64 units_load_finish_timestamp_monotonic { get; }
        public abstract uint64 security_start_timestamp { get; }
        public abstract uint64 security_start_timestamp_monotonic { get; }
        public abstract uint64 security_finish_timestamp { get; }
        public abstract uint64 security_finish_timestamp_monotonic { get; }
        public abstract string log_level { owned get; }
        public abstract string log_target { owned get; }
        [DBus (name = "NNames")]
        public abstract uint32 names_count { get; }
        [DBus (name = "NJobs")]
        public abstract uint32 jobs_count { get; }
        [DBus (name = "NInstalledJobs")]
        public abstract uint32 installed_jobs_count { get; }
        [DBus (name = "NFailedJobs")]
        public abstract uint32 failed_jobs_count { get; }
        public abstract double progress { get; }
        public abstract string[] environment { owned get; }
        public abstract bool confirm_spawn { get; }
        public abstract bool show_status { get; }
        public abstract string[] unit_path { owned get; }
        public abstract string default_standard_output { owned get; }
        public abstract string default_standard_error { owned get; }
        [DBus (name = "RuntimeWatchdogUSec")]
        public abstract uint64 runtime_watchdog_usec { get; }
        [DBus (name = "ShutdownWatchdogUSec")]
        public abstract uint64 shutdown_watchdog_usec { get; }
        public abstract string virtualization { owned get; }
        public abstract string architecture { owned get; }

        public abstract async ObjectPath get_unit (string name) throws IOError;
        public abstract async ObjectPath get_unit_by_pid (uint32 pid) throws IOError;
        public abstract async ObjectPath load_unit (string name) throws IOError;
        public abstract async ObjectPath start_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath start_unit_replace (string old_unit, string new_unit, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath stop_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath try_restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_or_restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_or_try_restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async void kill_unit (string name, Systemd.Who who, int32 @signal) throws IOError;
        public abstract async void reset_failed_unit (string name) throws IOError;
        public abstract async ObjectPath get_job (uint32 id) throws IOError;
        public abstract async void cancel_job (uint32 id) throws IOError;
        public abstract async void clear_jobs () throws IOError;
        public abstract async void reset_failed () throws IOError;
        public abstract async UnitInfo[] list_units () throws IOError;
        public abstract async JobInfo[] list_jobs () throws IOError;
        public abstract async void subscribe () throws IOError;
        public abstract async void unsubscribe () throws IOError;
        public abstract async ObjectPath create_snapshot (string name, bool cleanup) throws IOError;
        public abstract async void remove_snapshot (string name) throws IOError;
        public abstract async void reload () throws IOError;
        public abstract async void reexecute () throws IOError;
        public abstract async void exit () throws IOError;
        public abstract async void reboot () throws IOError;
        public abstract async void power_off () throws IOError;
        public abstract async void halt () throws IOError;
        [DBus  (name = "KExec")]
        public abstract async void kexec () throws IOError;
        public abstract async void switch_root (string new_root, string init) throws IOError;
        public abstract async void set_environment (string[] names) throws IOError;
        public abstract async void unset_environment (string[] names) throws IOError;
        public abstract async void unset_and_set_environment (string[] unset, string[] @set) throws IOError;
        public abstract async UnitFileInfo[] list_unit_files () throws IOError;
        public abstract async Systemd.UnitFileState get_unit_file_state (string file) throws IOError;
        public abstract async UnitLinkChangeInfo[] enable_unit_files (string[] files, bool runtime, bool force, out bool carries_install_info) throws IOError;
        public abstract async UnitLinkChangeInfo[] disable_unit_files (string[] files, bool runtime) throws IOError;
        public abstract async UnitLinkChangeInfo[] reenable_unit_files (string[] files, bool runtime, bool force, out bool carries_install_info) throws IOError;
        public abstract async UnitLinkChangeInfo[] link_unit_files (string[] files, bool runtime) throws IOError;
        public abstract async UnitLinkChangeInfo[] preset_unit_files (string[] files, bool runtime, bool force, out bool carries_install_info) throws IOError;
        public abstract async UnitLinkChangeInfo[] mask_unit_files (string[] files, bool runtime) throws IOError;
        public abstract async UnitLinkChangeInfo[] unmask_unit_files (string[] files, bool runtime) throws IOError;
        public abstract async UnitLinkChangeInfo[] set_default_target (string[] files) throws IOError;
        public abstract async string get_default_target () throws IOError;
        public abstract async void set_unit_properties (string name, bool runtime, UnitProperty[] properties) throws IOError;
        public abstract async ObjectPath start_transiend_unit (string name, string mode, UnitProperty[] properties, UnitPropertyGroup[] aux) throws IOError;

        public abstract signal void unit_new (string id, ObjectPath path);
        public abstract signal void unit_removed (string id, ObjectPath path);
        public abstract signal void job_new (uint32 id, ObjectPath path, string unit);
        public abstract signal void job_removed (uint32 id, ObjectPath path, string unit, Systemd.JobResult res);
        public abstract signal void startup_finished (uint64 firmware, uint64 loader, uint64 kernel, uint64 initrd, uint64 userspace, uint64 total);
        public abstract signal void unit_files_changed ();
        public abstract signal void reloading (bool active);
    }

    [DBus (name = "org.freedesktop.systemd1.Unit")]
    public interface Unit : DBusProxy {
        public struct JobLink {
            uint32 id;
            ObjectPath path;
        }

        public abstract string id { owned get; }
        public abstract string[] names { owned get; }
        public abstract string following { owned get; }
        public abstract string[] requires { owned get; }
        public abstract string[] requires_overridable { owned get; }
        public abstract string[] requisite { owned get; }
        public abstract string[] requisite_overridable { owned get; }
        public abstract string[] wants { owned get; }
        public abstract string[] required_by { owned get; }
        public abstract string[] required_by_overridable { owned get; }
        public abstract string[] wanted_by { owned get; }
        public abstract string[] conflicts { owned get; }
        public abstract string[] conflicted_by { owned get; }
        public abstract string[] before { owned get; }
        public abstract string[] after { owned get; }
        public abstract string[] on_failure { owned get; }
        public abstract string description { owned get; }
        public abstract string load_state { owned get; }
        public abstract Systemd.UnitActiveState active_state { owned get; }
        public abstract string sub_state { owned get; }
        public abstract string fragment_path { owned get; }
        public abstract Systemd.UnitFileState unit_file_state { get; }
        public abstract uint64 inactive_exit_timestamp { owned get; }
        public abstract uint64 active_enter_timestamp { owned get; }
        public abstract uint64 active_exit_timestamp { owned get; }
        public abstract uint64 inactive_enter_timestamp { owned get; }
        public abstract bool can_start { get; }
        public abstract bool can_stop { get; }
        public abstract bool can_reload { get; }
        public abstract JobLink job { owned get; }
        public abstract bool recursive_stop { get; }
        public abstract bool stop_when_unneeded { get; }
        public abstract bool refuse_manual_start { get; }
        public abstract bool refuse_manual_stop { get; }
        public abstract bool default_dependencies { get; }
        public abstract string default_control_group { owned get; }
        public abstract string[] control_groups { owned get; }
        public abstract bool need_daemon_reload { get; }
        public abstract uint64 job_timeout_usec { get; }

        public abstract async ObjectPath start (Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath stop (Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload (Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath restart (Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath try_restart (Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_or_restart (Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_or_try_restart (Systemd.UnitMode mode) throws IOError;

        public abstract async void reset_failed () throws IOError;
    }

    [DBus (name = "org.freedesktop.systemd1.Job")]
    public interface Job : DBusProxy {
        public struct UnitLink {
            string id;
            ObjectPath path;
        }

        public abstract uint32 id { get; }
        public abstract string state { owned get; }
        public abstract string job_type { owned get; }
        public abstract UnitLink unit { owned get; }

        public abstract async void cancel () throws IOError;
    }
}

namespace org.freedesktop.DBus {
    [DBus (name = "org.freedesktop.DBus.Properties")]
    public interface Properties : DBusProxy {
        public abstract async Variant? get (string iface, string property) throws IOError;
        public abstract async void set (string iface, string property, Variant? value) throws IOError;
        public abstract signal void properties_changed (string iface, HashTable<string, Variant> changed_properties, string[] invalidated_properties);
    }
}
