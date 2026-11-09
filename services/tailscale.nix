{...}: {
    services.tailscale = {
        enable = true;
        extraUpFlags = ["--ssh"];
        openFirewall = true;
        useRoutingFeatures = "server";
    };

    networking.firewall.trustedInterfaces = ["tailscale0"];
}
