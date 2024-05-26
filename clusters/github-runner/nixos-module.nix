{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  user = "github-runner";
  group = "github-runner";
  tokenFile = "/run/keys/github-runner-token.secret"; # See colmena keys in top-level flake.nix
  repos = import ./repos.nix;
  runner-pkgs = (import ./runner-pkgs.nix { inherit pkgs lib; });
  # Convenient function to create multiple runners per single personal repo.
  mkPersonalRunners = user:
    lib.concatMapAttrs (repoName: meta:
      lib.listToAttrs (lib.flip builtins.map (lib.range 1 meta.num) (idx:
        let
          name = "${repoName}-${builtins.toString idx}";
        in
        lib.nameValuePair name {
          inherit user group tokenFile name;
          enable = true;
          replace = true;
          ephemeral = true;
          extraPackages = with pkgs; runner-pkgs ++ [
            # Standard nix tools
            nixci
            cachix
            # For nixos-flake
            sd
          ];
          url = "https://github.com/${user}/${repoName}";
        })));
  hostIP = "10.37.129.2"; # Find out using `ifconfig` on host, looking for bridge101
in
{
  # User
  users.users.${user} = {
    inherit group;
    isSystemUser = true;
  };
  users.groups.${group} = { };
  nix.settings.trusted-users = [ user ];

  # No way to do this: https://github.com/NixOS/nix/issues/6536
  #nix.extraOptions = ''
  #  !include /run/keys/nix-conf-gh-token.secret
  #'';

  # Runners
  services.github-runners = mkPersonalRunners "srid" repos.srid;

  # macOS remote builder
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = hostIP;
    systems = [ "aarch64-darwin" "x86_64-darwin" ];
    maxJobs = 6; # 6 cores
    protocol = "ssh-ng";
    sshUser = user;
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
  }];
}
