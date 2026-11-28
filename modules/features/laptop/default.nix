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
    flake.modules.nixos.laptop = {
        # every sibling that defines a NixOS half
        imports = names |> lib.filter (n: m.nixos ? ${n}) |> map (n: m.nixos.${n});

        # HM-only siblings; the others already attach their HM half themselves
        home-manager.sharedModules = [ m.homeManager.laptop ];
    };

    flake.modules.homeManager.laptop = {
        imports =
            names |> lib.filter (n: m.homeManager ? ${n} && !(m.nixos ? ${n})) |> map (n: m.homeManager.${n});
    };
}
