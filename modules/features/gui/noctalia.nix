{
    inputs,
    m,
    shared,
    ...
}:
{

    flake.modules.nixos.noctalia = { ... }: {
        services.gnome.gnome-keyring.enable = true;
        security.pam.services.login.enableGnomeKeyring = true;

        # I don't know if this is requried still

        nix.settings = {
            extra-substituters = [ "https://noctalia.cachix.org" ];
            extra-trusted-public-keys = [
                "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            ];
        };
        programs.dconf.enable = true;
        home-manager.sharedModules = [ m.homeManager.noctalia ];
    };
    flake.modules.homeManager.noctalia =
        {
            pkgs,
            lib,
            hl ? null,
            ...
        }:
        let
            wallpaper = shared.wallpaper pkgs;

        in
        {
            imports = [
                inputs.noctalia.homeModules.default
            ];

            programs.noctalia = {
                enable = true;

                settings = {
                    wallpaper = {
                        enabled = true;
                        default.path = "${wallpaper}";
                    };
                    theme = {
                        builtin = "Catppuccin";
                        mode = "dark";
                        source = "wallpaper";
                    };
                    bar = {
                        default = {
                            center = [ "group:g1" ];
                            end = [
                                "media"
                                "clipboard"
                                "network"
                                "bluetooth"
                                "volume"
                                "brightness"
                                "battery"
                                "control-center"
                                "session"
                            ];
                            start = [ "workspaces" ];
                            capsule_group = [
                                {
                                    accordion = false;
                                    accordion_direction = "end";
                                    enabled = true;
                                    fill = "surface_variant";
                                    id = "g1";
                                    members = [
                                        "weather"
                                        "clock"
                                    ];
                                    opacity = 1.0;
                                    padding = 6.0;
                                }
                            ];
                        };
                    };

                    desktop_widgets.enabled = false;
                    location.auto_locate = true;
                    lockscreen_widgets.enabled = false;
                    osd.enabled = false;
                    calendar = {
                        event_time_format = "%I:%M %p";
                    };

                    weather.unit = "imperial";
                    widget = {
                        brightness.show_label = false;
                        clock.format = "{:%a %e %b | %I:%M %p}";
                        control-center.glyph = "function";
                        media = {
                            album_art_only = true;
                            art_size = 20;
                            hide_when_no_media = true;
                        };
                        network.show_label = false;
                        volume.show_label = false;
                    };
                };
            };

            wayland.windowManager.hyprland.settings = lib.mkIf (hl != null) {
                bind = [
                    {
                        _args = [
                            "SUPER + Space"
                            (hl.exec "noctalia msg panel-toggle launcher")
                        ];
                    }
                ];

                on = [
                    {
                        _args =
                            let
                                mkLuaInline = lib.generators.mkLuaInline;
                            in
                            [
                                "hyprland.start"
                                (mkLuaInline ''
                                    function()
                                        hl.exec_cmd("noctalia")
                                    end'')
                            ];
                    }
                ];
            };
        };
}
