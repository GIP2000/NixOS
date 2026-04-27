{pkgs, ...}: {
    home.packages = with pkgs; [
        firefox
        discord
        spotify
        blueman
        playerctl
        pwvucontrol
        alsa-utils # audio command line utils
    ];
}
