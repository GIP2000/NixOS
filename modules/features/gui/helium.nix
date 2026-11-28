{ inputs, m, ... }: {
    flake.modules.nixos.helium = { pkgs, ... }: {
        security.wrappers.chrome-sandbox = {
            setuid = true;
            owner = "root";
            group = "root";
            source = "${pkgs.chromium.sandbox}/bin/__chromium-suid-sandbox";
        };

        home-manager.sharedModules = [ m.homeManager.helium ];
    };
    flake.modules.homeManager.helium = { pkgs, ... }: {

        home.packages = [
            inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium-browser
        ];

        xdg.mimeApps = {
            enable = true;
            defaultApplications = {
                "text/html" = [ "helium-browser.desktop" ];
                "x-scheme-handler/http" = [ "helium-browser.desktop" ];
                "x-scheme-handler/https" = [ "helium-browser.desktop" ];
                "x-scheme-handler/about" = [ "helium-browser.desktop" ];
                "x-scheme-handler/unknown" = [ "helium-browser.desktop" ];
            };
        };

    };
}
