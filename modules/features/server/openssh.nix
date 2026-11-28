{ ... }:
let
    authorizedKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA2tLbHGxTYI4Z4qFSiXFQFLlLVkfDDJQpTweLXZ2zNO gpress2222@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILfmSL1yGc9HdAOqFcDLDoWxKOAuGXcw2rlG5CmE2GNm gpress2222@gmail.com"
    ];
in
{
    flake.modules.darwin.openssh =
        { pkgs, ... }:
        {
            services.openssh = {
                enable = true;
                extraConfig = ''
                    PasswordAuthentication no
                    KbdInteractiveAuthentication no
                    PermitRootLogin no
                '';
            };
            users.users.gip.openssh.authorizedKeys.keys = authorizedKeys;
            environment.systemPackages = with pkgs; [
                ghostty-bin.terminfo
            ];

        };
    flake.modules.nixos.openssh = { pkgs, ... }: {
        services.openssh.enable = true;
        environment.systemPackages = with pkgs; [
            ghostty.terminfo
        ];
        users.users = {
            root.openssh.authorizedKeys.keys = authorizedKeys;
            gip.openssh.authorizedKeys.keys = authorizedKeys;
        };
    };
}
