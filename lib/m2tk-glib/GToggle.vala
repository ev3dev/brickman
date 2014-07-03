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
 * GToggle.vala:
 *
 * wrapper for m2tk LABEL
 */


namespace M2tk {
    public class GToggle : M2tk.GElement {
        Toggle toggle { get { return (Toggle)element; } }

        bool _checked;
        public bool checked {
            get { return _checked; }
            set {
                _checked = value;
                dirty = true;
            }
        }

        public GToggle(bool checked = false) {
            set_element(Toggle.create(ref _checked));
            toggle.func = (ElementFunc)hook_func;
            _checked = checked;
        }

        static uint8 hook_func (ElementFuncArgs arg) {
            unowned Toggle toggle = (Toggle)arg.element;
            toggle.func = (ElementFunc)Toggle.Func;
            var result = toggle.func(arg);
            toggle.func = (ElementFunc)hook_func;
            if (arg.msg == ElementMessage.SELECT)
                GElement.element_map[arg.element].notify_property("checked");
            return result;
        }
    }
}
