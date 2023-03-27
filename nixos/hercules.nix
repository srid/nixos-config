{ pkgs, flake, ... }:

{
  # TODO: use sops-nix to manage
  # - secrets
  # - ssh keys
  services.hercules-ci-agent = {
    enable = true;
    # nixpkgs may not always have the latest HCI.
    package = flake.inputs.hci.packages.${pkgs.system}.hercules-ci-agent;
  };

  # Regularly optimize nix store if using CI, because CI use can produce *lots*
  # of derivations.
  nix.gc = {
    automatic = ! pkgs.stdenv.isDarwin; # Enable only on Linux
    options = "--delete-older-than 90d";
  };
}
