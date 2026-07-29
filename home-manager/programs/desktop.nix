{
    pkgs,
    lib,
    inputs,
    ...
}: let
    # wallpaper = ../wallpapers/earth.jpg;
    # wallpaper = "${pkgs.kdePackages.breeze}/share/wallpapers/Next/contents/images/5120x2880.png";
    wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/ScarletTree/contents/images/5120x2880.png";

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

    catppuccinMochaGtk = pkgs.catppuccin-gtk.override {
        variant = "mocha";
        accents = ["blue"];
        size = "standard";
    };
in {
    home.pointerCursor = {
        enable = true;
        gtk.enable = true;
        hyprcursor.enable = true;
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
    };

    gtk = {
        enable = true;
        theme = {
            name = "catppuccin-mocha-blue-standard";
            package = catppuccinMochaGtk;
        };
        iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.catppuccin-papirus-folders;
        };
        gtk4.theme = null;
    };

    home.packages = with pkgs; [
        wf-recorder # pkill doesn't work well unless I call it from the path
        satty # I want to use this to open images
    ];

    services = {
        kdeconnect = {
            enable = true;
        };

        wayle = {
            enable = true;
            autoInstallDependencies = true;
            settings = {
                osd.enabled = false;
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
                    hyprland-workspaces = {
                        app-icons-show = true;
                    };
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
                        scroll-up = "wpctl set-volume @DEFAULT_SINK@ 5%+";
                        scroll-down = "wpctl set-volume @DEFAULT_SINK@ 5%-";
                        middle-click = "wpctl set-mute @DEFAULT_SINK@ toggle";
                    };
                    power = {
                        left-click = "shutdown -h now";
                        right-click = "hyprctl dispatch 'hl.dsp.exit()'";
                    };
                };
            };
        };

        hyprpaper = {
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
    };

    wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd.enable = true;
        package = null;
        portalPackage = null;
        configType = "lua";

        settings = let
            mkLuaInline = lib.generators.mkLuaInline;
            terminal-cmd = "${pkgs.ghostty}/bin/ghostty";
            browser-cmd = "helium-browser";
            media-player-cmd = "${pkgs.spotify}/bin/spotify";
        in {
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
                {
                    leaf = "windowsIn";
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

                workspaces-with-keybinds = [
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

                workspace-binds =
                    workspaces-with-keybinds
                    |> lib.imap (i: key: let
                        wk = toString i;
                    in [
                        {
                            _args = ["${wmod} + ${key}" (workspace "${wk}" |> focus)];
                        }
                        {
                            _args = ["${wmod} + SHIFT + ${key}" (workspace "${wk}" |> move)];
                        }
                    ])
                    |> lib.flatten;

                # helper functions
                exec = cmd: mkLuaInline ''hl.dsp.exec_cmd("${cmd}")'';
                dir = dir: "{direction = \"${dir}\"}";
                workspace = workspace: "{workspace = \"${workspace}\"}";
                focus = rest-str: mkLuaInline ''hl.dsp.focus(${rest-str})'';
                move = rest-str: let
                    # this is a stupid hack
                    str-len = builtins.stringLength rest-str;
                    temp-str = builtins.substring 0 (str-len - 1) rest-str;
                    final-str = "${temp-str}, follow = true}";
                in (mkLuaInline ''hl.dsp.window.move(${final-str})'');
                move-ws = rest-str: (mkLuaInline ''hl.dsp.workspace.move({monitor = "${rest-str}"})'');
                uuid =
                    #lua
                    ''
                        local function uuid()
                          local handle = io.popen("uuidgen")
                          local result = handle:read("*a"):gsub("%s+", "")
                          handle:close()
                          return result
                        end
                    '';

                satty-cmd =
                    ''
                        ${pkgs.satty}/bin/satty
                            -f -
                            --copy-command wl-copy
                            --floating-hack
                            --early-exit
                            --actions-on-escape save-to-clipboard
                            --actions-on-right-click save-to-clipboard
                    ''
                    |> lib.strings.splitString "\n"
                    |> builtins.map lib.strings.trim
                    |> builtins.filter (val: builtins.stringLength val > 0)
                    |> builtins.concatStringsSep " ";
            in
                workspace-binds
                ++ [
                    # Execution
                    {_args = ["${mod} + Q" (mkLuaInline ''hl.dsp.window.close()'') {locked = true;}];}
                    {_args = ["${mod} + T" (exec terminal-cmd)];}
                    {_args = ["${mod} + B" (exec browser-cmd)];} # I have this downloaded with a flake its too annoying to grab it from inputs
                    {_args = ["${mod} + Space" (exec "rofi -show combi")];}

                    # Media Controls
                    {_args = ["XF86AudioRaiseVolume" (exec "wpctl set-volume @DEFAULT_SINK@ 5%+")];}
                    {_args = ["XF86AudioLowerVolume" (exec "wpctl set-volume @DEFAULT_SINK@ 5%-")];}
                    {_args = ["XF86AudioMute" (exec "wpctl set-mute @DEFAULT_SINK@ toggle")];}
                    {_args = ["XF86AudioPlay" (exec "playerctl play-pause")];}
                    {_args = ["XF86AudioNext" (exec "playerctl next")];}
                    {_args = ["XF86AudioPrev" (exec "playerctl previous")];}

                    #  Screenshots
                    {
                        _args = [
                            "${mod} + S"
                            (exec ''${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -d)\" - | ${satty-cmd}'')
                        ];
                    }
                    {
                        _args = [
                            "${mod} + SHIFT + S"
                            (mkLuaInline ''
                                function()
                                    local monitor = hl.get_active_monitor();
                                    hl.dispatch(hl.dsp.exec_cmd("${pkgs.grim}/bin/grim -o " .. monitor.name .." - | ${satty-cmd}"));
                                end
                            '')
                        ];
                    }
                    # Recordings
                    {
                        _args = [
                            "${mod} + SHIFT + R"
                            (mkLuaInline ''
                                (function()
                                    ${uuid}
                                    local monitor = nil;

                                    return function ()
                                        -- pkill doesn't work well unless I call it from PATH make sure its installed somewhere else
                                        os.execute("pkill -INT -f wf-recorder");
                                        if tmp_path then
                                            hl.dispatch(hl.dsp.exec_cmd("echo -n \"file:///" ..tmp_path .."\" | wl-copy --type text/uri-list"));
                                            if monitor then
                                                hl.notification.create({
                                                    text = "Recording from "..monitor.name .."Saved to Clipboard & " ..tmp_path,
                                                    timeout = 5000,
                                                    icon = "ok"
                                                });
                                            else
                                                hl.notification.create({
                                                    text = "Recording Saved to Clipboard & " ..tmp_path,
                                                    timeout = 5000,
                                                    icon = "ok"
                                                });
                                            end
                                            tmp_path = nil;
                                            monitor = nil;
                                        else
                                            monitor = hl.get_active_monitor();
                                            tmp_path = "/tmp/" ..uuid() .. ".mp4";
                                            hl.dispatch(hl.dsp.exec_cmd("wf-recorder -o "..monitor.name  .." -f " ..tmp_path))
                                            hl.notification.create({
                                                text = "Recording "..monitor.name .."Started",
                                                timeout = 5000,
                                                icon = "ok"
                                            });
                                        end
                                   end
                                end)()
                            '')
                        ];
                    }
                    {
                        _args = [
                            "${mod} + R"
                            (mkLuaInline ''
                                (function()
                                    ${uuid}
                                    return function ()
                                        os.execute("pkill -INT -f wf-recorder");
                                        if tmp_path then
                                            hl.dispatch(hl.dsp.exec_cmd("echo -n \"file:///" ..tmp_path .."\" | wl-copy --type text/uri-list"))
                                            hl.notification.create({
                                                text = "Recording Saved to Clipboard & " ..tmp_path,
                                                timeout = 5000,
                                                icon = "ok"
                                            })
                                            tmp_path = nil;
                                        else
                                            tmp_path = "/tmp/" ..uuid() .. ".mp4";
                                            hl.dispatch(hl.dsp.exec_cmd("wf-recorder -g \"$(${pkgs.slurp}/bin/slurp)\" -f " ..tmp_path))
                                            hl.notification.create({ text = "Recording Started", timeout = 5000, icon = "ok" })
                                        end
                                   end
                                end)()
                            '')
                        ];
                    }

                    # Navigation
                    {_args = ["${wmod} + j" (dir "d" |> focus)];}
                    {_args = ["${wmod} + k" (dir "u" |> focus)];}
                    {_args = ["${wmod} + h" (dir "l" |> focus)];}
                    {_args = ["${wmod} + l" (dir "r" |> focus)];}

                    {_args = ["${wmod} + SHIFT + j" (dir "d" |> move)];}
                    {_args = ["${wmod} + SHIFT + k" (dir "u" |> move)];}
                    {_args = ["${wmod} + SHIFT + h" (dir "l" |> move)];}
                    {_args = ["${wmod} + SHIFT + l" (dir "r" |> move)];}

                    {_args = ["${mod} + SHIFT + j" ("d" |> move-ws)];}
                    {_args = ["${mod} + SHIFT + k" ("u" |> move-ws)];}
                    {_args = ["${mod} + SHIFT + h" ("l" |> move-ws)];}
                    {_args = ["${mod} + SHIFT + l" ("r" |> move-ws)];}

                    # Hide
                    {
                        _args = [
                            "${mod} + H"
                            (mkLuaInline ''
                                function ()
                                    local ws = hl.get_active_workspace();
                                    local sp = "special:minimized-".. ws.name;
                                    local tag = "min-".. ws.name;

                                    if hl.get_workspace(sp) then
                                        hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace(), window = "tag:".. tag }))
                                        hl.dispatch(hl.dsp.window.clear_tags({ window = "tag:" .. tag }))
                                    else
                                        hl.dispatch(hl.dsp.window.tag({ tag = tag, window = hl.get_active_window() }))
                                        hl.dispatch(hl.dsp.window.move({ workspace = sp, follow = false }))
                                    end
                                end
                            '')
                        ];
                    }

                    # Floating
                    {
                        _args = [
                            "${mod} + F"
                            (mkLuaInline ''
                                function()
                                    hl.dispatch(hl.dsp.window.float());
                                    hl.dispatch(hl.dsp.window.resize({ x = 1600, y = 1080}));
                                    hl.dispatch(hl.dsp.window.center());
                                end
                            '')
                        ];
                    }

                    # Mouse
                    {_args = ["${mod} + mouse:272" (mkLuaInline ''hl.dsp.window.drag()'') {mouse = true;}];}
                    {_args = ["${mod} + mouse:273" (mkLuaInline ''hl.dsp.window.resize()'') {mouse = true;}];}
                ];

            on = [
                {
                    # This automatically opens a specific window whenever I go to a specific empty workspace
                    _args = [
                        "workspace.active"
                        (let
                            persitant-workspaces = [
                                {
                                    ws = "10";
                                    pkgs-path = terminal-cmd;
                                }

                                {
                                    ws = "11";
                                    pkgs-path = browser-cmd;
                                }
                                {
                                    ws = "12";
                                    pkgs-path = "${inputs.helium.packages.x86_64-linux.helium-whatsapp}/bin/helium-whatsapp";
                                }
                                {
                                    ws = "13";
                                    pkgs-path = media-player-cmd;
                                }
                            ];
                        in
                            mkLuaInline ''
                                function (ws_obj)
                                    local ws = ws_obj.name;
                                    local windows = hl.get_workspace_windows(ws);

                                    if #windows > 0 then
                                        return ;
                                    end

                                ${
                                    persitant-workspaces
                                    |> map (val:
                                    #lua
                                    ''
                                        if ws == "${val.ws}" then
                                            hl.dispatch(
                                                hl.dsp.exec_cmd(
                                                    "${val.pkgs-path}",
                                                    {
                                                        workspace = ws,
                                                        no_initial_focus = true,
                                                        tag = "+auto-open"
                                                    }
                                                )
                                            );
                                        end
                                    '')
                                    |> builtins.concatStringsSep ""
                                }
                                end
                            '')
                    ];
                }
                {
                    # This keeps the window that was automatically opened by the workspace.active
                    # From stealing focus from an active application if it took too long to open and I
                    # went to another workspace
                    _args = [
                        "window.open"
                        (mkLuaInline ''
                            function(o_window)
                                local function has_tag(w, tag_name)
                                    for _, t in ipairs(w.tags) do
                                        if t == tag_name then
                                            return true
                                        end
                                    end
                                    return false;
                                end

                                if not has_tag(o_window, "auto-open*") then
                                    return;
                                end

                                local a_ws = hl.get_active_workspace();

                                if o_window.workspace.name == a_ws.name then
                                    hl.dispatch(hl.dsp.focus({window = o_window}));
                                end
                            end
                        '')
                    ];
                }
            ];
        };
    };

    programs = {
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
