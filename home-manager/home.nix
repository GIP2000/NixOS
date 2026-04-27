{pkgs, ...}: {
    imports = [
        ./programs/nvim.nix
        ./programs/shell.nix
        ./programs/desktop.nix
        ./programs/browser.nix
        ./programs/shared-apps.nix
    ];

    home = {
        username = "gip";
        homeDirectory = "/home/gip";
        stateVersion = "25.11";
        packages = with pkgs; [
            prismlauncher
        ];

        pointerCursor = {
            gtk.enable = true;
            hyprcursor.enable = true;
            name = "Bibata-Modern-Classic";
            package = pkgs.bibata-cursors;
            size = 24;
        };
    };

    wayland.windowManager.hyprland.settings = {
        misc = {
            vrr = 2;
        };
        monitor = "DP-3,2560x1440@143.86Hz,0x0,1";
    };
}
