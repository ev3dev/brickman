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
    upower-glib
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
    lib/m2tk-glib/GVList.vala
    src/BatteryInfoScreen.vala
    src/BatteryHistScreen.vala
    src/BatteryStatsScreen.vala
    src/brickdm.vala
    src/gui.vala
    src/home.vala
    src/Power.vala
    src/Screen.vala
    src/ShutdownScreen.vala
    src/StatusBar.vala
PACKAGES
    glib-2.0
    gobject-2.0
    gio-2.0
    gee-1.0
    curses
    posix
    linux
CUSTOM_VAPIS
    bindings/*.vapi
)

add_executable(${EXEC_NAME} ${VALA_C})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION bin)

install (FILES ${CMAKE_CURRENT_SOURCE_DIR}/data/test1.desktop DESTINATION ${DATADIR}/applications/)
