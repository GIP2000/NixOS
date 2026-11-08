{...}: {
    services.pihole-ftl = {
        enable = true;

        lists = [
            {
                url = "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts";
                # type = "block";  # default
                # enabled = true;
            }
        ];

        openFirewallDNS = true;
        openFirewallDHCP = true;

        settings = {
            dns = {
                hosts = [
                    "192.168.1.152 doof.local"
                ];
                upstreams = [
                    "1.1.1.1"
                    "9.9.9.9"
                ];
            };

            dhcp = {
                active = true;
                start = "192.168.1.2";
                end = "192.168.1.254";
                router = "192.168.1.1";
                leaseTime = "24h";

                hosts = [
                    "f0:4d:a2:07:b0:db,192.168.1.152,doof,infinite"
                ];
            };
        };
    };

    services.pihole-web = {
        enable = true;
        ports = [8081];
    };

    networking.firewall.allowedTCPPorts = [
        8081
    ];
}
