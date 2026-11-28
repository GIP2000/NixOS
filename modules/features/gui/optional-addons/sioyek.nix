{ ... }: {
    flake.modules.homeManager.sioyek =
        {
            pkgs,
            osConfig ? { },
            ...
        }:
        {
            home.packages =
                with pkgs;
                let
                    has-nvidia = builtins.elem "nvidia" osConfig.services.xserver.videoDrivers;
                    sioyek-wrapped =
                        if (has-nvidia) then
                            (symlinkJoin {
                                # this forces sioyek to run on my IGPU because its messed up on Nvidia
                                name = "sioyek";
                                paths = [ sioyek ];
                                buildInputs = [ makeWrapper ];
                                postBuild = ''
                                    wrapProgram $out/bin/sioyek \
                                      --set __EGL_VENDOR_LIBRARY_FILENAMES ${mesa}/share/glvnd/egl_vendor.d/50_mesa.json
                                '';
                            })
                        else
                            pkgs.sioyek;
                in
                [
                    sioyek-wrapped
                ];

        };

}
