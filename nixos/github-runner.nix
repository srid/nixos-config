/* Module for setting up personal github runners

  TODOs

  - [ ] Run runners in containers
  - [ ] Write a token creation script:
  ```sh
  $ gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  /repos/srid/haskell-flake/actions/runners/registration-token
  ```
  - [ ] Can we automate that to write directly to secrets.json?

*/
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
              # 
              # For each entry, make sure the token exists in secrets.json (use
              # the `gh` command above to create this token from CLI)
              "emanote"
              "haskell-flake"
            ];
          };
          sopsPrefix = lib.mkOption {
            type = types.str;
            default = "gh-selfhosted-tokens";
          };
          runnerConfig = lib.mkOption {
            type = types.lazyAttrsOf types.raw;
            default = {
              extraPackages = with pkgs; [
                cachix
                nixci
                which
                coreutils
              ];
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
    in
    {
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
        }))
        cfg.repositories);

      nix.settings.trusted-users =
        lib.mapAttrsToList
          (name: runner:
            if runner.user == null
            then getRunnerUser name
            else runner.user)
          config.services.github-runners;
    };
}
