{ m, ... }: {
    flake.modules.nixos.kde-connect = { pkgs, ... }: {
        networking.firewall = rec {
            allowedTCPPortRanges = [
                {
                    from = 1714;
                    to = 1764;
                }
            ];
            allowedUDPPortRanges = allowedTCPPortRanges;
        };

        home-manager.sharedModules = [ m.homeManager.kde-connect ];
    };

    flake.modules.homeManager.kde-connect = { pkgs, ... }: {
        services.kdeconnect.enable = true;

    };

}
