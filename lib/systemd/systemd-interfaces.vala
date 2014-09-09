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
    public interface Manager : org.freedesktop.Properties, DBusProxy {
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

        public struct JobInfo {
            uint32 id;
            string name;
            string type;
            string state;
            ObjectPath job_path;
            ObjectPath unit_path;
        }

        public abstract string[] environment { owned get; }

        public abstract async UnitInfo[] list_units () throws IOError;
        public abstract async JobInfo[] list_jobs () throws IOError;

        public abstract async ObjectPath get_unit (string name) throws IOError;
        public abstract async ObjectPath get_unit_by_pid (uint32 pid) throws IOError;
        public abstract async ObjectPath load_unit (string name) throws IOError;
        public abstract async ObjectPath get_job (uint32 id) throws IOError;

        public abstract async ObjectPath start_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath start_unit_replace (string old_unit, string new_unit, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath stop_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath try_restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_or_restart_unit (string name, Systemd.UnitMode mode) throws IOError;
        public abstract async ObjectPath reload_or_try_restart_unit (string name, Systemd.UnitMode mode) throws IOError;

        public abstract async void reset_failed_unit (string name) throws IOError;

        public abstract async void clear_jobs () throws IOError;

        public abstract async void subscribe () throws IOError;
        public abstract async void unsubscribe () throws IOError;

        public abstract async void reload () throws IOError;
        public abstract async void reexecute () throws IOError;
        public abstract async void exit () throws IOError;
        public abstract async void halt () throws IOError;
        public abstract async void power_off () throws IOError;
        public abstract async void reboot () throws IOError;
        public abstract async void kexec () throws IOError;

        public abstract async ObjectPath create_snapshot (string name, bool cleanup) throws IOError;

        public abstract async void set_environment (string[] names) throws IOError;
        public abstract async void unset_environment (string[] names) throws IOError;

        public abstract signal void unit_new (string id, ObjectPath path);
        public abstract signal void unit_removed (string id, ObjectPath path);
        public abstract signal void job_new (uint32 id, ObjectPath path);
        public abstract signal void job_removed (uint32 id, ObjectPath path, Systemd.JobResult res);
    }

    [DBus (name = "org.freedesktop.systemd1.Unit")]
    public interface Unit : org.freedesktop.Properties, DBusProxy {
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
        public abstract string active_state { owned get; }
        public abstract string sub_state { owned get; }
        public abstract string fragment_path { owned get; }
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
    public interface Job : org.freedesktop.Properties, DBusProxy {
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

namespace org.freedesktop {
    [DBus (name = "org.freedesktop.Properties")]
    public interface Properties : DBusProxy {
        public abstract async Variant? get (string iface, string property) throws IOError;
        public abstract signal void properties_changed (string iface, HashTable<string, Variant?> changed_properties, string[] invalidated_properties);
    }
}
