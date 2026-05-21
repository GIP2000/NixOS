{
    inputs,
    config,
    ...
}: {
    home.packages = [
        inputs.helium.packages.x86_64-linux.helium-browser
    ];

    programs = {
        # helium doesn't have a DRM yet so this is so I can watch netflix
        firefox = {
            enable = true;
            configPath = "${config.xdg.configHome}/mozilla/firefox";
        };
    };
}
