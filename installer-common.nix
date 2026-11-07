{lib, ...}: {
    services.openssh = {
        enable = true;
        settings = {
            PermitRootLogin = "yes";
            PasswordAuthentication = true;
            PermitEmptyPasswords = "yes";
        };
    };

    security.pam.services.sshd.allowNullPassword = true;
    users.users.root.initialHashedPassword = lib.mkForce "";

    networking.hostName = "nixos-installer";

    services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
        publish = {
            enable = true;
            addresses = true;
        };
    };
}
