import { Gtk } from "ags/gtk4";
import AstalBluetooth from "gi://AstalBluetooth?version=0.1";
import { createBinding, For } from "gnim";

const bt = AstalBluetooth.get_default()

export default function Bluetooth() {

    const isEnabled = createBinding(bt, "isPowered")
    const devices = createBinding(bt, "devices")


    return <menubutton>
        <label label={isEnabled(e => `ᛒ: ${e ? "On" : "Off"}`)} />
        <popover
            onShow={() => {
                bt.adapter.set_pairable(true);
                bt.adapter.start_discovery();
            }}
            onHide={() => bt.adapter.stop_discovery()}
        >
            <box orientation={Gtk.Orientation.VERTICAL}>
                <switch active={isEnabled()} onStateSet={() => bt.toggle()} halign={Gtk.Align.END} />
                <For
                    each={
                        devices(d =>
                            d
                                .filter(x => (x?.name?.length ?? 0) > 0)
                                .toSorted((a, b) => Number(b.connected) - Number(a.connected) ||
                                    Number(b.paired) - Number(a.paired) ||
                                    (a.name ?? "").localeCompare(b.name ?? "")
                                )
                        )
                    }
                >
                    {(device: AstalBluetooth.Device) => (
                        <button onClicked={() => {
                            if (!device.connected) {
                                if (!device.paired) {
                                    device.pair();
                                }
                                device.connect_device((_, res) => device.connect_device_finish(res))
                            } else {
                                device.disconnect_device((_, res) => device.disconnect_device_finish(res));
                            }
                        }}>
                            <label label={`${device.connected ? "Y" : "N"} ${device.paired ? "P" : ""} ${device.name}`} />
                        </button>
                    )}
                </For>
            </box>
        </popover>
    </menubutton >

}
