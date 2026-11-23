{
    description = "Blue Bubbles Server";
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    outputs = {
        self,
        nixpkgs,
    }: let
        system = "aarch64-darwin";
        pkgs = import nixpkgs {inherit system;};
        version = "1.9.12";
        hash = "sha256-aFipFOPS5/1Asez10k6keJ6g4zr2s60r8alA4JCr/1c=";
    in {
        packages.${system}.bluebubbles-server = pkgs.stdenvNoCC.mkDerivation {
            pname = "bluebubbles-server";
            inherit version;
            src = pkgs.fetchurl {
                url = "https://github.com/BlueBubblesApp/bluebubbles-server/releases/download/v${version}/BlueBubbles-${version}.dmg";
                inherit hash;
            };
            nativeBuildInputs = [pkgs._7zz];
            unpackPhase = ''
                runHook preUnpack
                7zz x -snld $src
                runHook postUnpack
            '';

            sourceRoot = ".";

            installPhase = ''
                runHook preInstall
                mkdir -p $out/Applications
                cp -R BlueBubbles.app $out/Applications/
                runHook postInstall
            '';
            dontFixup = true;

            meta = {
                description = "Blue Bubbles Server";
                homepage = "https://bluebubbles.app";
                platforms = pkgs.lib.platforms.darwin;
            };
        };
    };
}
