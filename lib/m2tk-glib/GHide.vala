/*
 * m2tk-glib -- GLib bindings for m2tklib graphical toolkit
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
 * GHide.vala:
 *
 * wrapper for m2tk HIDE element
 */

namespace M2tk {
    public class GHide : M2tk.GElement {
        Hide hide { get { return (Hide)element; } }

        public GElement child {
            get {
                return element_map[hide.child];
            }
            set {
                hide.child = value.element;
                dirty = true;
            }
        }

        HideState _state;
        public HideState state {
            get { return _state; }
            set {
                _state = value;
                dirty = true;
            }
        }

        public override bool dirty {
            get { return base.dirty | child.dirty; }
            set {
                if (!value)
                    child.dirty = false;
                base.dirty = value;
            }
        }

        public GHide(GElement child = GElement.null_element) {
            set_element(Hide.create(child.element, ref _state));
        }
    }
}

