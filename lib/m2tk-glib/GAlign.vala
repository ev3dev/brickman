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
 * GAlign.vala:
 *
 * wrapper for m2tk ALIGN
 */

namespace M2tk {
    public class GAlign : M2tk.GElement {
        Align align { get { return (Align)element; } }

        public GElement child {
            get {
                return element_map[align.child];
            }
            set {
                align.child = value.element;
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

        public VerticalAlignment vertical_alignment {
            get { return _vertical_alignment; }
            set {
                _vertical_alignment = value;
                update_format();
            }
        }

        public HorizontalAlignment horizontal_alignment {
            get { return _horizontal_alignment; }
            set {
                _horizontal_alignment = value;
                update_format();
            }
        }

        public GAlign(GElement child = GElement.null_element) {
            base(Align.create(child.element));
        }
    }
}

