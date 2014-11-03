project (brickman)

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/brickman")
set (EXEC_NAME "brickman")
set (RELEASE_NAME "Brick Manager")
set (VERSION "0.1.3")

configure_file (src/Version.vala.in Version.vala)

if (BRICKMAN_TEST)
    set (BRICKMAN_TEST_MODULES gtk+-3.0)
    set (BRICKMAN_TEST_PACKAGES gtk+-3.0)
    set (BRICKMAN_SOURCE_FILES
        test/main.vala
        test/ControlPanel.vala
        test/FakeConnMan.vala
        test/controller/FakeAboutController.vala
        test/controller/FakeBatteryController.vala
        test/controller/FakeNetworkController.vala
        test/controller/FakeUSBController.vala
        lib/ev3devKit/src/desktop/FakeEV3LCDDevice.vala
        lib/ev3devKit/src/desktop/DesktopScreen.vala
        lib/ev3devKit/src/desktop/DesktopTestApp.vala
    )
else (BRICKMAN_TEST)
    set (BRICKMAN_SOURCE_FILES
        lib/connman/Manager.vala
        lib/connman/Peer.vala
        lib/connman/Service.vala
        lib/connman/Technology.vala
        lib/ev3devKit/src/ConsoleApp.vala
        src/controller/AboutController.vala
        src/controller/BatteryController.vala
        src/controller/NetworkController.vala
        src/controller/USBController.vala
        src/main.vala
    )
endif (BRICKMAN_TEST)

set (BRICKMAN_COMMON_SOURCE_FILES
    lib/ev3devKit/src/Align.vala
    lib/ev3devKit/src/Box.vala
    lib/ev3devKit/src/Button.vala
    lib/ev3devKit/src/CheckboxMenuItem.vala
    lib/ev3devKit/src/CheckButton.vala
    lib/ev3devKit/src/Container.vala
    lib/ev3devKit/src/Dialog.vala
    lib/ev3devKit/src/Grid.vala
    lib/ev3devKit/src/Label.vala
    lib/ev3devKit/src/Menu.vala
    lib/ev3devKit/src/MenuItem.vala
    lib/ev3devKit/src/MessageDialog.vala
    lib/ev3devKit/src/Notebook.vala
    lib/ev3devKit/src/NotebookTab.vala
    lib/ev3devKit/src/OnScreenKeyboard.vala
    lib/ev3devKit/src/RadioMenuItem.vala
    lib/ev3devKit/src/Rectangle.vala
    lib/ev3devKit/src/Screen.vala
    lib/ev3devKit/src/Scroll.vala
    lib/ev3devKit/src/Spacer.vala
    lib/ev3devKit/src/StatusBar.vala
    lib/ev3devKit/src/StatusBarItem.vala
    lib/ev3devKit/src/TabButton.vala
    lib/ev3devKit/src/TextEntry.vala
    lib/ev3devKit/src/Widget.vala
    lib/ev3devKit/src/Window.vala
    lib/systemd/Logind.vala
    lib/systemd/Systemd.vala
    lib/systemd/logind-interfaces.vala
    lib/systemd/systemd-interfaces.vala
    src/controller/IBrickManagerModule.vala
    src/dbus/ConnManAgent.vala
    src/view/AboutWindow.vala
    src/view/BatteryInfoWindow.vala
    src/view/BatteryStatusBarItem.vala
    src/view/BrickManagerWindow.vala
    src/view/ConnManAgentInputDialog.vala
    src/view/HomeWindow.vala
    src/view/NetworkConnectionMenuItem.vala
    src/view/NetworkConnectionsWindow.vala
    src/view/NetworkPropertiesWindow.vala
    src/view/NetworkStatusBarItem.vala
    src/view/NetworkStatusWindow.vala
    src/view/ShutdownDialog.vala
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
    libpng12
    ${BRICKMAN_TEST_MODULES}
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} grx20 jpeg png)
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
    bindings/*.vapi
OPTIONS
    --target-glib=2.40
    --thread
)

add_executable(${EXEC_NAME} ${VALA_C})

if (BRICKMAN_TEST)
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/lib/ev3devKit/src/desktop/main_window.glade
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

add_custom_target(run
    COMMAND ${EXEC_NAME}
    DEPENDS ${EXEC_NAME}
    WORKING_DIRECTORY ${CMAKE_PROJECT_DIR}
)

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION sbin)

