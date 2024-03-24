{ lib, ... }:

{
  # To build Linux derivations whilst on macOS.
  # 
  # NOTES:
  # - For first `nix run`, comment out all but the `enable` option, so binary cache is used. You may have to `sudo pkill nix-daemon` first.
  #   - After this, uncomment the configuration and `nix run`; this time, it will use the remote builder.
  # - To SSH, `sudo su -` and then `ssh -i /etc/nix/builder_ed25519  builder@linux-builder`.
  #   Unfortunately, a simple `ssh linux-builder` will not work (Too many authentication failures).
  # - To update virtualisation configuration, you have to disable; delete
  #   /private/var/lib/darwin-builder/ and re-enable.
  nix.linux-builder = {
    enable = true;
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    config = { pkgs, lib, ... }: {
      boot.binfmt.emulatedSystems = [ "x86_64-linux" ];
      nix.settings.experimental-features = "nix-command flakes repl-flake";
      environment.systemPackages = with pkgs; [
        htop
      ];
      virtualisation = {
        # Larger linux-builder cores, ram, and disk.
        cores = 6;
        memorySize = lib.mkForce (1024 * 16);
        diskSize = lib.mkForce (1024 * 1024 * 1); # In MB.
      };
    };
  };
}
