{ pkgs, lib, config, ... }:
{
  # TODO: Run inside container
  services.github-runners = {
    emanote-runner = {
      enable = true;
      name = "emanote-runner";
      # TODO: use sops-nix
      tokenFile = "/home/srid/runner.token";
      url = "https://github.com/srid/emanote";
      extraPackages = [ pkgs.cachix pkgs.nixci ];
      extraLabels = [ "nixos" ];
    };

    sridcircle-runner = {
      enable = true;
      name = "sridcircle-runner";
      # TODO: use sops-nix
      tokenFile = "/home/srid/sridcircle-runner.token";
      url = "https://github.com/SridCircle";
      extraPackages = [ pkgs.cachix pkgs.nixci ];
      extraLabels = [ "nixos" ];
    };
  };
  nix.settings.trusted-users =
    lib.mapAttrsToList
      (name: runner:
        if runner.user == null
        then
        # systemd DynamicUser
          "github-runner-${name}"
        else runner.user)
      config.services.github-runners;
}
