{ ... }: {
    flake.modules.homeManager.ghostty = {
        programs.ghostty = {
            enable = true;
            settings = {
                font-size = 20;
                window-padding-x = 0;
                window-padding-y = 0;
                window-padding-balance = true;
            };
        };
    };

}
