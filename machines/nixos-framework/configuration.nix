# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: {
    imports = [
        # Include the results of the hardware scan.
        ./hardware-configuration.nix
    ];

    hardware.graphics.enable = true;

    hardware.bluetooth.enable = true;

    environment.sessionVariables = {
        MOZ_ENABLE_WAYLAND = "1";
    };

    boot.tmp.cleanOnBoot = true;

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    security.wrappers.chrome-sandbox = {
        setuid = true;
        owner = "root";
        group = "root";
        source = "${pkgs.chromium.sandbox}/bin/__chromium-suid-sandbox";
    };
    security.pam.services = {
        login.fprintAuth = true;
        sudo.fprintAuth = true;
        hyprlock.fprintAuth = false;
        greetd.fprintAuth = true;
    };

    networking.hostName = "nixos-framework"; # Define your hostname.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Enable networking
    networking.networkmanager.enable = true;

    # This is the ports for KDEConnect
    networking.firewall = rec {
        allowedTCPPortRanges = [
            {
                from = 1714;
                to = 1764;
            }
        ];
        allowedUDPPortRanges = allowedTCPPortRanges;
    };
    # Set your time zone.
    time.timeZone = "America/New_York";

    # Select internationalisation properties.
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

    # Configure keymap in X11
    services.xserver.xkb = {
        layout = "us";
        variant = "";
    };

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
    services.fwupd.enable = true;

    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji

        adwaita-fonts
        nerd-fonts.jetbrains-mono
        dejavu_fonts
    ];

    # Define a user account. Don't forget to set a password with ‘passwd’.

    programs.nix-ld.enable = true;
    programs.zsh.enable = true;
    programs._1password.enable = true;
    programs._1password-gui.enable = true;
    users.users.gip = {
        isNormalUser = true;
        description = "Gregory Presser";
        extraGroups = ["networkmanager" "wheel" "kvm"];
        shell = pkgs.zsh;
    };

    home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;
        backupFileExtension = "backup";
    };

    nix.settings = {
        experimental-features = ["nix-command" "flakes" "pipe-operators"];
        extra-substituters = ["https://noctalia.cachix.org"];
        extra-trusted-public-keys = ["noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="];
    };

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [
        vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
        wget

        adwaita-icon-theme
        gnome-themes-extra
        brightnessctl
        gparted
        # dconf
    ];
    # hardware.brightnessctl.enable = true;

    boot.extraModprobeConfig = ''
        options snd-hda-intel power_save=0 power_save_controller=N
    '';

    # environment.etc."asound.conf".text = ''
    #     pcm.!default {
    #     type hw
    #     card 0
    #     device 0
    #     }
    #     ctl.!default {
    #     type hw
    #     card 0
    #     }
    # '';
    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = false;
    };

    services.gnome.gnome-keyring.enable = true;
    services.greetd = {
        enable = true;
        settings.default_session = {
            command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.hyprland}/bin/start-hyprland";
            user = "greeter";
        };
    };

    programs.dconf.enable = true;

    services.pipewire = {
        enable = true;
        wireplumber = {
            enable = true;
            extraConfig = {
                "move-streams" = {
                    "wireplumber.settings" = {
                        "move-streams-on-default-sink-change" = true;
                    };
                };
            };
        };
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
    };
    services.blueman.enable = true;

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # programs.mtr.enable = true;
    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };

    # List services that you want to enable:

    # Enable the OpenSSH daemon.
    # services.openssh.enable = true;

    # Open ports in the firewall.
    # networking.firewall.allowedTCPPorts = [ ... ];
    # networking.firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # networking.firewall.enable = false;

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
}
