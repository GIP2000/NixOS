# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{ pkgs, ... }: {

    services.openssh = {
        enable = true;
        extraConfig = ''
            PasswordAuthentication no
            KbdInteractiveAuthentication no
            PermitRootLogin no
        '';
    };

    system.primaryuser = "gip";
    users.users = {
        gip = {
            description = "gregory presser";
            home = "/users/gip";
            shell = pkgs.zsh;
            openssh.authorizedkeys.keys = [
                "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaaia2tlbhgxtyi4z4qfsixfqflllvkfddjqptwelxz2zno gpress2222@gmail.com"
                "ssh-ed25519 aaaac3nzac1lzdi1nte5aaaailfmsl1ygc9hdaoqfcdldowxkoaugxcw2rlg5cme2gnm gpress2222@gmail.com"
            ];
        };
    };
    networking = {
        hostName = "monogram";
        localHostName = "monogram";
        computerName = "monogram";
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
        experimental-features = [
            "nix-command"
            "flakes"
            "pipe-operators"
        ];
    };

    # Allow unfree packages
    nixpkgs.hostPlatform = "aarch64-darwin";
    nixpkgs.config.allowUnfree = true;

    nixpkgs.overlays = [
        (final: prev: {
            llvmPackages_18 = prev.llvmPackages_18.overrideScope (
                llvmFinal: llvmPrev: {
                    compiler-rt-libc = llvmPrev.compiler-rt-libc.overrideAttrs (old: {
                        cmakeFlags = (old.cmakeFlags or [ ]) ++ [
                            (final.lib.cmakeBool "COMPILER_RT_BUILD_XRAY" false)
                            (final.lib.cmakeBool "COMPILER_RT_BUILD_LIBFUZZER" false)
                            (final.lib.cmakeBool "COMPILER_RT_BUILD_MEMPROF" false)
                            (final.lib.cmakeBool "COMPILER_RT_BUILD_ORC" false)
                        ];
                    });
                }
            );
        })
    ];

    # List packages installed in system profile.
    # You can use https://search.nixos.org/ to find more packages (and options).
    programs.zsh.enable = true;
    environment.systemPackages = with pkgs; [
        git
        curl
        vim
        ghostty-bin.terminfo
    ];

    system.stateVersion = 7;
}
