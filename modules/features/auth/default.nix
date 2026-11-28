# default.nix
{ lib, m, ... }:
let
    names =
        ./.
        |> builtins.readDir
        |> lib.filterAttrs (
            n: t: t == "regular" && lib.hasSuffix ".nix" n && n != "default.nix" && !(lib.hasPrefix "_" n)
        )
        |> builtins.attrNames
        |> map (lib.removeSuffix ".nix");
in
{
    flake.modules.nixos.auth = {
        # every sibling that defines a NixOS half
        imports = names |> lib.filter (n: m.nixos ? ${n}) |> map (n: m.nixos.${n});

        home-manager.sharedModules = [ m.homeManager.auth ];
    };

    flake.modules.homeManager.auth = {
        imports =
            names |> lib.filter (n: m.homeManager ? ${n} && !(m.nixos ? ${n})) |> map (n: m.homeManager.${n});
    };
}
