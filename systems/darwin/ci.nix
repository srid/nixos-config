{ ... }:

{
  # TODO: GitHub Runners

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
