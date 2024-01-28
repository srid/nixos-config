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
          localAddress = lib.mkOption {
            type = types.str;
            description = ''
              IP address of the host that will run containers.
            '';
            default =
              (builtins.head (builtins.head (lib.attrValues config.networking.interfaces)).ipv4.addresses).address;
          };
          runnerUid = lib.mkOption {
            type = types.int;
            default = 1234;
            description = ''
              Shared UID between host and containers.
              
              This allows the guest nix processes to access /nix/store of the host.
            '';
          };
          owner = lib.mkOption {
            type = types.str;
            default = "srid";
          };
          repositories = lib.mkOption {
            type = types.attrsOf types.str;
            description = ''
              My repositories configured to use self-hosted runners
              
              *Before* adding an entry, make sure the token exists in
              secrets.json (use the `gh` command above to create this token
              from CLI)

              Maps to container IP address to assign.
            '';
            default = {
              "emanote" = "192.168.100.20";
              "haskell-flake" = "192.168.100.21";
            };
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
    in
    {
      sops.secrets = lib.mapAttrs'
        (name: _: lib.nameValuePair "${cfg.sopsPrefix}/${name}" {
          mode = "0440";
        })
        cfg.repositories;

      containers =
        lib.mapAttrs'
          (name: hostAddress:
            let tokenFile = top.config.sops.secrets."${cfg.sopsPrefix}/${name}".path;
            in lib.nameValuePair "github-runner-${name}" {
              inherit (cfg) localAddress;
              inherit hostAddress;
              autoStart = true;
              bindMounts."${tokenFile}" = {
                hostPath = tokenFile;
                isReadOnly = true;
              };
              config = { config, pkgs, ... }: {
                system.stateVersion = "23.11";
                users.users."github-runner-${name}" = {
                  uid = cfg.runnerUid;
                  isSystemUser = true;
                  group = "github-runner-${name}";
                };
                users.groups."github-runner-${name}" = { };
                nix.settings = {
                  trusted-users = [ "github-runner-${name}" ]; # for cachix
                  experimental-features = "nix-command flakes repl-flake";
                  max-jobs = "auto";
                };
                services.github-runners."${name}" = cfg.runnerConfig // {
                  enable = true;
                  inherit tokenFile;
                  url = "https://github.com/${cfg.owner}/${name}";
                };
              };
            })
          cfg.repositories;

      users.users."github-runner" = {
        uid = cfg.runnerUid;
        isSystemUser = true;
        group = "github-runner";
      };
      users.groups.github-runner = { };

      nix.settings = {
        trusted-users = [ "github-runner" ];
        allowed-users = [ "github-runner" ];
      };
    };
}
