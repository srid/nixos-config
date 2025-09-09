{ flake, ... }:
let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  imports = [
    self.homeModules.default
    self.homeModules.linux-only
    (self + /modules/home/all/vira.nix)
  ];

  home.username = "srid";

  services.gotty = {
    enable = true;
    port = 9000;
    command = "tmux new-session -A -s gotty";
    write = true;
  };
}
