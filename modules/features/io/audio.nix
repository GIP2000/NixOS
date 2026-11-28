{ m, ... }: {
    flake.modules.nixos.audio = {
        services.pipewire = {
            enable = true;
            wireplumber = {
                enable = true;
                extraConfig = {
                    "move-streams" = {
                        "wireplumber.settings" = {
                            "move-streams-on-default-sink-change" = true;
                        };
                    };
                };
            };
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
        };

        boot.extraModprobeConfig = ''
            options snd-hda-intel power_save=0 power_save_controller=N
        '';

        home-manager.sharedModules = [ m.homeManager.audio ];
    };

    flake.modules.homeManager.audio = { pkgs, ... }: {
        home.packages = with pkgs; [
            playerctl
            pwvucontrol
            alsa-utils
        ];

    };

}
