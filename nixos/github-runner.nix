{ pkgs, lib, config, ... }:
let
  getRunnerUser = name:
    # systemd DynamicUser
    "github-runner-${name}";
in
{
  sops.secrets."gh-selfhosted-tokens/emanote".mode = "0440";

  # TODO: Run inside container
  services.github-runners = {
    emanote = {
      enable = true;
      name = "emanote";
      tokenFile = config.sops.secrets."gh-selfhosted-tokens/emanote".path;
      url = "https://github.com/srid/emanote";
      extraPackages = [ pkgs.cachix pkgs.nixci ];
      extraLabels = [ "nixos" ];
    };
  };
  nix.settings.trusted-users =
    lib.mapAttrsToList
      (name: runner:
        if runner.user == null
        then getRunnerUser name
        else runner.user)
      config.services.github-runners;
}
