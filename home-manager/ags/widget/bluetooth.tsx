import { Gtk } from "ags/gtk4";
import AstalBluetooth from "gi://AstalBluetooth?version=0.1";
import { createBinding, createComputed, For, With } from "gnim";

const bt = AstalBluetooth.get_default()

export default function Bluetooth() {

    const isEnabled = createBinding(bt, "isPowered")

    const devices = createBinding(bt, "devices")

    // .adapter




    return <menubutton>

        <label label={isEnabled(e => `Bluetooth: ${e ? "On" : "Off"}`)} />
        <popover>

            <togglebutton active={isEnabled()} onToggled={() => bt.toggle()} halign={Gtk.Align.END} />

            <For each={devices}>{device => <label label={device.name} />}</For>
        </popover>
    </menubutton>

}
