{
    inputs,
    config,
    ...
}: let
    helium = inputs.helium.packages.x86_64-linux.helium-browser;
in {
    home.packages = [
        helium
    ];

    xdg.mimeApps = {
        enable = true;
        defaultApplications = {
            "text/html" = ["helium-browser.desktop"];
            "x-scheme-handler/http" = ["helium-browser.desktop"];
            "x-scheme-handler/https" = ["helium-browser.desktop"];
            "x-scheme-handler/about" = ["helium-browser.desktop"];
            "x-scheme-handler/unknown" = ["helium-browser.desktop"];
        };
    };

    programs = {
        # helium doesn't have a DRM yet so this is so I can watch netflix
        firefox = {
            enable = true;
            configPath = "${config.xdg.configHome}/mozilla/firefox";
        };
    };
}
