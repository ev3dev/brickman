/*
 * brickman -- Brick Manager for LEGO MINDSTORMS EV3/ev3dev
 *
 * Copyright 2014-2015 David Lechner <david@lechnology.com>
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

/* ConnmanAgent.vala - ConnMan Agent implementation */

using Ev3devKit.Ui;
using Connman;

namespace BrickManager {
    [DBus (name = "net.connman.Agent")]
    public class ConnmanAgent : Object {
        const string NAME_KEY                   = "Name";
        const string SSID_KEY                   = "SSID";
        const string IDENTITY_KEY               = "Identity";
        const string PASSPHRASE_KEY             = "Passphrase";
        const string PREVIOUS_PASSPHRASE_KEY    = "PreviousPassphrase";
        const string WPS_KEY                    = "WPS";
        const string USERNAME_KEY               = "Username";
        const string PASSWORD_KEY               = "Password";
        const string TYPE_KEY                   = "Type";
        const string REQUIREMENT_KEY            = "Requirement";
        const string ALTERNATES_KEY             = "Alternates";
        const string VALUE_KEY                  = "Value";

        [DBus (visible = false)]
        public Manager? manager { get; set; }

        signal void canceled ();

        public ConnmanAgent () {
        }

        public async void release () throws DBusError, IOError {
            //debug ("Released.");
        }

        public async void report_error (ObjectPath service_path, string err) throws DBusError, IOError, ConnmanAgentError {
            var dialog = new MessageDialog ("Error", err);
            dialog.show ();
            // TODO: get user feedback for retry
            //throw new ConnmanAgentError.RETRY ("User requested retry.");
        }

        public async void report_peer_error (ObjectPath peer_path, string err) throws DBusError, IOError, ConnmanAgentError {
            var dialog = new MessageDialog ("Error", err);
            dialog.show ();
            // TODO: get user feedback for retry
            //throw new ConnmanAgentError.RETRY ("User requested retry.");
        }

        public async void request_browser (ObjectPath service_path, string url) throws DBusError, IOError, ConnmanAgentError {
            throw new ConnmanAgentError.CANCELED ("Web browser not implemented.");
        }

        public async HashTable<string, Variant> request_input (ObjectPath service_path, HashTable<string, Variant> fields) throws DBusError, IOError, ConnmanAgentError {
            var service = manager.get_service (service_path);
            var required_field_names = new SList<string> ();
            string? previous_passphrase = null;
            fields.foreach ((k, v) => {
                //debug ("%s %s", k, v.print (true));
                var requirement = v.lookup_value (REQUIREMENT_KEY, VariantType.STRING);
                if (requirement != null && requirement.get_string () == "mandatory") {
                    required_field_names.prepend (k);
                }
                if (k == PREVIOUS_PASSPHRASE_KEY) {
                    var previous_passphrase_value = v.lookup_value (VALUE_KEY, VariantType.STRING);
                    if (previous_passphrase_value != null) {
                        previous_passphrase = previous_passphrase_value.dup_string ();
                    }
                }
            });
            var result = new HashTable<string, Variant> (null, null);
            required_field_names.reverse ();
            foreach (var required_field_name in required_field_names) {
                var dialog = new ConnmanAgentInputDialog (
                    "Please enter %s for %s.".printf (field_to_string (required_field_name),
                        service.name),
                    previous_passphrase ?? "");
                bool dialog_canceled = true;
                weak ConnmanAgentInputDialog weak_dialog = dialog;
                dialog.responded.connect ((accepted) => {
                    dialog_canceled = !accepted;
                    result[required_field_name] = weak_dialog.text_value;
                    request_input.callback ();
                });
                var handler_id = canceled.connect (() => {
                    dialog.responded (false);
                    dialog.close ();
                    var message_dialog = new MessageDialog ("Info", "Request was canceled.");
                    message_dialog.show ();
                });
                dialog.show ();
                yield;
                SignalHandler.disconnect (this, handler_id);
                if (dialog_canceled) {
                    throw new ConnmanAgentError.CANCELED ("Canceled by the user.");
                }
            }
            return result;
        }

        public async HashTable<string, Variant> request_peer_authorization (ObjectPath peer_path, HashTable<string, Variant> fields) throws DBusError, IOError, ConnmanAgentError {
            //var peer = Peer.from_path_sync (peer_path);
            throw new ConnmanAgentError.CANCELED ("Not implemented.");
        }

        public async void cancel () throws DBusError, IOError {
            canceled ();
        }

        string field_to_string (string field) {
            switch (field) {
                case NAME_KEY:
                case SSID_KEY:
                    return "SSID";
                case IDENTITY_KEY:
                case USERNAME_KEY:
                    return "username";
                case PASSPHRASE_KEY:
                    return "passphrase";
                case WPS_KEY:
                    return "WPS PIN";
                case PASSWORD_KEY:
                    return "password";
                default:
                    critical ("Unexpected field '%s'", field);
                    return "???";
            }
        }
    }

    [DBus (name = "net.connman.Agent.Error")]
    public errordomain ConnmanAgentError {
        CANCELED,
        LAUNCH_BROWSER,
        REJECTED,
        RETRY
    }
}