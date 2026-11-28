{ ... }:
let
    common = { pkgs, ... }: {
        users.users.gip.description = "Gregory Presser";
        time.timeZone = "America/New_York";

        home-manager = {
            useUserPackages = true;
            useGlobalPkgs = true;
            backupFileExtension = "backup";
            users.gip = { };
        };

        environment.systemPackages = with pkgs; [
            vim
        ];

        nix.settings = {
            experimental-features = [
                "nix-command"
                "flakes"
                "pipe-operators"
            ];
        };

    };
in
{
    flake.modules.darwin.base-config =
        { pkgs, ... }:
        {
            imports = [ common ];

            system.primaryuser = "gip";
            users.users = {
                gip = {
                    home = "/Users/gip";
                };
            };

            power = {
                sleep = {
                    computer = "never";
                    display = "never";
                    harddisk = "never";
                };
                restartAfterPowerFailure = true;
                restartAfterFreeze = true;
            };

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
            system.defaults.loginwindow.GuestEnabled = false;

            system.stateVersion = 7;
        };
    flake.modules.nixos.base-config =
        { pkgs, ... }:
        {

            imports = [ common ];
            programs.nix-ld.enable = true;
            users.users.gip = {
                isNormalUser = true;
                extraGroups = [
                    "networkmanager"
                    "wheel"
                    "kvm"
                ];
            };

            i18n.defaultLocale = "en_US.UTF-8";

            i18n.extraLocaleSettings = {
                LC_ADDRESS = "en_US.UTF-8";
                LC_IDENTIFICATION = "en_US.UTF-8";
                LC_MEASUREMENT = "en_US.UTF-8";
                LC_MONETARY = "en_US.UTF-8";
                LC_NAME = "en_US.UTF-8";
                LC_NUMERIC = "en_US.UTF-8";
                LC_PAPER = "en_US.UTF-8";
                LC_TELEPHONE = "en_US.UTF-8";
                LC_TIME = "en_US.UTF-8";
            };

            services.xserver.xkb = {
                layout = "us";
                variant = "";
            };
            boot.tmp.cleanOnBoot = true;

            fonts.packages = with pkgs; [
                noto-fonts
                noto-fonts-cjk-sans
                noto-fonts-color-emoji

                adwaita-fonts
                nerd-fonts.jetbrains-mono
                dejavu_fonts
            ];

            environment.systemPackages = with pkgs; [
                wget
                gparted
            ];

            nixpkgs.config.allowUnfree = true;
            nix.settings = {
                extra-substituters = [ "https://noctalia.cachix.org" ];
                extra-trusted-public-keys = [
                    "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
                ];
            };
        };
}
