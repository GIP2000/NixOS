{ inputs, m, ... }: {
    flake.nixosConfigurations.nixos = inputs.nixpkgs.lib.nixosSystem {
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
            nixos
        ];
    };
    flake.modules.nixos.nixos = { pkgs, ... }: {

        networking.hostName = "nixos";
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        home-manager.sharedModules = with m.homeManager; [
            nixos
            agents
        ];

        home-manager.users.gip.home.stateVersion = "25.11";
        system.stateVersion = "25.11";

    };
    flake.modules.homeManager.nixos = { lib, ... }: {

        wayland.windowManager.hyprland.settings = {
            config.misc = {
                vrr = 2;
            };
            monitor = [
                {
                    output = "DP-3";
                    mode = "2560x1440@143.86Hz";
                    position = "0x0";
                    scale = 1;
                }
                {
                    output = "HDMI-A-2";
                    mode = " 2560x1440@144.00";
                    position = "+2560x0";
                    scale = 1;
                    transform = 3;
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

            on = [
                {
                    _args =
                        let
                            mkLuaInline = lib.generators.mkLuaInline;
                        in
                        [
                            "monitor.added"
                            (mkLuaInline ''
                                function(monitor)
                                    if not monitor.name == "DP-3" then
                                        return;
                                    end


                                    hl.dispatch(hl.dsp.focus({
                                        workspace = "10",
                                        on_current_monitor = true,
                                    }));


                                    hl.dispatch(hl.dsp.workspace.move({
                                        workspace = "10",
                                        monitor = "DP-3",
                                        follow = true,
                                    }));


                                end
                            '')
                        ];
                }
            ];
        };

    };
}
