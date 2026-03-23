import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createBinding } from "gnim";

import Internet from "./network"

import AstalHyprland from "gi://AstalHyprland?version=0.1"
import Bluetooth from "./bluetooth";

const hypr = AstalHyprland.get_default();

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
    const peristent = [10, 11, 12, 13];

    const fw = createBinding(hypr, "focusedWorkspace")

    return (
        <window
            visible
            name="bar"
            class="Bar"
            gdkmonitor={gdkmonitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={TOP | LEFT | RIGHT}
            application={app}
        >
            <centerbox cssName="centerbox" visible>
                <box $type="start" hexpand halign={Gtk.Align.START}>
                    <box>
                        <label label={fw(fw => fw.name)} />
                    </box>
                    <box>
                        {peristent.map(x =>
                            <button onClicked={() => hypr.get_workspace(x).focus()}>
                                <label label={fw(fw => fw.id === x ? "󰜋" : "󰜌")} />
                            </button>
                        )}
                    </box>
                </box>
                <box $type="center" hexpand halign={Gtk.Align.CENTER}>
                    <label label={"Time"} />
                </box>
                <box $type="end" hexpand halign={Gtk.Align.END}>
                    <Bluetooth />
                    <Internet />
                </box>
            </centerbox>
        </window>
    )
}
