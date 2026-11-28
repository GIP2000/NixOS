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

    # `m.darwin` only exists if some file defines a darwin module, so guard the lookup
    has = class: n: (m.${class} or { }) ? ${n};
    pick = class: names |> lib.filter (has class) |> map (n: m.${class}.${n});
in
{
    flake.modules.nixos.tui-cli = {
        # every sibling that defines a NixOS half
        imports = pick "nixos";

        # HM-only siblings; the others already attach their HM half themselves
        home-manager.sharedModules = [ m.homeManager.tui-cli ];
    };

    flake.modules.darwin.tui-cli = {
        # every sibling that defines a darwin half
        imports = pick "darwin";

        home-manager.sharedModules = [ m.homeManager.tui-cli ];
    };

    flake.modules.homeManager.tui-cli = {
        # siblings with an HM half and no system half on either platform
        imports =
            names
            |> lib.filter (n: has "homeManager" n && !(has "nixos" n) && !(has "darwin" n))
            |> map (n: m.homeManager.${n});
    };
}
