{ ... }: {
    flake.modules.homeManager.minecraft-client = { pkgs, ... }: {
        home.packages = [ pkgs.prismlauncher ];
    };
}
