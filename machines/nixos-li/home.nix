{
    pkgs,
    lib,
    ...
}: {
    imports = [
        ../../home-manager/programs/nvim.nix
        ../../home-manager/programs/shell.nix
        ../../home-manager/programs/desktop.nix
        ../../home-manager/programs/browser.nix
        ../../home-manager/programs/shared-apps.nix
    ];

    home = {
        username = "gip";
        homeDirectory = "/home/gip";
        stateVersion = "25.11";
        packages = with pkgs; [
            prismlauncher
            (pkgs.rpcs3.overrideAttrs (prev: {
                cmakeFlags = prev.cmakeFlags ++ [(lib.cmakeBool "BUILD_SHARED_LIBS" false)];
            }))
            #   (symlinkJoin {
            #       # this forces sioyek to run on my IGPU because its messed up on Nvidia
            #       name = "sioyek";
            #       paths = [sioyek];
            #       buildInputs = [makeWrapper];
            #       postBuild = ''
            #           wrapProgram $out/bin/sioyek \
            #             --set __EGL_VENDOR_LIBRARY_FILENAMES ${mesa}/share/glvnd/egl_vendor.d/50_mesa.json
            #       '';
            #   })
            davinci-resolve
        ];
    };

    wayland.windowManager.hyprland.settings = {
        config.misc = {
            vrr = 2;
        };

        monitor = [
            {
                output = "DP-3";
                mode = "1920x1080@144.00Hz";
                position = "0x0";
                scale = 1;
            }
        ];
        window_rule = [
            # novrr on helium
            # vrr has issues with helium (I think all of chromium) and nvidia on wayland
            {
                match = {
                    class = "^helium$";
                };
                no_vrr = true;
            }

            {
                match = {
                    initial_title = ".*The Simpsons™ Game.*";
                };
                no_vrr = true;
            }
        ];
    };
}
