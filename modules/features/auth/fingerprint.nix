{ ... }: {
    flake.modules.nixos.fingerprint = {
        security.pam.services = {
            login.fprintAuth = true;
            sudo.fprintAuth = true;
        };
    };
}
