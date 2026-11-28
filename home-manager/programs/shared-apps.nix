{
    pkgs,
    inputs,
    ...
}:
let
    whatsapp = inputs.helium.packages.x86_64-linux.helium-whatsapp;
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
        blueman
        playerctl
        pwvucontrol
        alsa-utils # audio command line utils
        whatsapp
        bluebubbles
        notion-app
        vlc
        ffmpeg
        opencode
        gnome-sound-recorder
        localsend
    ];
}
