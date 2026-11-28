{ ... }: {
    _module.args.shared = {
        wallpaper =
            pkgs:
            "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/ScarletTree/contents/images/5120x2880.png";
    };
}
