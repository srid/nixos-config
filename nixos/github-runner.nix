/* Module for setting up personal github runners

  TODOs

  - [x] Run runners in containers
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
  runnerUid = 1234; # Shared UID between host and containers, so guest nix can access /nix/store of host.
  localAddress = (builtins.head (builtins.head (lib.attrValues config.networking.interfaces)).ipv4.addresses).address;
in
{
  options = {
    services.personal-github-runners = lib.mkOption {
      default = { };
      type = types.submodule {
        options = {
          hostAddresses = lib.mkOption {
            type = types.listOf types.str;
            default = [
              "192.168.100.20"
              "192.168.100.21"
              "192.168.100.22"
              "192.168.100.23"
              # ... etc
            ];
          };
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
      sops.secrets = lib.listToAttrs (builtins.map
        (name: lib.nameValuePair "${cfg.sopsPrefix}/${name}" {
          mode = "0440";
        })
        cfg.repositories);

      containers =
        lib.listToAttrs (builtins.map
          ({ fst, snd }:
            let tokenFile = top.config.sops.secrets."${cfg.sopsPrefix}/${fst}".path;
            in lib.nameValuePair "github-runner-${fst}" {
              inherit localAddress;
              hostAddress = snd;
              autoStart = true;
              bindMounts."${tokenFile}" = {
                hostPath = tokenFile;
                isReadOnly = true;
              };
              config = { config, pkgs, ... }: {
                system.stateVersion = "23.11";
                users.users."github-runner-${fst}" = {
                  uid = runnerUid;
                  isSystemUser = true;
                  group = "github-runner-${fst}";
                };
                users.groups."github-runner-${fst}" = { };
                nix.settings = {
                  trusted-users = [ "github-runner-${fst}" ]; # for cachix
                  experimental-features = "nix-command flakes repl-flake";
                  max-jobs = "auto";
                };
                services.github-runners."${fst}" = cfg.runnerConfig // {
                  enable = true;
                  inherit tokenFile;
                  url = "https://github.com/${cfg.owner}/${fst}";
                };
              };
            })
          (lib.zipLists cfg.repositories cfg.hostAddresses));

      users.users."github-runner" = {
        uid = runnerUid;
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
