{pkgs, ...}: {
    home.packages = with pkgs; [
        discord
        spotify
        blueman
        playerctl
        pwvucontrol
        alsa-utils # audio command line utils
        # sioyek
    ];
}
