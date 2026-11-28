{ ... }: {
    flake.modules.homeManager.hyprland-laptop = {
        wayland.windowManager.hyprland.settings = {
            monitor = [
                {
                    output = "eDP-1";
                    mode = "preferred";
                    position = "auto";
                    scale = 2;
                }
                {
                    output = "desc:ASUSTek COMPUTER INC PA278CFRV S5LMYX001888";
                    mode = "2560x1440@99.95Hz";
                    position = "auto";
                    scale = 1;
                }
                {
                    output = "";
                    mode = "highres";
                    position = "auto";
                    scale = 1;
                }
            ];
            config.input = {
                touchpad = {
                    scroll_factor = 0.3;
                };
            };
            device = [
                {
                    name = "1343-touchpad";
                    sensitivity = -0.5;
                }
            ];
        };
    };

}
