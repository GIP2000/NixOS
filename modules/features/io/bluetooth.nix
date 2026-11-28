{ m, ... }: {
    flake.modules.nixos.bluetooth = {
        services.blueman.enable = true;
        hardware.bluetooth.enable = true;
        home-manager.sharedModules = [ m.homeManager.bluetooth ];
    };
    flake.modules.homeManager.bluetooth = { pkgs, ... }: {
        home.packages = [ pkgs.blueman ];
    };

}
