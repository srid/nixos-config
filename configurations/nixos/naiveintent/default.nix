{ flake, ... }:

let
  self = flake.inputs.self;
  homeMod = self + /modules/home;
in
{
  nixos-unified.sshTarget = "srid@naiveintent";

  imports = [
    self.nixosModules.default
    (self + /k8s/odu-lane.nix)
    ./configuration.nix
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
  ];

  zramSwap.enable = true;
  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 64 * 1024; # 64GB in megabytes
  }];

  networking.firewall.allowedTCPPorts = [ 7692 ];

  # odu CI lane on the workstation (modules/home/cli/odu.nix used to list
  # ci@pureintent here; pureintent left the inventory).
  users.users.ci.openssh.authorizedKeys.keys = [ flake.config.me.sshKey ];
}
