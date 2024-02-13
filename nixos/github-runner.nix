/* Module for setting up personal github runners

  Limitations
  - A runner can run only one job at a time: https://github.com/orgs/community/discussions/26769
      - This makes sharing an org-wide runner less useful.

  TODOs

  - [x] Run runners in containers
  - [ ] macOS runners: https://github.com/LnL7/nix-darwin/issues/582
  - [ ] Support github orgs
  - [ ] Unbreak cachix? https://github.com/cachix/cachix-action/issues/169 
      - [x] Or switch to nix-serve or attic
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
top@{ pkgs, lib, config, ... }:
let
  inherit (lib) types;
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
            description = ''
              My repositories configured to use self-hosted runners
              
              *Before* adding an entry, make sure the token exists in
              secrets.json (use the `gh` command above to create this token
              from CLI)
            '';
            default = [
              "emanote"
              "haskell-flake"
              "nixos-config"
              "ema"
            ];
          };
          sopsPrefix = lib.mkOption {
            type = types.str;
            default = "gh-selfhosted-tokens";
            readOnly = true;
          };
          nixosConfig = lib.mkOption {
            type = types.deferredModule;
            description = ''
              NixOS configuration for the GitHub Runner container
            '';
            default = { pkgs, ... }: {
              nix.settings = {
                experimental-features = "nix-command flakes repl-flake";
                max-jobs = "auto";
              };
            };
          };
          runnerConfig = lib.mkOption {
            type = types.lazyAttrsOf types.raw;
            description = ''Configuration for the GitHub Runner'';
            default = {
              extraPackages = with pkgs; [
                cachix
                nixci
                which
                coreutils
                docker
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
      user = "github-runner";
      userModule = {
        users.users.${user} = {
          uid = 1099;
          isSystemUser = true;
          group = user;
        };
        users.groups.${user} = { };
      };
    in
    userModule // {
      sops.secrets."${cfg.sopsPrefix}/srid".mode = "0440";

      containers =
        lib.listToAttrs (builtins.map
          (name:
            let
              tokenFile = top.config.sops.secrets."${cfg.sopsPrefix}/srid".path;
            in
            lib.nameValuePair "github-runner-${name}" {
              autoStart = true;
              bindMounts."${tokenFile}" = {
                hostPath = tokenFile;
                isReadOnly = true;
              };
              config = { config, pkgs, ... }: {
                system.stateVersion = "23.11";
                imports = [
                  userModule
                  cfg.nixosConfig
                ];
                nix.settings.trusted-users = [ user ]; # for cachix
                services.github-runners."${name}" = cfg.runnerConfig // {
                  enable = true;
                  inherit user tokenFile;
                  url = "https://github.com/${cfg.owner}/${name}";
                };
              };
            })
          cfg.repositories);

      nix.settings = {
        trusted-users = [ user ];
        allowed-users = [ user ];
      };
    };
}
