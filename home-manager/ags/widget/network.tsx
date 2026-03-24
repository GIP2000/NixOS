import { Gtk } from "ags/gtk4"
import AstalNetwork from "gi://AstalNetwork?version=0.1";
import { createBinding, createComputed, For, With } from "gnim";

const network = AstalNetwork.get_default();

const stateToString = {
    [AstalNetwork.State.UNKNOWN]: "UNKNOWN",
    [AstalNetwork.State.ASLEEP]: "ASLEEP",
    [AstalNetwork.State.DISCONNECTED]: "DISCONNECTED",
    [AstalNetwork.State.DISCONNECTING]: "DISCONNECTING",
    [AstalNetwork.State.CONNECTING]: "CONNECTING",
    [AstalNetwork.State.CONNECTED_LOCAL]: "CONNECTED_LOCAL",
    [AstalNetwork.State.CONNECTED_SITE]: "CONNECTED_SITE",
    [AstalNetwork.State.CONNECTED_GLOBAL]: "CONNECTED_GLOBAL",
}

function NetworkPopup() {

    const currentSSID = createBinding(network, "wifi", "ssid")
    const wifiEnabled = createBinding(network, "wifi", "enabled")
    const accesPoints = createBinding(network, "wifi", "accessPoints")

    return (
        <box orientation={Gtk.Orientation.VERTICAL}>
            <box>
                <label label={currentSSID(ssid => `Wifi: ${ssid ?? "Off"}`)} />

                <switch active={wifiEnabled()} onStateSet={({ active }) => network.wifi.set_enabled(active)} halign={Gtk.Align.END} />
            </box>


            <box orientation={Gtk.Orientation.VERTICAL} visible={wifiEnabled()}>
                <label label={""} />
                <For each={accesPoints}>{value =>
                    <label label={value.ssid} />
                }</For>
            </box>

        </box>

    );


}

function NetworkLabelRouter() {
    const wifiStrengthIdx = createBinding(network, "wifi", "strength")
    const wifiStrength = createComputed(() => wifiStrengthIdx((idx) => ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"][Math.ceil(idx / 20) - 1]));


    const primary = createBinding(network, "primary");
    const status = createBinding(network, "state");

    return <With value={status}>
        {(status) => {

            if (
                status === AstalNetwork.State.DISCONNECTED ||
                status === AstalNetwork.State.DISCONNECTING ||
                status === AstalNetwork.State.UNKNOWN ||
                status === AstalNetwork.State.ASLEEP
            ) {
                return <label label={stateToString[status]} />
            }

            if (status === AstalNetwork.State.CONNECTING) {
                return <label label="..." />
            }

            return <box>
                <With value={primary}>{(primary) => {
                    if (primary === AstalNetwork.Primary.UNKNOWN) {
                        return <label label={"Connected to UNKNOWN"} />
                    }
                    if (primary === AstalNetwork.Primary.WIRED) {
                        return <label label={"Connected to Wired"} />
                    }
                    return <label label={wifiStrength()} />
                }}</With>
            </box>

        }}
    </With>;
}

export default function Internet() {
    return <menubutton>
        <NetworkLabelRouter />
        <popover onShow={() => network.wifi.scan()}>
            <NetworkPopup />
        </popover>
    </menubutton>;

}
