project (brickdm)

cmake_minimum_required (VERSION 2.6)

list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

set (DATADIR "${CMAKE_INSTALL_PREFIX}/share")

set (PKGDATADIR "${DATADIR}/brickdm")
set (EXEC_NAME "brickdm")
set (RELEASE_NAME "Brick Display Manager")
set (VERSION "0.1")
set (VERSION_INFO "alpha")

find_package(PkgConfig REQUIRED)
pkg_check_modules(DEPS REQUIRED
    glib-2.0
    gobject-2.0
    gio-2.0
    gee-1.0
    ncurses
    dbus-glib-1
    libnm-util
    libnm-glib
)
add_definitions(${DEPS_CFLAGS})
link_libraries(${DEPS_LIBRARIES} u8g m2tk)
link_directories(${DEPS_LIBRARY_DIRS})

find_package(Vala REQUIRED)
include(ValaVersion)
ensure_vala_version("0.16" MINIMUM)
include(ValaPrecompile)

vala_precompile(VALA_C ${EXEC_NAME}
    lib/m2tk-glib/GM2tk.vala
    lib/m2tk-glib/GElement.vala
    lib/m2tk-glib/GAlign.vala
    lib/m2tk-glib/GBox.vala
    lib/m2tk-glib/GButton.vala
    lib/m2tk-glib/GElementList.vala
    lib/m2tk-glib/GFontList.vala
    lib/m2tk-glib/GGridList.vala
    lib/m2tk-glib/GHList.vala
    lib/m2tk-glib/GLabel.vala
    lib/m2tk-glib/GListElement.vala
    lib/m2tk-glib/GNullElement.vala
    lib/m2tk-glib/GRoot.vala
    lib/m2tk-glib/GSpace.vala
    lib/m2tk-glib/GToggle.vala
    lib/m2tk-glib/GVList.vala
    lib/connman/Manager.vala
    lib/connman/Peer.vala
    lib/connman/Service.vala
    lib/connman/Technology.vala
    src/BrickDisplayManager.vala
    src/GUI.vala
    src/Network.vala
    #src/Power.vala
    src/view/BatteryInfoScreen.vala
    src/view/BatteryHistScreen.vala
    src/view/BatteryStatsScreen.vala
    src/view/BatteryStatusBarItem.vala
    src/view/BrickDisplayManager.vala
    src/view/HomeScreen.vala
    src/view/NetworkStatusScreen.vala
    src/view/NetworkTechnologyItem.vala
    src/view/Screen.vala
    src/view/ShutdownScreen.vala
    src/view/StatusBar.vala
    src/view/StatusBarItem.vala
PACKAGES
    glib-2.0
    gobject-2.0
    gio-2.0
    gee-1.0
    curses
    posix
    linux
    dbus-glib-1
CUSTOM_VAPIS
    bindings/*.vapi
OPTIONS
    --target-glib=2.40
)

add_executable(${EXEC_NAME} ${VALA_C})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/test1.desktop DESTINATION ${DATADIR}/applications/)
