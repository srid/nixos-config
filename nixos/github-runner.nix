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
  - [ ] Document PAC token
      - For user accounts, create a legacy PAC token with 'repo' scope. New-style could also work. 

*/
top@{ pkgs, lib, config, ... }:
let
  inherit (lib) types;
in
{
  options = {
    # TODO: Make this general enough to support organizations and other users.
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
            description = ''
              sops-nix parent key path containing the tokens
            '';
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
      sops.secrets."${cfg.sopsPrefix}/${cfg.owner}".mode = "0440";

      nix.settings = {
        trusted-users = [ user ];
        allowed-users = [ user ];
      };

      containers =
        lib.listToAttrs (builtins.map
          (name:
            let
              tokenFile = top.config.sops.secrets."${cfg.sopsPrefix}/${cfg.owner}".path;
              githubPath = "${cfg.owner}/${name}";
              url = "https://github.com/${githubPath}";
              githubPathLegal = lib.replaceStrings [ "/" ] [ "-" ] githubPath;
            in
            lib.nameValuePair ''github-runner-${githubPathLegal}'' {
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
                services.github-runners."${githubPathLegal}" = cfg.runnerConfig // {
                  enable = true;
                  inherit user url tokenFile;
                };
              };
            })
          cfg.repositories);

    };
}
