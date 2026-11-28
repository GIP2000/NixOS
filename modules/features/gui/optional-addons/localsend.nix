{ m, ... }: {
    flake.modules.nixos.localsend = { pkgs, ... }: {
        networking.firewall = {
            allowedTCPPorts = [ 53317 ];
            allowedUDPPorts = [ 53317 ];
        };

        home-manager.sharedModules = [ m.homeManager.localsend ];
    };

    flake.modules.homeManager.localsend = { pkgs, ... }: {
        home.packages = [ pkgs.localsend ];

    };

}
