# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
    config,
    lib,
    pkgs,
    ...
}: {
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
        ../../services/pi-hole.nix
        ../../services/tailscale.nix
    ];

    # Use the GRUB 2 boot loader.
    boot.loader.grub = {
        enable = true;
        device = "/dev/disk/by-id/wwn-0x6842b2b0653e890021c9a4d90ca3349d";
    };

    hardware.enableRedistributableFirmware = true;

    services.openssh.enable = true;

    users.users = let
        authorizedKeys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2tLbHGxTYI4Z4qFSiXFQFLlLVkfDDJQpTweLXZ2zNO gpress2222@gmail.com"
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfmSL1yGc9HdAOqFcDLDoWxKOAuGXcw2rlG5CmE2GNm gpress2222@gmail.com"
        ];
    in {
        root.openssh.authorizedKeys.keys = authorizedKeys;
        gip = {
            isNormalUser = true;
            description = "Gregory Presser";
            extraGroups = ["networkmanager" "wheel" "kvm"];
            shell = pkgs.zsh;
            openssh.authorizedKeys.keys = authorizedKeys;
        };
    };
    networking = {
        hostName = "doof";
        networkmanager.enable = true;

        interfaces.eno2.ipv4.addresses = [
            {
                address = "192.168.1.152";
                prefixLength = 24;
            }
        ];
    };

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
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
        git
        curl
        vim
        ghostty.terminfo
    ];

    system.stateVersion = "26.05";
}
