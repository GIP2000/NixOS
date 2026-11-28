{ inputs, m, ... }: {
    flake.darwinConfigurations.monogram = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = with m.darwin; [
            inputs.home-manager-stable.darwinModules.home-manager
            tui-cli
            monogram
            base-config
            openssh
        ];
    };
    flake.modules.darwin.monogram = { pkgs, ... }: {

        home-manager.sharedModules = with m.homeManager; [
            bluebubbles-server
            monogram
        ];

        services.tailscale.enable = true;
        networking = {
            hostName = "monogram";
            localHostName = "monogram";
            computerName = "monogram";
            wakeOnLan.enable = true;
        };

    };
    flake.modules.homeManager.monogram = { pkgs, ... }: {
        home = {
            username = "gip";
            homeDirectory = "/Users/gip";
            stateVersion = "26.05";
        };
    };

}
