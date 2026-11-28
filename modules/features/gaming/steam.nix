{ ... }: {
    flake.modules.nixos.steeam = { pkgs, ... }: {
        hardware.steam-hardware.enable = true;

        programs.steam = {
            enable = true;
            gamescopeSession.enable = true;
        };
    };

}
