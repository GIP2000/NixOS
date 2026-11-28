{ ... }: {
    flake.modules.nixos.one-password = {
        programs._1password.enable = true;
        programs._1password-gui.enable = true;
    };
}
