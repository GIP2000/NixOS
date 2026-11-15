# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
    config,
    lib,
    pkgs,
    ...
}: {
    # imports = [
    #     # Include the results of the hardware scan.
    #     ../../services/tailscale.nix
    # ];

    services.openssh = {
        enable = true;
        extraConfig = ''
            PasswordAuthentication no
            KbdInteractiveAuthentication no
            PermitRootLogin no
        '';
    };

    system.primaryUser = "gip";
    users.users = {
        gip = {
            description = "Gregory Presser";
            shell = pkgs.zsh;
            openssh.authorizedKeys.keys = [
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2tLbHGxTYI4Z4qFSiXFQFLlLVkfDDJQpTweLXZ2zNO gpress2222@gmail.com"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfmSL1yGc9HdAOqFcDLDoWxKOAuGXcw2rlG5CmE2GNm gpress2222@gmail.com"
            ];
        };
    };
    networking = {
        hostName = "monogram";
        localHostName = "monogram";
        computerName = "monogram";
        networkmanager.enable = true;
        wakeOnLan.enable = true;
    };
    services.tailscale.enable = true;

    power = {
        sleep = {
            computer = "never";
            display = "never";
            harddisk = "never";
        };
        restartAfterPowerFailure = true;
        restartAfterFreeze = true;
    };

    system.defaults.loginwindow.GuestEnabled = false;

    # Set your time zone.
    time.timeZone = "America/New_York";

    home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
    };

    nix.settings = {
        experimental-features = ["nix-command" "flakes" "pipe-operators"];
    };

    # Allow unfree packages
    nixpkgs.hostPlatform = "aarch64-darwin";
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
        git
        curl
        vim
        ghostty-bin.terminfo
    ];

    system.stateVersion = "26.05";
}
