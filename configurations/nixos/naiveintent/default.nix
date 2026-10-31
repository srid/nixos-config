{ flake, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@naiveintent";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    # Single-node K3s cluster running olai; odu's cluster is on pureintent.
    (self + /k8s)
    (self + /k8s/apps/olai)
    (self + /modules/nixos/linux/my-workstation.nix)
    # pu / xyne-boxes + juspay-run (needs jumphost SOCKS5 from juspay.nix)
    (self + /modules/nixos/linux/devbox.nix)
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/docker.nix)
    (self + /modules/nixos/linux/incus/host.nix)
    (self + /modules/nixos/linux/llm-debugging.nix)
    (self + /modules/nixos/linux/kill-audit.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/gui/1password.nix"
    "${homeMod}/cli/ssh-agent-forward.nix"
    # No 1Password app runs here, so its agent socket never exists; an
    # IdentityAgent pointing at it makes ssh ignore the agent forwarded to
    # this host over $SSH_AUTH_SOCK.
    ({ lib, ... }: {
      programs.ssh.settings."*".IdentityAgent = lib.mkForce null;
    })
    # LITELLM_API_KEY for Juspay's gateway
    "${homeMod}/work/litellm.nix"
    # The K3s app serves Vault; this instance serves the olai repo's own docs.
    inputs.olai.homeManagerModules.default
    ({ config, ... }: {
      services.olai = {
        enable = true;
        dataDir = "${config.home.homeDirectory}/code/oss.olai";
        # push = "auto";
        # extraPlugins = [ "claude" "codex" "chat" "kolu" "odu" ];
      };
    })
  ];

  # Ethernet address (enp1s0f0); the Wi-Fi interface has a different one.
  k8s.nodeIP = "192.168.2.48";

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64 * 1024; # 64GB in megabytes
  }];

  networking.firewall.allowedTCPPorts = [ 7692 ];
}
