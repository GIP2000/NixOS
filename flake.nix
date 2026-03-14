{
    description = "NixOS with home-manager btw";
    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
        home-manager.url = "github:nix-community/home-manager/release-25.11";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        nvf.url = "github:NotAShelf/nvf";
        nvf.inputs.nixpkgs.follows = "nixpkgs";
        firefox-addons = {
            url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        zen-browser = {
            url = "github:0xc000022070/zen-browser-flake";
            inputs = {
                nixpkgs.follows = "nixpkgs";
                home-manager.follows = "home-manager";
            };
        };
    };
    outputs = inputs @ {
        self,
        nixpkgs,
        home-manager,
        ...
    }: {
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {inherit inputs;};
            modules = [
                ./configuration.nix
                home-manager.nixosModules.home-manager
                {
                    home-manager.users.gip = import ./home.nix;
                    home-manager.extraSpecialArgs = {inherit inputs;};
                }
            ];
        };
    };
}
