{ inputs, m, ... }: {
    flake.nixosConfigurations.nixos-framework = inputs.nixpkgs.lib.nixosSystem {
        modules = with m.nixos; [
            ./_hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            inputs.nixos-hardware.nixosModules.framework-intel-core-ultra-series3
            base-config
            io
            gui
            tui-cli
            auth
            laptop
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

        home-manager.users.gip.home.stateVersion = "25.11";
        home-manager.sharedModules = with m.homeManager; [
            nixos-framework
            minecraft-client
            work
            agents
        ];

    };
    flake.modules.homeManager.nixos-framework = { lib, ... }: {
        programs.ghostty.settings.font-size = lib.mkForce 13;
    };

}
