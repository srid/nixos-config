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
        options = {
          owner = lib.mkOption {
            type = types.str;
            default = "srid";
          };
          repositories = lib.mkOption {
            type = types.listOf types.str;
            default = [
              # My repositories configured to use self-hosted runners
              # For each entry, make sure the token exists in secrets.json
              "emanote"
            ];
          };
          sopsPrefix = lib.mkOption {
            type = types.str;
            default = "gh-selfhosted-tokens";
          };
          runnerConfig = lib.mkOption {
            type = types.lazyAttrsOf types.raw;
            default = {
              extraPackages = [ pkgs.cachix pkgs.nixci ];
              extraLabels = [ "nixos" ];
            };
          };
        };
      };
    };
  };
  config =
    let 
      cfg = config.services.personal-github-runners;
    in {
      sops.secrets = lib.listToAttrs (builtins.map
        (name: lib.nameValuePair "${cfg.sopsPrefix}/${name}" {
          mode = "0440";
        })
        cfg.repositories);

      # TODO: Run inside container
      services.github-runners = lib.listToAttrs (builtins.map 
        (name: lib.nameValuePair name (cfg.runnerConfig // {
          enable = true;
          tokenFile = config.sops.secrets."${cfg.sopsPrefix}/${name}".path;
          url = "https://github.com/${cfg.owner}/${name}";
        })) cfg.repositories);

      nix.settings.trusted-users =
        lib.mapAttrsToList
          (name: runner:
            if runner.user == null
            then getRunnerUser name
            else runner.user)
          config.services.github-runners;
    };
}
