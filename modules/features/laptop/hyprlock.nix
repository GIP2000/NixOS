{ m, shared, ... }: {
    flake.modules.nixos.hyprlock = { pkgs, config, ... }: {
        security.pam.services.hyprlock.fprintAuth = config.security.pam.services.login.fprintAuth;

        home-manager.sharedModules = [ m.homeManager.hyprlock ];
    };
    flake.modules.homeManager.hyprlock =
        {
            pkgs,
            osConfig ? { },
            lib,
            ...
        }:
        let
            has-fprint = osConfig.security.pam.services.login.fprintAuth or false;
        in
        {
            programs.hyprlock = {
                enable = true;
                settings = {
                    auth = lib.mkIf has-fprint {
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
                            path = shared.wallpaper pkgs;
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
        };

}
