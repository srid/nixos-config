{ flake, pkgs, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
in
{
  nixos-unified.sshTarget = "srid@hello";

  imports = [
    ../public-vm/configuration.nix
  ];

  networking.hostName = "hello";

  environment.systemPackages = with pkgs; [
    neovim
  ];
}
