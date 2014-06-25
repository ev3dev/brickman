namespace NM {
    public class Client : NM.Object, GLib.AsyncInitable, GLib.Initable {
        public static async NM.Client new_async(GLib.Cancellable? cancellable = null) throws GLib.Error;
    }

    public class RemoteSettings : NM.Object, GLib.AsyncInitable, GLib.Initable {
        public static async NM.RemoteSettings new_async(DBus.Connection? bus, GLib.Cancellable? cancellable = null) throws GLib.Error;
    }
}
