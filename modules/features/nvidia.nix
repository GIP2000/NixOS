{ ... }: {
    flake.modules.nixos.nvidia = {
        hardware.graphics.enable = true;
        services.xserver.videoDrivers = [ "nvidia" ];
        boot.kernelParams = [ "nvidia-drm.modeset=1" ];
        hardware.nvidia = {
            open = false;
            modesetting.enable = true;
        };
    };
}
