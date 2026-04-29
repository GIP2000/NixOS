{pkgs, ...}: {
    imports = [
        ../home-manager/programs/nvim.nix
        ../home-manager/programs/shell.nix
        ../home-manager/programs/desktop.nix
        ../home-manager/programs/browser.nix
        ../home-manager/programs/shared-apps.nix
    ];

    home = {
        username = "gip";
        homeDirectory = "/home/gip";
        stateVersion = "25.11";
        packages = with pkgs; [
            prismlauncher
            (symlinkJoin {
                # this forces sioyek to run on my IGPU because its messed up on Nvidia
                name = "sioyek";
                paths = [sioyek];
                buildInputs = [makeWrapper];
                postBuild = ''
                    wrapProgram $out/bin/sioyek \
                      --set __EGL_VENDOR_LIBRARY_FILENAMES ${mesa}/share/glvnd/egl_vendor.d/50_mesa.json
                '';
            })
        ];
    };

    wayland.windowManager.hyprland.settings = {
        misc = {
            vrr = 2;
        };
        monitor = "DP-3,2560x1440@143.86Hz,0x0,1";
    };
}
