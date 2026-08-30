{
    pkgs,
    inputs,
    ...
}: let
    whatsapp = inputs.helium.packages.x86_64-linux.helium-whatsapp;
    notion-app = inputs.helium.mkWebApp {
        name = "helium-notion";
        url = "https://app.notion.com/";
        desktopName = "Notion";
        icon = "Notion";
        comment = "Notion note taking applicaiton";
        categories = ["Office"];
    };
in {
    home.packages = with pkgs; [
        nemo
        discord
        spotify
        blueman
        playerctl
        pwvucontrol
        alsa-utils # audio command line utils
        whatsapp
        notion-app
        vlc
        ffmpeg
        opencode
        gnome-sound-recorder
        localsend
    ];
}
