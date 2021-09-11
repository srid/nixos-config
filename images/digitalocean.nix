let
  nixpkgs =
    (
      let
        lock = builtins.fromJSON (builtins.readFile ../flake.lock);
      in
      fetchTarball {
        url = "https://github.com/NixOS/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
        sha256 = lock.nodes.nixpkgs.locked.narHash;
      }
    );
  pkgs = import nixpkgs { };
  config = {
    imports =
      [ "${nixpkgs}/nixos/modules/virtualisation/digital-ocean-image.nix" ];

    # Headless - don't start a tty on the serial consoles.
    systemd.services."serial-getty@ttyS0".enable = false;
    systemd.services."serial-getty@hvc0".enable = false;
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@".enable = false;

    # sufficient swap for functioning nix-build on 1G droplets
    swapDevices = [{ device = "/swapfile"; size = 2048; }];

    # Make sure that SSH is available
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.sshd.enable = true;
    users.users.root.openssh.authorizedKeys.keys = [ (builtins.readFile ../id_rsa.pub) ];

    # Use more aggressive compression then the default.
    virtualisation.digitalOceanImage.compressionMethod = "bzip2";
  };
in
(pkgs.nixos config).digitalOceanImage
