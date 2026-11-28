{ ... }: {
    flake.modules.nixos.greetd =
        {
            pkgs,
            lib,
            config,
            ...
        }:
        {
            security.pam.services.greetd.fprintAuth = config.security.pam.services.login.fprintAuth;
            services.greetd = {
                enable = true;
                settings.default_session = {
                    command =
                        if !config.programs.hyprland.enable then
                            "${pkgs.tuigreet}/bin/tuigreet --time --remember"
                        else
                            "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
                    user = "greeter";
                };
            };

        };
}
