{ inputs, pkgs, ... }:

let
    unstable = import inputs.nixpkgs {
        system = pkgs.stdenv.hostPlatform.system;
        config.allowUnfree = true;
    };
in
{

    containers.minecraft = {
        autoStart = true;
        privateNetwork = true; # no shared host network, nothing exposed
        hostAddress = "10.233.1.1";
        localAddress = "10.233.1.2";

        # needed for Tailscale's TUN device
        allowedDevices = [
            {
                node = "/dev/net/tun";
                modifier = "rwm";
            }
        ];
        bindMounts."/dev/net/tun" = {
            hostPath = "/dev/net/tun";
            isReadOnly = false;
        };

        config = { ... }: {
            system.stateVersion = "26.05";
            networking.nameservers = [ "1.1.1.1" ];
            services.tailscale.enable = true;
            services.minecraft-server = {
                enable = true;
                package = unstable.minecraftServers.vanilla-26-3;
                eula = true;
                jvmOpts = "-Xms6G -Xmx6G";

            };
            nixpkgs.config.allowUnfree = true;

            # only reachable over the tailnet
            networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 25565 ];
        };

    };
}
