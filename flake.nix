{
    description = "NixOS with home-manager btw";
    nixConfig.extra-experimental-features = [ "pipe-operators" ];
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        nixpkgs-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
        nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
        nix-darwin = {
            url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:denful/import-tree";

        # remove when my pr is merged in https://github.com/NixOS/nixpkgs/pull/590129
        nixpkgs-bluebubbles.url = "github:GIP2000/nixpkgs/bluebubbles-udpate-ffmpeg-kit-hash";
        bluebubbles-server = {
            url = "path:./flakes/bluebubbles-server";
            inputs.nixpkgs.follows = "nixpkgs-stable";
        };
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        home-manager-stable = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs-stable";
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
    outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);

}
