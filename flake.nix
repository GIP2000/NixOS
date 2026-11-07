{
    description = "NixOS with home-manager btw";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nixos-hardware = {
            url = "github:NixOS/nixos-hardware/master";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nvf.url = "github:NotAShelf/nvf";
        llm-agents = {
            url = "github:numtide/llm-agents.nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        helium = {
            url = "path:./flakes/helium";
            inputs = {
                nixpkgs.follows = "nixpkgs";
            };
        };
        noctalia = {
            url = "github:noctalia-dev/noctalia";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    outputs = inputs @ {
        self,
        nixpkgs,
        nixpkgs-stable,
        home-manager,
        nixos-hardware,
        ...
    }: {
        nixosConfigurations.nixos-framework = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
                ./machines/nixos-framework/configuration.nix
                home-manager.nixosModules.home-manager
                nixos-hardware.nixosModules.framework-intel-core-ultra-series3
                {
                    home-manager.users.gip = import ./machines/nixos-framework/home.nix;
                    home-manager.extraSpecialArgs = {
                        inherit inputs;
                        inherit self;
                    };
                }
            ];
        };

        nixosConfigurations.nixos-li = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
                ./machines/nixos-li/configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager.users.gip = import ./machines/nixos-li/home.nix;
                    home-manager.extraSpecialArgs = {
                        inherit inputs;
                        inherit self;
                    };
                }
            ];
        };

        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
                ./machines/nixos/configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager.users.gip = import ./machines/nixos/home.nix;
                    home-manager.extraSpecialArgs = {
                        inherit inputs;
                        inherit self;
                    };
                }
            ];
        };
        nixosConfigurations.installer = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                "${nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                ./installer-common.nix
            ];
        };

        nixosConfigurations.netboot = nixpkgs-stable.lib.nixosSystem {
            system = "x86_64-linux";
            modules = [
                "${nixpkgs-stable}/nixos/modules/installer/netboot/netboot-minimal.nix"
                ./installer-common.nix
            ];
        };
        # nixosConfigurations.installer = nixpkgs-stable.lib.nixosSystem {
        #     system = "x86_64-linux";
        #     modules = [
        #         "${nixpkgs-stable}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        #         ({
        #             pkgs,
        #             lib,
        #             ...
        #         }: {
        #             services.openssh = {
        #                 enable = true;
        #                 settings = {
        #                     PermitRootLogin = "yes";
        #                     PasswordAuthentication = true;
        #                     PermitEmptyPasswords = "yes";
        #                 };
        #             };
        #
        #             # Let PAM accept empty passwords for sshd
        #             security.pam.services.sshd.allowNullPassword = true;
        #
        #             # Root has an empty password (the installer's default, made explicit)
        #             users.users.root.initialHashedPassword = lib.mkForce "";
        #
        #             networking.hostName = "nixos-installer";
        #
        #             services.avahi = {
        #                 enable = true;
        #                 nssmdns4 = true;
        #                 openFirewall = true;
        #                 publish = {
        #                     enable = true;
        #                     addresses = true;
        #                 };
        #             };
        #         })
        #     ];
        # };
    };
}
