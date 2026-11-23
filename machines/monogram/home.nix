{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../home-manager/programs/nvim.nix
    ../../home-manager/programs/shell.nix
    ../../services/bluebubbles.nix
  ];
  home = {
    username = "gip";
    homeDirectory = "/Users/gip";
    stateVersion = "26.05";
  };
}
