{ inputs, m, ... }: {
    flake.nixosConfigurations.nixos-li = inputs.nixpkgs.lib.nixosSystem {
        modules = with m.nixos; [
            ./_hardware-configuration.nix
            inputs.home-manager.nixosModules.home-manager
            base-config
            io
            gui
            tui-cli
            greetd
            gaming
            nvidia
            nixos-li
        ];
    };
    flake.modules.nixos.nixos-li = { pkgs, ... }: {

        networking.hostName = "nixos-li";

        boot.loader.grub = {
            enable = true;
            device = "/dev/sda";
            useOSProber = true;
        };
        boot.loader.efi.canTouchEfiVariables = true;

        home-manager.sharedModules = with m.homeManager; [
            nixos-li
            agents
        ];

        home-manager.users.gip.home.stateVersion = "25.11";
        system.stateVersion = "25.11";

    };
    flake.modules.homeManager.nixos-li = { lib, ... }: {

        programs.ghostty.settings.font-size = lib.mkForce 14;

        wayland.windowManager.hyprland.settings = {
            config.misc = {
                vrr = 2;
            };

            monitor = [
                {
                    output = "DP-3";
                    mode = "1920x1080@144.00Hz";
                    position = "0x0";
                    scale = 1;
                }
            ];
            window_rule = [
                # novrr on helium
                # vrr has issues with helium (I think all of chromium) and nvidia on wayland
                {
                    match = {
                        class = "^helium$";
                    };
                    no_vrr = true;
                }

                {
                    match = {
                        initial_title = ".*The Simpsons™ Game.*";
                    };
                    no_vrr = true;
                }
            ];
        };

    };
}
