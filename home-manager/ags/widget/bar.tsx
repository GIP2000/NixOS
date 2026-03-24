import app from "ags/gtk4/app"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import { createBinding } from "gnim";

import Internet from "./network"

import AstalHyprland from "gi://AstalHyprland?version=0.1"
import Bluetooth from "./bluetooth";
import Sound from "./audio";
import GLib from "gi://GLib?version=2.0";
import { createPoll } from "ags/time";

const hypr = AstalHyprland.get_default();

export default function Bar(gdkmonitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor
    const peristent = [10, 11, 12, 13];

    const fw = createBinding(hypr, "focusedWorkspace")

    const time = createPoll("", 1000, async () => GLib.DateTime.new_now_local().format("%a %e %b | %I:%M %p") ?? "");

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
                    <box class="workspaces">
                        {peristent.map(x =>
                            <button class={fw(fw => fw.id === x ? "workspace-button-active" : "workspace-button")} onClicked={() => hypr.get_workspace(x).focus()}>
                                <label label="" />
                            </button>
                        )}
                    </box>
                </box>
                <box $type="center" class="clock" hexpand halign={Gtk.Align.CENTER}>
                    <label label={time} />
                </box>
                <box $type="end" hexpand halign={Gtk.Align.END}>
                    <Sound />
                    <Bluetooth />
                    <Internet />
                </box>
            </centerbox>
        </window>
    )
}
