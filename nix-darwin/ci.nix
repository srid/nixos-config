{ flake, pkgs, lib, ... }:

{
  # TODO: Refactor this into a module, like easy-github-runners.nix
  services.github-runners =
    let
      srid = {
        common = {
          enable = true;
          # TODO: Document instructions
          # - chmod og-rwx; chown github-runner
          # TODO: Use a secret manager. 1Password? https://github.com/LnL7/nix-darwin/issues/882
          # > OAuth app tokens and personal access tokens (classic) need the 
          # > admin:org scope to use this endpoint. If the repository is private, 
          # > the repo scope is also required.
          # https://docs.github.com/en/rest/actions/self-hosted-runners?apiVersion=2022-11-28#list-self-hosted-runners-for-an-organization
          tokenFile = "/run/mykeys/gh-token-runner";
          extraPackages = with pkgs; [
            nixci
            cachix
            which
            coreutils
            # https://github.com/actions/upload-pages-artifact/blob/56afc609e74202658d3ffba0e8f6dda462b719fa/action.yml#L40
            (pkgs.runCommandNoCC "gtar" { } ''
              mkdir -p $out/bin
              ln -s ${lib.getExe pkgs.gnutar} $out/bin/gtar
            '')
            # For nixos-flake
            sd
          ];
        };
        repos = {
          emanote = {
            url = "https://github.com/srid/emanote";
            num = 2;
          };
          ema = {
            url = "https://github.com/srid/ema";
            num = 3;
          };
          nixci = {
            url = "https://github.com/srid/nixci";
            num = 2;
          };
          nixos-config = {
            url = "https://github.com/srid/nixos-config";
            num = 2;
          };
          nixos-flake = {
            url = "https://github.com/srid/nixos-flake";
            num = 3;
          };
          haskell-flake = {
            url = "https://github.com/srid/haskell-flake";
            num = 2;
          };
          heist-extra = {
            url = "https://github.com/srid/heist-extra";
            num = 2;
          };
          unionmount = {
            url = "https://github.com/srid/unionmount";
            num = 2;
          };
        };
      };
    in
    lib.listToAttrs (lib.concatLists (lib.flip lib.mapAttrsToList srid.repos
      (k: { url, num }:
        lib.flip builtins.map (lib.range 1 num) (idx:
          let
            name = "${k}-${builtins.toString idx}";
            value = srid.common // {
              inherit url;
            };
          in
          lib.nameValuePair name value)
      )));
  users.knownGroups = [ "github-runner" ];
  users.knownUsers = [ "github-runner" ];

  # If not using linux-builder, use a VM
  nix.distributedBuilds = true;
  nix.buildMachines = [{
    hostName = "linux-builder";
    systems = [ "aarch64-linux" "x86_64-linux" ];
    supportedFeatures = [ "kvm" "benchmark" "big-parallel" ];
    maxJobs = 6; # 6 cores
    protocol = "ssh-ng";
    sshUser = flake.config.people.myself;
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
  }];

  # To build Linux derivations whilst on macOS.
  # 
  # NOTES:
  # - To SSH, `sudo su -` and then `ssh -i /etc/nix/builder_ed25519  builder@linux-builder`.
  #   Unfortunately, a simple `ssh linux-builder` will not work (Too many authentication failures).
  # - To update virtualisation configuration, you have to disable, delete
  #   /private/var/lib/darwin-builder/ and re-enable.
  nix.linux-builder = {
    enable = false;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    config = { pkgs, lib, ... }: {
      boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
      nix.settings.experimental-features = "nix-command flakes repl-flake";
      virtualisation = {
        # Larger linux-builder cores, ram, and disk.
        cores = 6;
        memorySize = lib.mkForce (1024 * 16);
        diskSize = lib.mkForce (1024 * 1024 * 1); # In MB.
      };
    };
  };
}
