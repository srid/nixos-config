{ pkgs, lib, inputs, system, ... }:

{
  services.hercules-ci-agent = {
    enable = true;
    # nixpkgs may not always have the latest HCI.
    package = inputs.hci.packages.${system}.hercules-ci-agent;
  };

  # Regularly optimize nix store if using CI, because CI use can produce *lots*
  # of derivations.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    # NOTE: If the repos that use cache are updated as often as once a week (eg:
    # flake.lock update action?), its cache should not be invalidated over time
    # of idle periods.
    options = "--delete-older-than 30d";
  };
}
