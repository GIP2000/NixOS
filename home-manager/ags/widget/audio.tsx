import { Gtk } from "ags/gtk4";
import Wp from "gi://AstalWp"
import { createBinding } from "gnim"


const wp = Wp.get_default()
const icons = ["󰕿", "󰖀", "󰕾"];
const muteIcon = "󰖁";

export default function Sound() {
    const volume = createBinding(wp, "audio", "defaultSpeaker", "volume");


    return <menubutton>
        <label label={volume(v => `${v === 0 ? muteIcon : icons[Math.min(2, Math.floor(v / (1 / 3)))]}${v.toFixed(2)}`)} />
        <popover>
            <box hexpand orientation={Gtk.Orientation.VERTICAL} widthRequest={100}>
                <slider class="volume-slider" hexpand min={0} max={1} step={0.02} value={volume} onChangeValue={({ value }) => wp.audio.defaultSpeaker.set_volume(value)} />
            </box>
        </popover>
    </menubutton>;
}
