{ inputs, m, ... }: {
    flake.nixosConfigurations.nixos-framework = inputs.nixpkgs.lib.nixosSystem {
        modules = with m.nixos; [
            ./_hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            base-config
            io
            gui
            tui-cli
            auth
            m.homeManager.agents
            laptop
            m.homeManager.minecraft-client
            m.homeManager.work
            nixos-framework
            battery
        ];
    };
    flake.modules.nixos.nixos-framework = { pkgs, ... }: {

        networking.hostName = "nixos-framework";
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;
        boot.kernelPackages = pkgs.linuxPackages_latest;
        services.tailscale.enable = true;
        services.fwupd.enable = true;
        system.stateVersion = "25.11";

        home-manager.sharedModules = [ m.homeManager.nixos-framework ];

    };
    flake.modules.homeManager.nixos-framework = { lib, ... }: {
        programs.ghostty.settings.font-size = lib.mkForce 13;
    };

}
