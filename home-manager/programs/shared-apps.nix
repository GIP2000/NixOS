{
    pkgs,
    inputs,
    ...
}: {
    home.packages = with pkgs; [
        nemo
        discord
        spotify
        blueman
        playerctl
        pwvucontrol
        alsa-utils # audio command line utils
        inputs.helium.packages.x86_64-linux.helium-whatsapp
        vlc
        ffmpeg
        opencode
    ];
}
