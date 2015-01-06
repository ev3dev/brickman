/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
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

/*
 * ControlPanel.vala:
 *
 * Control Panel for driving FakeEV3LCDDevice
 */

using EV3devKit;
using Gtk;

namespace BrickManager {
    public class ControlPanel : Object {
        const string CONTROL_PANEL_GLADE_FILE = "ControlPanel.glade";

        public Gtk.Window window;
        public FakeDeviceBrowserController device_browser_controller;
        public FakeNetworkController network_controller;
        public FakeBluetoothController bluetooth_controller;
        public FakeUSBController usb_controller;
        public FakeBatteryController battery_controller;
        public FakeAboutController about_controller;

        enum Tab {
            DEVICE_BROWSER,
            NETWORK,
            BLUETOOTH,
            USB,
            BATTERY
        }

        enum PortsColumn {
            PRESENT,
            DEVICE_NAME,
            PORT_NAME,
            DRIVER_NAME,
            MODE,
            MODES,
            STATUS,
            CAN_SET_DEVICE,
            USER_DATA,
            COLUMN_COUNT;
        }

        enum SensorsColumn {
            PRESENT,
            DEVICE_NAME,
            DRIVER_NAME,
            PORT_NAME,
            FW_VERSION,
            ADDRESS,
            POLL_MS,
            MODES,
            MODE,
            NUM_VALUES,
            DECIMALS,
            UNITS,
            COMMANDS,
            USER_DATA,
            COLUMN_COUNT;
        }

        enum NetworkTechnologyColumn {
            PRESENT,
            POWERED,
            CONNECTED,
            NAME,
            TYPE,
            USER_DATA,
            COLUMN_COUNT;
        }

        enum NetworkServiceColumn {
            PRESENT,
            STATE,
            ERROR,
            NAME,
            TYPE,
            SECURITY,
            STRENGTH,
            FAVORITE,
            IMMUTABLE,
            AUTO_CONNECT,
            ROAMING,
            NAMESERVERS,
            NAMESERVERS_CONFIG,
            TIMESERVERS,
            TIMESERVERS_CONFIG,
            DOMAINS,
            DOMAINS_CONFIG,
            USER_DATA,
            IPV4_DATA,
            ENET_DATA,
            COLUMN_COUNT;
        }

        enum BluetoothAdapterColumn {
            PRESENT,
            ADDRESS,
            NAME,
            ALIAS,
            CLASS,
            POWERED,
            DISCOVERABLE,
            PAIRABLE,
            PAIRABLE_TIMEOUT,
            DISCOVERABLE_TIMEOUT,
            UUIDS,
            DISCOVERING,
            MODALIAS,
            USER_DATA,
            COLUMN_COUNT;
        }

        enum BluetoothDeviceColumn {
            PRESENT,
            ADDRESS,
            NAME,
            ICON,
            CLASS,
            APPEARANCE,
            UUIDS,
            PAIRED,
            CONNECTED,
            TRUSTED,
            BLOCKED,
            ALIAS,
            ADAPTER,
            LEGACY_PAIRING,
            MODALIAS,
            RSSI,
            USER_DATA,
            COLUMN_COUNT;
        }

        public ControlPanel () {
            var builder = new Builder ();
            try {
                builder.add_from_file (CONTROL_PANEL_GLADE_FILE);
                window = builder.get_object ("control_panel_window") as Gtk.Window;

                device_browser_controller = new FakeDeviceBrowserController (builder);
                network_controller = new FakeNetworkController (builder);
                bluetooth_controller = new FakeBluetoothController (builder);
                usb_controller = new FakeUSBController (builder);
                battery_controller = new FakeBatteryController (builder);
                about_controller = new FakeAboutController (builder);

                builder.connect_signals (this);
                window.show_all ();
            } catch (Error err) {
                critical ("ControlPanel init failed: %s", err.message);
            }
        }

        [CCode (instance_pos = -1)]
        public void on_quit_button_clicked (Gtk.Button button) {
            EV3devKit.DesktopTestApp.quit ();
        }

        internal static void update_listview_toggle_item (ListStore store,
            CellRendererToggle toggle, string path, int column)
        {
            TreePath tree_path = new TreePath.from_string (path);
            TreeIter iter;
            store.get_iter (out iter, tree_path);
            store.set (iter, column, !toggle.active);
        }

        internal static void update_listview_text_item (ListStore store,
            string path, string new_text, int column)
        {
            TreePath tree_path = new TreePath.from_string (path);
            TreeIter iter;
            store.get_iter (out iter, tree_path);
            store.set (iter, column, new_text);
        }
    }
}
