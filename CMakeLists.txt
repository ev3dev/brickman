project ("brickman" C)

if (CMAKE_CROSSCOMPILING)
    # we are depending on CMAKE_SYSROOT feature introduce in CMake 3.x
    # and we only support cross compiling using Ubuntu 16.04
    cmake_minimum_required (VERSION 3.5)
else (CMAKE_CROSSCOMPILING)
    cmake_minimum_required (VERSION 2.6)
endif (CMAKE_CROSSCOMPILING)

option (BRICKMAN_TEST "Build the desktop test version.")

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (EXEC_NAME "brickman")
set (RELEASE_NAME "Brick Manager")
set (VERSION "0.7.2")

# Comment this out to enable C compiler warnings
add_definitions (-w)

add_subdirectory (data)
set (XDG_DATA_DIR data)

configure_file (src/Version.vala.in Version.vala)

if (BRICKMAN_TEST)
    set (BRICKMAN_TEST_PACKAGES gtk+-3.0 ev3devkit-desktop-0.3)
    set (BRICKMAN_SOURCE_FILES
        test/main.vala
        test/ControlPanel.vala
        test/FakeBluez5.vala
        test/FakeConnman.vala
        test/controller/FakeAboutController.vala
        test/controller/FakeBatteryController.vala
        test/controller/FakeBluetoothController.vala
        test/controller/FakeDeviceBrowserController.vala
        test/controller/FakeFileBrowserController.vala
        test/controller/FakeNetworkController.vala
        test/controller/FakeOpenRobertaController.vala
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
        src/controller/OpenRobertaController.vala
        src/GlobalManager.vala
        src/main.vala
    )
endif (BRICKMAN_TEST)

set (BRICKMAN_COMMON_SOURCE_FILES
    lib/bluez5/Error.vala
    lib/bluez5/Uuid.vala
    lib/dbus/Properties.vala
    lib/systemd/Logind.vala
    lib/systemd/Systemd.vala
    lib/systemd/logind-interfaces.vala
    lib/systemd/systemd-interfaces.vala
    src/controller/IBrickManagerModule.vala
    src/dbus/Bluez5Agent.vala
    src/dbus/ConnmanAgent.vala
    src/view/AboutWindow.vala
    src/view/BatteryInfoWindow.vala
    src/view/BatteryStatusBarItem.vala
    src/view/BluetoothDeviceMenuItem.vala
    src/view/BluetoothDeviceWindow.vala
    src/view/BluetoothStatusBarItem.vala
    src/view/BluetoothWindow.vala
    src/view/BrickManagerWindow.vala
    src/view/ConnmanAgentInputDialog.vala
    src/view/DeviceBrowserWindow.vala
    src/view/FileBrowserWindow.vala
    src/view/HomeWindow.vala
    src/view/MotorBrowserWindow.vala
    src/view/MotorInfoWindow.vala
    src/view/MotorValueDialog.vala
    src/view/NetworkConnectionDnsWindow.vala
    src/view/NetworkConnectionEnetWindow.vala
    src/view/NetworkConnectionIpv4Window.vala
    src/view/NetworkConnectionMenuItem.vala
    src/view/NetworkConnectionWindow.vala
    src/view/NetworkConnectionsWindow.vala
    src/view/NetworkStatusBarItem.vala
    src/view/NetworkStatusWindow.vala
    src/view/OpenRobertaStatusBarItem.vala
    src/view/OpenRobertaWindow.vala
    src/view/PortBrowserWindow.vala
    src/view/PortInfoWindow.vala
    src/view/SelectFromListDialog.vala
    src/view/SensorBrowserWindow.vala
    src/view/SensorInfoWindow.vala
    src/view/SensorValueDialog.vala
    src/view/ShutdownDialog.vala
    src/view/SignalBars.vala
    src/view/TetheringInfoWindow.vala
    src/view/TetheringWindow.vala
    src/view/WifiMenuItem.vala
    src/view/WifiNetworkStatusWindow.vala
    src/view/WifiNetworkWindow.vala
    src/view/WifiStatusBarItem.vala
    src/view/WifiWindow.vala
)

find_package(PkgConfig REQUIRED)
pkg_check_modules(DEPS REQUIRED
    ev3devkit-0.3
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    grx20
    gudev-1.0
    ncurses
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES})
link_directories(${DEPS_LIBRARY_DIRS})

if (BRICKMAN_TEST)
    pkg_check_modules(BRICKMAN_TEST_DEPS ev3devkit-desktop-0.3 gtk+-3.0)
    add_definitions(${BRICKMAN_TEST_DEPS_CFLAGS})
    link_libraries(${BRICKMAN_TEST_DEPS_LIBRARIES})
    link_directories(${BRICKMAN_TEST_DEPS_LIBRARY_DIRS})
endif (BRICKMAN_TEST)

link_libraries(m)

if (CMAKE_CROSSCOMPILING)
    # These need to be added manually for some reason. It is important that they
    # come after other calls to link_libraries or you will get linker errors.
    link_libraries(pcre resolv pthread)
endif(CMAKE_CROSSCOMPILING)

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
    ev3devkit-0.3
    glib-2.0
    gobject-2.0
    gmodule-2.0
    gio-2.0
    gio-unix-2.0
    grx20
    gudev-1.0
    curses
    posix
    linux
    ${BRICKMAN_TEST_PACKAGES}
CUSTOM_VAPIS
    bindings/*.vapi
OPTIONS
    --target-glib=2.40
    --thread
)

add_executable(${EXEC_NAME} ${VALA_C})

if (BRICKMAN_TEST)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/test/glade/ControlPanel.glade
    ${CMAKE_CURRENT_BINARY_DIR}/ControlPanel.glade COPYONLY )
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/test/glade/ConnmanServiceIPv4Dialog.glade
    ${CMAKE_CURRENT_BINARY_DIR}/ConnmanServiceIPv4Dialog.glade COPYONLY )
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/test/glade/ConnmanAgentRequestInputDialog.glade
    ${CMAKE_CURRENT_BINARY_DIR}/ConnmanAgentRequestInputDialog.glade COPYONLY )
endif (BRICKMAN_TEST)

add_dependencies(${EXEC_NAME} brickman_data)
install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION sbin)

add_custom_target(run
    COMMAND
        XDG_DATA_DIRS=${XDG_DATA_DIR}:/usr/local/share:/usr/share
        ./${EXEC_NAME}
    DEPENDS ${EXEC_NAME}
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)
