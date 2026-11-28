{ m, ... }: {
    flake.modules.nixos.firefox = {
        environment.sessionVariables = {
            MOZ_ENABLE_WAYLAND = "1";
        };
        home-manager.sharedModules = [ m.homeManager.firefox ];
    };
    flake.modules.homeManager.firefox = { pkgs, ... }: {
        home.packages = [ pkgs.firefox ];
    };

}
