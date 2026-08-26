{
    pkgs,
    inputs,
    ...
}: let
    whatsapp = inputs.helium.packages.x86_64-linux.helium-whatsapp;
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
        vlc
        ffmpeg
        opencode
        gnome-sound-recorder
        localsend
    ];
}
