{ ... }: {
    flake.modules.nixos.steam = { pkgs, ... }: {
        hardware.steam-hardware.enable = true;

        programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
        };
    };

}
