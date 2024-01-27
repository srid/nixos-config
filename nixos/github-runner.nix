{ pkgs, lib, config, ... }:
let
  inherit (lib) types;
  getRunnerUser = name:
    # systemd DynamicUser
    "github-runner-${name}";
in
{
  options = {
    services.personal-github-runners = lib.mkOption {
      default = { };
      type = types.submodule {
        owner = lib.mkOption {
          type = types.str;
          default = "srid";
        };
        repositories = lib.mkOption {
          type = types.listOf types.str;
          default = [
            # My repositories configured to use self-hosted runners
            "emanote"
          ];
        };
        sopsPrefix = lib.mkOption {
          type = types.str;
          default = "gh-selfhosted-tokens";
        };
        runnerConfig = lib.mkOption {
          type = types.deferredModule;
          default = {
            extraPackages = [ pkgs.cachix pkgs.nixci ];
            extraLabels = [ "nixos" ];
          };
        };
      };
    };
  };
  config = {
    sops.secrets = {
      "gh-selfhosted-tokens/emanote".mode = "0440";
    };

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
  };
}
