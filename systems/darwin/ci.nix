{ pkgs, lib, ... }:

{
  # TODO: Refactor this into a module, like easy-github-runners.nix
  services.github-runners =
    let
      srid = {
        common = {
          enable = true;
          # TODO: Document instructions
          # - chmod og-rwx; chown github-runner
          # TODO: Use a secret manager. 1Password?
          tokenFile = "/run/mykeys/gh-token-runner";
          extraPackages = with pkgs; [
            nixci
            cachix
            which
            coreutils
          ];
        };
        repos = {
          emanote = {
            url = "https://github.com/srid/emanote";
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
          lib.nameValuePair (builtins.trace name name) value)
      )));
  users.knownGroups = [ "github-runner" ];
  users.knownUsers = [ "github-runner" ];

  # To build Linux derivations whilst on macOS.
  # 
  # NOTES:
  # - To SSH, `sudo su -` and then `ssh -i /etc/nix/builder_ed25519  builder@linux-builder`.
  #   Unfortunately, a simple `ssh linux-builder` will not work (Too many authentication failures).
  # - To update virtualisation configuration, you have to disable, delete
  #   /private/var/lib/darwin-builder/ and re-enable.
  nix.linux-builder = {
    enable = true;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    config = { pkgs, lib, ... }: {
      boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
      virtualisation = {
        # Larger linux-builder cores, ram, and disk.
        cores = 6;
        memorySize = lib.mkForce (1024 * 16);
        diskSize = lib.mkForce (1024 * 1024 * 1); # In MB.
      };
    };
  };
}