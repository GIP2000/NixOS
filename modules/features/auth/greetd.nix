{ ... }: {
    flake.modules.nixos.greetd =
        {
            pkgs,
            lib,
            config,
            hl ? null,
            ...
        }:
        {
            security.pam.services.geetd.fprintAuth = config.security.pam.services.login.fprintAuth;
            services.greetd = {
                enable = true;
                settings.default_session = {
                    command =
                        if hl == null then
                            "${pkgs.tuigreet}/bin/tuigreet --time --remember"
                        else
                            "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
                    user = "greeter";
                };
            };

        };
}
