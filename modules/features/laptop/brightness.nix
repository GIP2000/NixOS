{ m, ... }: {
    flake.modules.nixos.brightness = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [ brightnessctl ];
        home-manager.sharedModules = [ m.homeManager.brightness ];

    };
    flake.modules.homeManager.brightness =
        {
            pkgs,
            lib,
            hl ? null,
            ...
        }:
        {
            wayland.windowManager.hyprland.settings.bind =
                lib.mkIf hl != null [
                    {
                        _args = [
                            "XF86MonBrightnessUp"
                            (hl.exec "brightnessctl set +5%")
                            { repeating = true; }
                        ];
                    }
                    {
                        _args = [
                            "XF86MonBrightnessDown"
                            (hl.exec "brightnessctl set 5%-")
                            { repeating = true; }
                        ];
                    }
                ];

        };

}
