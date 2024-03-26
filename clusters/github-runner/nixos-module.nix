{ flake, pkgs, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  user = "github-runner";
  group = "github-runner";
  tokenFile = "/run/keys/github-runner-token.secret"; # See colmena keys in top-level flake.nix
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
          extraPackages = with pkgs; [
            # Standard nix tools
            nixci
            cachix

            # For nixos-flake
            sd

            # Tools already available in standard GitHub Runners; so we provide
            # them here:
            coreutils
            which
            jq
            # https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml#L40
            (pkgs.runCommandNoCC "gtar" { } ''
              mkdir -p $out/bin
              ln -s ${lib.getExe pkgs.gnutar} $out/bin/gtar
            '')
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

  # Runners
  services.github-runners = mkPersonalRunners "srid" {
    haskell-flake.num = 2 * 7;
    nixos-config.num = 2 * 5;
    perpetuum.num = 2;
  };

  # macOS remote builder
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = hostIP;
    systems = [ "aarch64-darwin" "x86_64-darwin" ];
    # supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    maxJobs = 6; # 6 cores
    protocol = "ssh-ng";
    sshUser = user;
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
  }];
}
