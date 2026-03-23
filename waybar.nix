{
    enable = true;
    style = ''
        /* --- TOKYO NIGHT PALETTE --- */
        @define-color bg        #1a1b26;
        @define-color fg        #c0caf5;
        @define-color blue      #7aa2f7;
        @define-color purple    #bb9af7;
        @define-color green     #9ece6a;
        @define-color red       #f7768e;
        @define-color dark_g    #24283b;

        * {
            border: none;
            border-radius: 0;
            font-family: JetBrainsMono Nerd Font Propo;
            font-weight: bold;
            font-size: 11px;
            min-height: 0;
            box-shadow: none;
            text-shadow: none;
        }

        window#waybar {
            background: transparent;
            color: @fg;
        }

        tooltip {
            background: @bg;
            border: 1px solid @blue;
            border-radius: 8px;
        }


        /* --- WORKSPACES --- */
        #workspaces {
            background: @dark_g;
            padding: 2px 4px;
            border-radius: 12px;
        }

        #workspaces button {
            padding: 0 4px;
            color: @fg;
            font-size: 10px;
            transition: all 0.3s ease;
        }

        #workspaces button.active {
            color: @bg;
            background: @purple;
            border-radius: 10px;
            padding: 0 10px;
            margin: 1px 0;
            min-width: 20px;
        }

        #workspaces button:hover {
            color: @blue;
            background: @bg;
        }

        #clock {
            background: @dark_g;
            color: @fg;
            padding: 0 10px;
            border-radius: 12px;
        }

        /* --- MODULI DESTRA (TUTTE LE ISOLE) --- */
        #pulseaudio, #network, #bluetooth, #custom-control-center {
            background: @dark_g;
            padding: 0 10px;
            margin-right: 6px;
            border-radius: 12px;
        }

        #cpu { color: @blue; }
        #pulseaudio { color: @fg; }
        #network { color: @blue; }
        #bluetooth { color: @green; }


        /* --- CONTROL CENTER --- */
        #custom-control-center {
            color: @purple;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        #custom-control-center:hover {
            background: @purple;
            color: @bg;
        }

        /* --- PULSANTE SPEGNIMENTO --- */
        #custom-power {
            background: @dark_g;
            color: @red;
            padding: 0 10px;
            border-radius: 12px;
            font-size: 14px;
            transition: all 0.3s ease;
        }

        #custom-power:hover {
            background: @red;
            color: @bg;
        }

        #custom-camera, #custom-mic {
            border-radius: 12px;
            transition: all 0.3s ease-in-out;
            /* Colori di base quando sono attivi */
            color: @bg;
        }
        #custom-camera.inactive, #custom-mic.inactive {
            font-size: 0px;
            padding: 0px;
            margin-left: 0px;
            background: transparent;
            color: transparent;
        }

        #custom-camera.active {
            font-size: 14px;
            padding: 0 10px;
            margin-left: 10px;
            background: @green;
        }

        #custom-mic.active {
            font-size: 14px;
            padding: 0 10px;
            margin-left: 10px;
            background: @red; /* O @red se preferisci lo stile iOS */
        }
    '';
    settings = {
        mainBar = {
            layer = "top";
            position = "top";
            mod = "dock";
            height = 28;
            exclusive = true;
            passthrough = false;
            gtk-layer-shell = true;
            reload_style_on_change = true;

            margin-top = 5;
            margin-left = 10;
            margin-right = 10;
            margin-bottom = 0;

            modules-left = ["hyprland/window" "hyprland/workspaces" "custom/camera" "custom/mic"];
            modules-center = ["clock"];
            modules-right = ["pulseaudio" "network" "bluetooth" "custom/control-center" "custom/power"];

            "hyprland/window" = {
                format = "{initialTitle}";
                max-length = 80;
                icon = true;
                icon-size = 24;
            };

            "hyprland/workspaces" = {
                disable-scroll = true;
                all-outputs = true;
                active-only = false;
                on-click = "activate";
                persistent-workspaces = {
                    "10" = [];
                    "11" = [];
                    "12" = [];
                    "13" = [];
                };
                format = "";
            };

            # --- INDICATORI PRIVACY ---
            "custom/camera" = {
                exec = "~/.config/waybar/scripts/check_cam.sh";
                interval = 2;
                return-type = "json";
                format = "{icon}";
                format-icons = {
                    active = "󰄀";
                    inactive = "󰄀";
                };
            };

            "custom/mic" = {
                exec = "~/.config/waybar/scripts/check_mic.sh";
                interval = 2;
                return-type = "json";
                format = "{icon}";
                format-icons = {
                    active = "";
                    inactive = "";
                };
            };

            clock = {
                format = "{:%a %d %b  |  %H:%M}";
                tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            };

            # --- AUDIO ---
            pulseaudio = {
                format = "{icon} {volume}%";
                format-muted = "󰖁 Muted";
                format-icons = {
                    headphone = "";
                    default = ["󰕿" "󰖀" "󰕾"];
                };
                on-click = "eww -c ~/.config/waybar/scripts/volume open --toggle audiomenu";
                tooltip = false;
            };

            network = {
                interval = 2;
                format-wifi = " ";
                format-ethernet = "󰈀 ";
                format-linked = "󰈀 (No IP)";
                format-disconnected = "󰖪 ";
                tooltip-format = "Network: <big><b>{essid}</b></big>\nSignal strength: <b>{signaldBm}dBm ({signalStrength}%)</b>\nFrequency: <b>{frequency}MHz</b>\nInterface: <b>{ifname}</b>\nIP: <b>{ipaddr}/{cidr}</b>\nGateway: <b>{gwaddr}</b>\nNetmask: <b>{netmask}</b>";
                on-click = "eww -c ~/.config/waybar/scripts/wifi open --toggle wifimenu";
                on-click-right = "mode";
                format-alt = "<span foreground='#99ffdd'> {bandwidthDownBytes}</span> <span foreground='#ffcc66'> {bandwidthUpBytes}</span>";
            };

            bluetooth = {
                format = "";
                format-disabled = "󰂲";
                format-connected = "󰂱";
                tooltip-format = "{controller_alias}\n{num_connections} dispositivi connessi";
                on-click = "eww -c ~/.config/waybar/scripts/bluetooth open bluetoothmenu";
            };

            # --- CONTROL CENTER ---
            "custom/control-center" = {
                format = "";
                tooltip = false;
                on-click = "eww open control-center";
            };

            # --- SPEGNIMENTO ---
            "custom/power" = {
                format = "⏻";
                tooltip = false;
                on-click = "shutdow -h now";
            };

            # layer = top;
            # position = top;
            # height = 30;
            # modules-left = [
            #     "hyprland/window"
            #     "hyprland/workspaces"
            # ];
            # modules-center = [
            #     clock
            # ];
            # modules-right = [
            #     tray
            #     network
            #     pulseaudio
            # ];
            #
            # "hyprland/window" = {
            #     format = "{initialTitle}";
            #     max-length = 80;
            #     icon = true;
            #     icon-size = 24;
            # };
            #
            # "hyprland/workspaces" = {
            #     disable-scroll = true;
            #     all-outputs = false;
            #     format = "{icon}";
            #     format-icons = {
            #         default = "󰜌";
            #         active = "󰜋";
            #     };
            #     persistent-workspaces = {
            #         "10" = [];
            #         "11" = [];
            #         "12" = [];
            #         "13" = [];
            #     };
            # };
            #
            # network = {
            #     tooltip = true;
            #     format = "{icon}";
            #     format-wifi = "{icon}";
            #     format-icons = {
            #         default = [
            #             "󰤯"
            #             "󰤟"
            #             "󰤢"
            #             "󰤥"
            #             "󰤨"
            #         ];
            #     };
            #     format-ethernet = "󰤨";
            #     format-disconnected = "󰤫";
            #     format-disabled = "󰤮";
            #     tooltip-format-wifi = "󰤥 {essid} ({signalStrength}%)";
            #     tooltip-format-ethernet = " {ifname}";
            #     tooltip-format-disconnected = "󰤦 Verbindung getrennt!";
            #     tooltip-format-disabled = "󰤦 Verbindung ausgeschalten!";
            #     # on-click = "hyprctl dispatch exec '[float; size 880 879] kitty nmtui'";
            #     on-click = "nm-applet --indicator";
            #     on-click-right = "setsid ~/.config/swaync/scripts/netzwerk.sh";
            # };
            # clock = {
            #     timezone = "America/New_York";
            #     tooltip-format = "<big>{:L%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            #     format = " {:%I:%M %p}";
            #     format-alt = "󰸗 {:L%a %d.%m.%y}";
            #     calendar = {
            #         mode = year;
            #         mode-mon-col = 3;
            #         weeks-pos = right;
            #         on-scroll = 1;
            #         format = {
            #             months = "<span><b>{}</b></span>";
            #             days = "<span><b>{}</b></span>";
            #             weeks = "<span><b>W{}</b></span>";
            #             weekdays = "<span><b>{}</b></span>";
            #             today = "<span><b><u>{}</u></b></span>";
            #         };
            #     };
            # };
            #
            # pulseaudio = {
            #     format = "{icon} {volume}%";
            #     format-muted = "🔇 muted";
            #     format-icons = {
            #         default = ["🔈" "🔉" "🔊"];
            #     };
            #     on-click = "pwvucontrol";
            #     on-scroll-up = "wpctl set-volume @DEFAULT_SINK@ 5%+";
            #     on-scroll-down = "wpctl set-volume @DEFAULT_SINK@ 5%-";
            # };
        };
    };
}
