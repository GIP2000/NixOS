{ inputs, m, ... }: {

    flake.modules.nixos.shared-gui = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            adwaita-icon-theme
            gnome-themes-extra
        ];
        imports = with m.nixos; [
            firefox
            localsend
            kde-connect
        ];

        home-manager.sharedModules = [
            m.homeManager.shared-gui
            m.homeManager.sioyek
        ];
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
            home.packages = with pkgs; [
                nemo
                discord
                element-desktop
                spotify
                inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.helium-whatsapp
                bluebubbles
                notion-app
                vlc
                gnome-sound-recorder
                kitty
            ];

        };

}
