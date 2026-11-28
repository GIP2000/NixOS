{ m, ... }: {
    flake.module.nixos.firefox = {
        environment.sessionVariables = {
            MOZ_ENABLE_WAYLAND = "1";
        };
        home-manager.sharedModules = [ m.homeManager.firefox ];
    };
    flake.module.homeManager.firefox = { pkgs, ... }: {
        home.packages = [ pkgs.firefox ];
    };

}
