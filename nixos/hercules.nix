{ pkgs, lib, inputs, system, ... }:

{
  # TODO: use agenix to manage
  # - secrets
  # - ssh keys
  services.hercules-ci-agent = {
    enable = true;
    # nixpkgs may not always have the latest HCI.
    package = inputs.hci.packages.${system}.hercules-ci-agent;
  };

  # Regularly optimize nix store if using CI, because CI use can produce *lots*
  # of derivations.
  nix.gc = {
    automatic = ! pkgs.stdenv.isDarwin;  # Enable only on Linux
    options = "--delete-older-than 90d";
  };
}
