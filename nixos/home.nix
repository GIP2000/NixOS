{
    pkgs,
    lib,
    ...
}: {
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
            rpcs3
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
        config.misc = {
            vrr = 2;
        };
        monitor = [
            {
                output = "DP-3";
                mode = "2560x1440@143.86Hz";
                position = "0x0";
                scale = 1;
            }
            {
                output = "HDMI-A-2";
                mode = "2560x1440@143.99899Hz";
                position = "-2560x0";
                scale = 1;
            }
        ];

        on = [
            {
                _args = [
                    "hyprland.start"
                    (lib.generators.mkLuaInline ''
                        function()
                            hl.dispatch(hl.dsp.workspace.move({
                                workspace = 10,
                                monitor = DP-3,
                            }));

                            hl.dispatch(hl.dsp.focus({
                                workspace = 10,
                                on_current_monitor = false,
                            }));
                        end
                    '')
                ];
            }
        ];
    };
}
