{
    pkgs,
    lib,
    ...
}: {
    imports = [
        ../../home-manager/programs/nvim.nix
        ../../home-manager/programs/shell.nix
    ];

    home = {
        username = "gip";
        homeDirectory = "/home/gip";
        stateVersion = "26.05";
    };
}
