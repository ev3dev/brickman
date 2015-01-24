/*
 * brickman -- Brick Manager for LEGO Mindstorms EV3/ev3dev
 *
 * Copyright 2015 David Lechner <david@lechnology.com>
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

/* GLib.vapi - additional binding for GLib */

[CCode (cprefix = "g_")]
namespace GLib {
    /**
     * Replacement for GLib.IOError.from_errno (int).
     *
     * There is a bug in the vala compiler that tries to assign the return value
     * as GError* instead of int. This function returns and int like it should.
     */
    [CCode (cheader_file = "gioerror.h")]
    public int io_error_from_errno (int errno);
}