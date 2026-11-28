{ inputs, m, ... }: {
    flake.nixosConfigurations.nixos-li = inputs.nixpkgs.lib.nixosSystem {
        modules = with m.nixos; [
            ./_hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            base-config
            io
            gui
            tui-cli
            greetd
            agents
            gaming
        ];
    };
    flake.modules.nixos.nixos-li = { pkgs, ... }: {

        networking.hostName = "nixos-li";

        boot.loader.grub = {
            enable = true;
            device = "/dev/sda";
            useOSProber = true;
        };
        boot.loader.efi.canTouchEfiVariables = true;

        system.stateVersion = "25.11";

    };
}
