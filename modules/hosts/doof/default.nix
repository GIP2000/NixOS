{ inputs, m, ... }: {
    flake.nixosConfigurations.doof = inputs.nixpkgs.lib.nixosSystem {
        modules = with m.nixos; [
            ./_hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            base-config
            io
            tui-cli
            greetd
            server
        ];
    };
    flake.modules.nixos.doof = { pkgs, ... }: {
        networking = {
            nat = {
                enable = true;
                internalInterfaces = [ "ve-+" ];
                externalInterface = "eno1";
            };
            hostName = "doof";
            networkmanager = {
                enable = true;
                unmanaged = [ "interface-name:ve-*" ];

            };

            interfaces.eno2.ipv4.addresses = [
                {
                    address = "192.168.1.152";
                    prefixLength = 24;
                }
            ];
        };

        boot.loader.grub = {
            enable = true;
            device = "/dev/disk/by-id/wwn-0x6842b2b0653e890021c9a4d90ca3349d";
        };

        system.stateVersion = "26.05";

    };
}
