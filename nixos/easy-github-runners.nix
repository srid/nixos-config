/* Module for setting up personal or org-wide github runners

  Limitations
  - A runner can run only one job at a time: https://github.com/orgs/community/discussions/26769
      - This makes sharing an org-wide runner less useful, unless we create multiple runners.

  TODOs

  - [x] Run runners in containers
  - [ ] macOS runners: https://github.com/LnL7/nix-darwin/issues/582
  - [x] Support github orgs
  - [ ] Unbreak cachix? https://github.com/cachix/cachix-action/issues/169 
      - [x] Or switch to nix-serve or attic

*/
top@{ pkgs, lib, config, ... }:
let
  inherit (lib) types;
in
{
  options = {
    services.easy-github-runners = lib.mkOption {
      description = ''
        Attrset of runners.

        The key is either org name or the repo path.
      '';
      type = types.lazyAttrsOf (types.submodule ({ config, name, ... }: {
        options = {
          owner = lib.mkOption {
            type = types.str;
            description = ''
              The owner of this repo/org.

              The PAC token of this owner must be able to setup runners for this
              repo/org.
            '';
            default = lib.head (lib.splitString "/" config.githubPath);
          };
          url = lib.mkOption {
            type = types.str;
            description = ''Github URL for this runner'';
            default = "https://github.com/${config.githubPath}";
          };
          githubPath = lib.mkOption {
            type = types.str;
            default = name;
            description = ''
              The path after https://github.com in the URL for this runner

              By default, it uses the attr key. If you are running multiple
              runners per org or per repo, you may want to explicitly specify
              the githubPath to disambiguate.  
            '';
          };
          tokenSecretPath = lib.mkOption {
            type = types.str;
            # By default, we expect personal access token (not runner registeration token)
            # Thus, it is bucket by the owner.
            default = "gh-selfhosted-tokens/${config.owner}";
            readOnly = true;
            description = ''
              sops-nix key path containing the token for this runner.
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
      }));
    };
  };
  config =
    let
      cfg = config.services.easy-github-runners;
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
      sops.secrets =
        lib.flip lib.mapAttrs' cfg (name: cfg:
          lib.nameValuePair cfg.tokenSecretPath {
            mode = "0440";
          });

      nix.settings = {
        trusted-users = [ user ];
        allowed-users = [ user ];
      };

      containers =
        lib.flip lib.mapAttrs' cfg
          (name: cfg:
            let
              tokenFile = top.config.sops.secrets."${cfg.tokenSecretPath}".path;
              nameLegal = lib.replaceStrings [ "/" ] [ "-" ] name;
            in
            lib.nameValuePair ''github-runner-${nameLegal}'' {
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
                services.github-runners."${nameLegal}" = cfg.runnerConfig // {
                  enable = true;
                  inherit user tokenFile;
                  inherit (cfg) url;
                };
              };
            });
    };
}
