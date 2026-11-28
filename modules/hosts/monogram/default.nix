{ inputs, m, ... }: {
    flake.darwinConfigurations.monogram = inputs.nix-darwin.lib.darwinSystem {
        modules = with m.darwin; [
            inputs.home-manager.nixosModules.home-manager
            tui-cli
            m.homeManager.bluebubbles-server
        ];
    };
    flake.modules.darwin.monogram = { pkgs, ... }: {
        services.tailscale.enable = true;
        networking = {
            hostName = "monogram";
            localHostName = "monogram";
            computerName = "monogram";
            wakeOnLan.enable = true;
        };

    };
}
