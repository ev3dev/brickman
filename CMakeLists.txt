project ("brickman")

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/${CMAKE_PROJECT_NAME}")
set (EXEC_NAME "brickman")
set (RELEASE_NAME "Brick Manager")
set (VERSION "0.4.0")

# Comment this out to enable C compiler warnings
add_definitions (-w)

add_subdirectory (data)

# Currently, ev3devKit is a submodule and we are staticly linking it
set (EV3DEVKIT_LIBRARIES ev3devKit)
set (EV3DEVKIT_VAPI ${ev3devKit_BINARY_DIR}/ev3devKit.vapi)
if (BRICKMAN_TEST)
    set (EV3DEVKIT_DESKTOP 1)
    list (APPEND EV3DEVKIT_LIBRARIES ev3devKit-desktop)
    list (APPEND EV3DEVKIT_VAPI ${ev3devKit_BINARY_DIR}/ev3devKit-desktop.vapi)
endif (BRICKMAN_TEST)
set (EV3DEVKIT_NO_DEMO 1)
add_subdirectory (lib/ev3devKit)
include_directories (${ev3devKit_BINARY_DIR})
link_libraries (${EV3DEVKIT_LIBRARIES})

configure_file (src/Version.vala.in Version.vala)

if (BRICKMAN_TEST)
    set (BRICKMAN_TEST_MODULES gtk+-3.0)
    set (BRICKMAN_TEST_PACKAGES gtk+-3.0)
    set (BRICKMAN_SOURCE_FILES
        test/main.vala
        test/ControlPanel.vala
        test/FakeBlueZ5.vala
        test/FakeConnMan.vala
        test/controller/FakeAboutController.vala
        test/controller/FakeBatteryController.vala
        test/controller/FakeBluetoothController.vala
        test/controller/FakeDeviceBrowserController.vala
        test/controller/FakeFileBrowserController.vala
        test/controller/FakeNetworkController.vala
        test/controller/FakeUSBController.vala
    )
else (BRICKMAN_TEST)
    set (BRICKMAN_SOURCE_FILES
        lib/bluez5/Adapter.vala
        lib/bluez5/AgentManager.vala
        lib/bluez5/Device.vala
        lib/bluez5/Manager.vala
        lib/connman/Manager.vala
        lib/connman/Peer.vala
        lib/connman/Service.vala
        lib/connman/Technology.vala
        src/controller/AboutController.vala
        src/controller/BatteryController.vala
        src/controller/BluetoothController.vala
        src/controller/DeviceBrowserController.vala
        src/controller/FileBrowserController.vala
        src/controller/NetworkController.vala
        src/controller/USBController.vala
        src/GlobalManager.vala
        src/main.vala
    )
endif (BRICKMAN_TEST)

set (BRICKMAN_COMMON_SOURCE_FILES
    lib/bluez5/Error.vala
    lib/bluez5/UUID.vala
    lib/dbus/Properties.vala
    lib/systemd/Logind.vala
    lib/systemd/Systemd.vala
    lib/systemd/logind-interfaces.vala
    lib/systemd/systemd-interfaces.vala
    src/controller/IBrickManagerModule.vala
    src/dbus/BlueZ5Agent.vala
    src/dbus/ConnManAgent.vala
    src/view/AboutWindow.vala
    src/view/BatteryInfoWindow.vala
    src/view/BatteryStatusBarItem.vala
    src/view/BluetoothDeviceMenuItem.vala
    src/view/BluetoothDeviceWindow.vala
    src/view/BluetoothWindow.vala
    src/view/BrickManagerWindow.vala
    src/view/ConnManAgentInputDialog.vala
    src/view/DeviceBrowserWindow.vala
    src/view/FileBrowserWindow.vala
    src/view/HomeWindow.vala
    src/view/NetworkConnectionMenuItem.vala
    src/view/NetworkConnectionsWindow.vala
    src/view/NetworkPropertiesWindow.vala
    src/view/NetworkStatusBarItem.vala
    src/view/NetworkStatusWindow.vala
    src/view/PortBrowserWindow.vala
    src/view/PortInfoWindow.vala
    src/view/SelectFromListDialog.vala
    src/view/SensorBrowserWindow.vala
    src/view/SensorInfoWindow.vala
    src/view/SensorValueDialog.vala
    src/view/ShutdownDialog.vala
    src/view/TetheringInfoWindow.vala
    src/view/TetheringWindow.vala
    src/view/USBWindow.vala
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(DEPS REQUIRED
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    gudev-1.0
    ncurses
    ${BRICKMAN_TEST_MODULES}
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} grx20 m)
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.24" MINIMUM)
include(ValaPrecompile)

# if the binary directory is a subdirectory of the source directory, it causes
# the build to fail when including generated .vala files that are in the binary
# directory. The solution is to use the relative path.
string(REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/" "" BRICKMAN_RELATIVE_BINARY_DIR
    ${CMAKE_CURRENT_BINARY_DIR})

vala_precompile(VALA_C ${EXEC_NAME}
    ${BRICKMAN_RELATIVE_BINARY_DIR}/Version.vala
    ${BRICKMAN_SOURCE_FILES}
    ${BRICKMAN_COMMON_SOURCE_FILES}
PACKAGES
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    gee-0.8
    gudev-1.0
    curses
    posix
    linux
    ${BRICKMAN_TEST_PACKAGES}
CUSTOM_VAPIS
    lib/ev3devKit/bindings/*.vapi
    ${EV3DEVKIT_VAPI}
    bindings/*.vapi
OPTIONS
    --target-glib=2.40
    --thread
)

add_executable(${EXEC_NAME} ${VALA_C})

if (BRICKMAN_TEST)
configure_file(
    ${ev3devKit_SOURCE_DIR}/src/desktop/main_window.glade
    ${CMAKE_CURRENT_BINARY_DIR}/main_window.glade COPYONLY )
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/test/glade/ControlPanel.glade
    ${CMAKE_CURRENT_BINARY_DIR}/ControlPanel.glade COPYONLY )
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/test/glade/ConnManServiceIPv4Dialog.glade
    ${CMAKE_CURRENT_BINARY_DIR}/ConnManServiceIPv4Dialog.glade COPYONLY )
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/test/glade/ConnManAgentRequestInputDialog.glade
    ${CMAKE_CURRENT_BINARY_DIR}/ConnManAgentRequestInputDialog.glade COPYONLY )
endif (BRICKMAN_TEST)

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION sbin)

add_custom_target(run
    COMMAND ${EXEC_NAME}
    DEPENDS ${EXEC_NAME}
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)
