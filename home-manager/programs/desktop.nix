{
    pkgs,
    lib,
    ...
}: let
    wallpaper = ../wallpapers/earth.jpg;

    catppuccinMochaRofi = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/rofi/main/themes/catppuccin-mocha.rasi";
        sha256 = "0ikn0yc2b9cyzk4xga8mcq1j7xk2idik4wzpsibrphy8qr2pla4b";
    };
    catppuccinDefaultRofi = builtins.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/rofi/main/catppuccin-default.rasi";
        sha256 = "1f3r6yarrykj8cxvi5hblzlr5n8zbncifnxps9xl5gl32w6ysq5z";
    };
    rofiCatppuccinTheme = pkgs.writeTextFile {
        name = "catppuccin-rofi-config";
        text = ''
            @import "${catppuccinMochaRofi}"
            @import "${catppuccinDefaultRofi}"
        '';
    };
in {
    home.pointerCursor = {
        gtk.enable = true;
        hyprcursor.enable = true;
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
    };

    services.kdeconnect = {
        enable = true;
    };

    services.wayle = {
        enable = true;
        autoInstallDependencies = true;
        settings = {
            bar = {
                layout = [
                    {
                        monitor = "*";
                        left = ["window-title" "hyprland-workspaces"];
                        center = ["weather" "clock"];
                        right = ["media" "bluetooth" "network" "volume" "power"];
                    }
                ];
                location = "top";
                rounding = "sm";
                scale = 1;
            };
            modules = {
                window-title = {
                    label-max-length = 50;
                };
                hyprland-workspaces = {};
                weather = {
                    units = "imperial";
                    location = "New York";
                };
                clock = {
                    format = "%a %e %b | %I:%M %p";
                    icon-show = false;
                };
                media = {
                    label-max-length = 20;
                };
                bluetooth = {
                    label-show = false;
                };
                network = {
                    label-show = false;
                };
                volume = {
                    label-show = false;
                };
                power = {
                    left-click = "shutown -h now";
                    right-click = "hyprctl dispatch 'hl.dsp.exit()'";
                };
            };
        };
    };

    services.hyprpaper = {
        enable = true;
        settings = {
            splash = false;
            preload = [
                "${wallpaper}"
            ];
            wallpaper = [
                {
                    monitor = "";
                    path = "${wallpaper}";
                }
            ];
        };
    };

    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd.enable = true;
        package = null;
        portalPackage = null;
        configType = "lua";

        settings = {
            config = {
                misc = {
                    middle_click_paste = false;
                };
                input = {
                    repeat_delay = 300;
                    repeat_rate = 30;
                };
            };
            animation = [
                {
                    leaf = "workspaces";
                    enabled = false;
                }
            ];

            # Smart Gap
            workspace_rule = [
                {
                    workspace = "w[tv1]";
                    gaps_out = 0;
                    gaps_in = 0;
                }
                {
                    workspace = "f[1]";
                    gaps_out = 0;
                    gaps_in = 0;
                }
            ];
            window_rule = [
                {
                    match = {
                        float = false;
                        workspace = "w[tv1]";
                    };
                    border_size = 0;
                }
                {
                    match = {
                        float = false;
                        workspace = "w[tv1]";
                    };
                    rounding = 0;
                }
                {
                    match = {
                        float = false;
                        workspace = "f[1]";
                    };
                    border_size = 0;
                }
                {
                    match = {
                        float = false;
                        workspace = "f[1]";
                    };
                    rounding = 0;
                }
            ];

            bind = let
                # keybinds
                mod = "SUPER";
                wmod = "ALT";

                workspaces = [
                    "1"
                    "2"
                    "3"
                    "4"
                    "5"
                    "6"
                    "7"
                    "8"
                    "9"
                    "a"
                    "s"
                    "d"
                    "r"
                ];

                focus-workspace = lib.imap (i: key: let wk = toString i; in {_args = ["${wmod} + ${key}" ("${wk}" |> workspace |> focus)];}) workspaces;
                move-workspace = lib.imap (i: key: let wk = toString i; in {_args = ["${wmod} + SHIFT + ${key}" ("${wk}" |> workspace |> move)];}) workspaces;

                # helper functions
                dsp = rest-str: (lib.generators.mkLuaInline "hl.dsp.${rest-str}");
                exec = cmd: dsp "exec_cmd(\"${cmd}\")";
                dir = dir: "{direction = \"${dir}\"}";
                workspace = workspace: "{workspace = \"${workspace}\"}";
                focus = rest-str: dsp "focus(${rest-str})";

                # this is a stupid hack
                move = rest-str: let
                    str-len = builtins.stringLength rest-str;
                    temp-str = builtins.substring 0 (str-len - 1) rest-str;
                    final-str = "${temp-str}, follow = true}";
                in (dsp "window.move(${final-str})");
            in
                focus-workspace
                ++ move-workspace
                ++ [
                    # Execution
                    {_args = ["${mod} + Q" (dsp "window.close()") {locked = true;}];}
                    {_args = ["${mod} + T" (exec "${pkgs.ghostty}/bin/ghostty")];}
                    {_args = ["${mod} + B" (exec "zen-beta")];} # I have this downloaded with a flake its too annoying to grab it from inputs
                    {_args = ["${mod} + S" (exec "${pkgs.hyprshot}/bin/hyprshot -m region --clipboard-only")];}
                    {_args = ["${mod} + Space" (exec "rofi -show combi")];}
                    {_args = ["XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_SINK@ 5%+")];}
                    {_args = ["XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_SINK@ 5%-")];}
                    {_args = ["XF86AudioMute" (exec "wpctl set-mute @DEFAULT_SINK@ toggle")];}
                    {_args = ["XF86AudioPlay" (exec "playerctl play-pause")];}
                    {_args = ["XF86AudioNext" (exec "playerctl next")];}
                    {_args = ["XF86AudioPrev" (exec "playerctl previous")];}

                    # Navigation
                    {_args = ["${wmod} + j" ("d" |> dir |> focus)];}
                    {_args = ["${wmod} + k" ("u" |> dir |> focus)];}
                    {_args = ["${wmod} + h" ("l" |> dir |> focus)];}
                    {_args = ["${wmod} + l" ("r" |> dir |> focus)];}

                    {_args = ["${wmod} + SHIFT + j" ("d" |> dir |> move)];}
                    {_args = ["${wmod} + SHIFT + k" ("u" |> dir |> move)];}
                    {_args = ["${wmod} + SHIFT + h" ("l" |> dir |> move)];}
                    {_args = ["${wmod} + SHIFT + l" ("r" |> dir |> move)];}

                    # Special
                    {_args = ["${wmod} + f" (dsp "workspace.toggle_special(\"special\")")];}
                    {_args = ["${wmod} + SHIFT + f" ("special:special" |> workspace |> move)];}
                    {
                        _args = [
                            "${wmod} + T"
                            (lib.generators.mkLuaInline
                            ''
                                function()
                                    hl.dispatch(hl.dsp.window.float());
                                    hl.dispatch(hl.dsp.window.resize({ x = 1600, y = 1080}));
                                    hl.dispatch(hl.dsp.window.center());
                                end
                            '')
                        ];
                    }

                    # Mouse
                    {_args = ["${mod} + mouse:272" (dsp "window.drag()") {mouse = true;}];}
                    {_args = ["${mod} + mouse:273" (dsp "window.resize()") {mouse = true;}];}
                ];
        };
    };

    programs = {
        hyprshot.enable = true;
        rofi = {
            enable = true;
            terminal = "${pkgs.ghostty}/bin/ghostty";
            theme = "${rofiCatppuccinTheme}";
            extraConfig = {
                modi = "drun,run,calc,combi";
                combi-modes = "drun,run,calc";
                show-icons = true;
                font = "JetBrains Mono 12";

                no-show-match = true;
                no-sort = true;
            };
            plugins = with pkgs; [rofi-calc];
        };
    };
}
