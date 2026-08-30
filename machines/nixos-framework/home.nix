{
    pkgs,
    lib,
    ...
}: {
    imports = [
        ../../home-manager/programs/nvim.nix
        ../../home-manager/programs/shell.nix
        ../../home-manager/programs/desktop.nix
        ../../home-manager/programs/browser.nix
        ../../home-manager/programs/shared-apps.nix
    ];

    home = {
        username = "gip";
        homeDirectory = "/home/gip";
        stateVersion = "25.11";
        packages = with pkgs; [
            sioyek
            slack
            claude-code
            codex

            (inputs.helium.mkWebApp {
                name = "helium-notion-work";
                url = "https://app.notion.com/";
                desktopName = "Notion Work";
                icon = "Notion";
                comment = "Notion note taking applicaiton";
                categories = ["Office"];
                extra_args = [
                    "--profile-directory=Work"
                ];
            })
        ];
    };
    programs = {
        hyprlock = let
            wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/ScarletTree/contents/images/5120x2880.png";
        in {
            enable = true;
            settings = {
                auth = {
                    fingerprint = {
                        enabled = true;
                        ready_message = "Scan fingerprint to unlock";
                        present_message = "Scanning...";
                    };
                };

                general = {
                    disable_loading_bar = true;
                    hide_cursor = true;
                    grace = 0;
                };

                background = [
                    {
                        path = "${wallpaper}";
                        blur_passes = 2;
                        blur_size = 7;
                    }
                ];

                input-field = [
                    {
                        size = "250, 60";
                        position = "0, -80";
                        monitor = "";
                        fade_on_empty = false;
                        placeholder_text = "Scan fingerprint or enter password";
                        font_color = "rgb(202, 211, 245)";
                        inner_color = "rgb(91, 96, 120)";
                        outer_color = "rgb(24, 25, 38)";
                    }
                ];
            };
        };
        ghostty.settings.font-size = lib.mkForce 13;
    };
    services = {
        hyprpolkitagent.enable = true;
        hypridle = {
            enable = true;
            settings = {
                general = {
                    lock_cmd = "pidof hyprlock || ${pkgs.hyprlock}/bin/hyprlock";
                    before_sleep_cmd = "loginctl lock-session";
                    after_sleep_cmd = "hyprctl dispatch dpms on";
                };

                listener = [
                    {
                        timeout = 300;
                        on-timeout = "loginctl lock-session";
                    }
                ];
            };
        };
        wayle.settings = {
            modules = {
                window-title = {
                    label-max-length = lib.mkForce 30;
                };
                power.middle-click = "hyprlock";
            };
            bar = {
                scale = lib.mkForce 0.75;
                layout = lib.mkForce [
                    {
                        monitor = "*";
                        left = ["window-title" "hyprland-workspaces"];
                        center = ["weather" "clock"];
                        right = ["media" "brightness" "bluetooth" "network" "volume" "battery" "power"];
                    }
                ];
            };
        };
    };
    wayland.windowManager.hyprland.settings = {
        monitor = [
            {
                output = "eDP-1";
                mode = "preferred";
                position = "auto";
                scale = 2;
            }
            {
                output = "DP-1";
                mode = "2560x1440@99.95Hz";
                position = "auto";
                scale = 1;
            }
            {
                output = "";
                mode = "preferred";
                position = "auto";
                scale = 1;
            }
        ];
        config.input = {
            touchpad = {
                scroll_factor = 0.3;
            };
        };
        device = [
            {
                name = "1343-touchpad";
                sensitivity = -0.5;
            }
            {
                name = "at-translated-set-2-keyboard";
                kb_options = "caps:escape";
            }
        ];
    };
}
