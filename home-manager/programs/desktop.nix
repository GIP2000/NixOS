{
    pkgs,
    inputs,
    ...
}: let
    pkgs-unstable = import inputs.nixpkgs-unstable {
        system = pkgs.system;
    };
    wallpaper = ../wallpapers/earth.jpg;
in {
    services.hyprpaper = {
        enable = true;
        settings = {
            preload = [
                "${wallpaper}"
            ];
            wallpaper = [
                ",${wallpaper}"
            ];
        };
    };

    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        package = null;
        portalPackage = null;
        extraConfig = ''
            exec-once = ashell
            exec-once = hyprctl dispatch workspace 10
            input {
                repeat_delay = 300
                repeat_rate  = 30
            }
        '';
        settings = {
            animations = {
                enabled = true;
                animation = [
                    "workspaces, 0, 0, deafult"
                ];
            };

            workspace = [
                "1, name: Scratch 1"
                "2, name: Scratch 2"
                "3, name: Scratch 3"
                "4, name: Scratch 4"
                "5, name: Scratch 5"
                "6, name: Scratch 6"
                "7, name: Scratch 7"
                "8, name: Scratch 8"
                "9, name: Scratch 9"
                "10, name:Terminal"
                "11, name:Web"
                "12, name:Messaging"
                "13, name:Music"

                # smart gap
                "w[tv1], gapsout:0, gapsin:0"
                "w[f1], gapsout:0, gapsin:0"
            ];

            "$mod" = "SUPER";
            "$wmod" = "ALT";
            bind = [
                "$mod, Q, killactive"
                "$mod, T, exec, ghostty"
                "$mod, B, exec, zen-beta"
                # "$mod, Space, exec, ulauncher-toggle"
                "$mod, Space, exec, rofi -show combi"

                #Focus
                "$wmod, j, movefocus, d"
                "$wmod, k, movefocus, u"
                "$wmod, h, movefocus, l"
                "$wmod, l, movefocus, r"

                #Move
                "$wmod SHIFT, j, movewindow, d"
                "$wmod SHIFT, k, movewindow, u"
                "$wmod SHIFT, h, movewindow, l"
                "$wmod SHIFT, l, movewindow, r"

                # Workspaces
                "$wmod, 1, workspace,  1"
                "$wmod, 2, workspace,  2"
                "$wmod, 3, workspace,  3"
                "$wmod, 4, workspace,  4"
                "$wmod, 5, workspace,  5"
                "$wmod, 6, workspace,  6"
                "$wmod, 7, workspace,  7"
                "$wmod, 8, workspace,  8"
                "$wmod, 9, workspace,  9"
                "$wmod, a, workspace, 10"
                "$wmod, s, workspace, 11"
                "$wmod, d, workspace, 12"
                "$wmod, r, workspace, 13"

                # Workspaces move
                "$wmod SHIFT, 1, movetoworkspace,  1"
                "$wmod SHIFT, 2, movetoworkspace,  2"
                "$wmod SHIFT, 3, movetoworkspace,  3"
                "$wmod SHIFT, 4, movetoworkspace,  4"
                "$wmod SHIFT, 5, movetoworkspace,  5"
                "$wmod SHIFT, 6, movetoworkspace,  6"
                "$wmod SHIFT, 7, movetoworkspace,  7"
                "$wmod SHIFT, 8, movetoworkspace,  8"
                "$wmod SHIFT, 9, movetoworkspace,  9"
                "$wmod SHIFT, a, movetoworkspace, 10"
                "$wmod SHIFT, s, movetoworkspace, 11"
                "$wmod SHIFT, d, movetoworkspace, 12"
                "$wmod SHIFT, r, movetoworkspace, 13"

                ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
                ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
                ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_SINK@ toggle"

                ", XF86AudioPlay, exec, playerctl play-pause"
                ", XF86AudioNext, exec, playerctl next"
                ", XF86AudioPrev, exec, playerctl previous"
            ];
        };
    };

    programs = {
        ashell = {
            enable = true;
            package = pkgs-unstable.ashell;
            settings = {
                modules = {
                    left = ["WindowTitle" "Workspaces"];
                    center = ["Tempo"];
                    right = ["MediaPlayer" ["Privacy" "Settings"]];
                };
                tempo = {
                    clock_format = "%a %e %b | %I:%M %p";
                    weather_location = "Current";
                    weather_indicator = "IconAndTemperature";
                };
                settings = {
                    bluetooth_more_cmd = "blueman-manager";
                };
                appearance = {
                    success_color = "#a6e3a1";
                    text_color = "#cdd6f4";
                    workspace_colors = ["#fab387" "#b4befe" "#cba6f7"];
                };

                appearance.primary_color = {
                    base = "#fab387";
                    text = "#1e1e2e";
                };

                appearance.danger_color = {
                    base = "#f38ba8";
                    weak = "#f9e2af";
                };

                appearance.background_color = {
                    base = "#1e1e2e";
                    weak = "#313244";
                    strong = "#45475a";
                };

                appearance.secondary_color = {
                    base = "#11111b";
                    strong = "#1b1b25";
                };
            };
        };
        hyprshot.enable = true;

        rofi = {
            enable = true;
            terminal = "${pkgs.ghostty}/bin/ghostty";
            theme = "gruvbox-dark";
            extraConfig = {
                modi = "drun,run,combi";
                show-icons = true;
                font = "JetBrains Mono 12";
            };
        };
    };
}
