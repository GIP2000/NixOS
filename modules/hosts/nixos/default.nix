{ inputs, m, ... }: {
    flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
        modules = with m.nixos; [
            ./_hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            base-config
            io
            gui
            tui-cli
            greetd
            m.homeManager.agents
            gaming
        ];
    };
    flake.modules.nixos.nixos = { pkgs, ... }: {

        networking.hostName = "nixos";
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        system.stateVersion = "25.11";

    };
}
