/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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

/*
 * Networking.vala:
 *
 * Monitors network status and performs other network related functions
 */

using ConnMan;
using M2tk;

namespace BrickManager {
    class Networking : GLib.Object {
        Manager manager;

        public NetworkStatusScreen network_status_screen { get; private set; }

        public Networking() {
            network_status_screen = new NetworkStatusScreen();
            init.begin((obj, res) => {
                try {
                    init.end(res);
                    manager.bind_property("state",
                        network_status_screen,
                        "state", BindingFlags.SYNC_CREATE,
                        convert_manager_state_to_string);
                    manager.bind_property("offline-mode",
                        network_status_screen,
                        "airplane-mode",
                        BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
                    network_status_screen.loading = false;
                } catch (Error err) {
                    warning("%s", err.message);
                    // TODO set network_status_screen to show error
                }
            });
        }

        async void init () throws Error {
            manager = yield Manager.new_async();
            foreach(var prop in manager.get_class().list_properties()) {
                Value val = Value(prop.value_type);
                manager.get_property(prop.name, ref val);
                //debug ("%s - %s", prop.name, val.strdup_contents());
            }
            manager.technology_added.connect ((sender, tech) =>
                add_technology (tech));
            manager.technology_removed.connect ((sender, tech) =>
                remove_technology (tech));
            var technologies = yield manager.get_technologies ();
            foreach(var item in technologies)
                add_technology (item);
            var services = yield manager.get_services();
            foreach(var item in services) {
                foreach(var prop in item.get_class().list_properties()) {
                    Value val = Value(prop.value_type);
                    item.get_property(prop.name, ref val);
                    //debug ("%s - %s", prop.name, val.strdup_contents());
                }
            }
        }

        void add_technology (Technology tech) {
            var view = new NetworkTechnologyItem (tech.name);
            tech.bind_property("powered", view, "powered",
                BindingFlags.SYNC_CREATE | BindingFlags.BIDIRECTIONAL);
            network_status_screen.add_technology (view, tech);
            foreach(var prop in tech.get_class ().list_properties ()) {
                Value val = Value(prop.value_type);
                tech.get_property(prop.name, ref val);
                //debug ("%s - %s", prop.name, val.strdup_contents());
            }
        }

        void remove_technology (Technology tech) {
            network_status_screen.remove_technology (tech);
        }

        static bool convert_manager_state_to_string(Binding binding,
            Value source_value, ref Value target_value)
        {
            switch((ManagerState)source_value) {
            case ManagerState.OFFLINE:
                target_value = "Offline";
                break;
            case ManagerState.IDLE:
                target_value = "Idle";
                break;
            case ManagerState.READY:
                target_value = "Ready";
                break;
            case ManagerState.ONLINE:
                target_value = "Online";
                break;
            default:
                target_value = "Unknown";
                break;
            }
            return true;
        }
    }
}
