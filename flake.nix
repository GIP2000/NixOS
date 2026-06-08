{
    description = "NixOS with home-manager btw";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

        nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        nvf = {
            url = "github:NotAShelf/nvf";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        helium = {
            url = "path:./flakes/helium";
            inputs = {
                nixpkgs.follows = "nixpkgs";
            };
        };
    };
    outputs = inputs @ {
        self,
        nixpkgs,
        home-manager,
        ...
    }: {
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
    };
}
