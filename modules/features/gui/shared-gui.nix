{ inputs, m, ... }: {

    flake.modules.nixos.shared-gui = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
            gnome-themes-extra
        ];

        home-manager.sharedModules = [ m.homeManager.shared-gui ];
    };

    flake.modules.homeManager.shared-gui =
        { pkgs, ... }:
        let

            bluebubbles =
                (import inputs.nixpkgs-bluebubbles {
                    system = pkgs.stdenv.hostPlatform.system;
                    config.allowUnfree = pkgs.config.allowUnfree;
                }).bluebubbles;
            notion-app = inputs.helium.mkWebApp {
                name = "helium-notion";
                url = "https://app.notion.com/";
                desktopName = "Notion";
                icon = "Notion";
                comment = "Notion note taking applicaiton";
                categories = [ "Office" ];
            };
        in
        {
            imports = with m.nixos m.homeManager; [
                firefox
                localsend
                kde-connect
                sioyek
            ];

            home.packages = with pkgs; [
                nemo
                discord
                element-desktop
                spotify
                blueman
                pwvucontrol
                whatsapp
                bluebubbles
                notion-app
                vlc
                gnome-sound-recorder
                localsend
                kitty
            ];

        };

}
