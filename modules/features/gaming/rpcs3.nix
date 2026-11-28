{ m, ... }: {
    flake.modules.nixos.rpcs3 = { pkgs, ... }: {
        system.activationScripts.rpcs3DejaVu = {
            text = ''
                mkdir -p /usr/share/fonts/truetype/dejavu
                ln -sf ${pkgs.dejavu_fonts}/share/fonts/truetype/DejaVuSans.ttf \
                  /usr/share/fonts/truetype/dejavu/DejaVuSans.ttf
            '';
            deps = [ ];
        };

        home-manager.sharedModules = [ m.homeManager.rpcs3 ];

    };

    flake.modules.hoemManager.rpcs3 = { pkgs, ... }: {
        home.packages = [ pkgs.rpcs3 ];
    };
}
