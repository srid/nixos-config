{ flake, pkgs, ... }:
{
  nixos-unified.sshTarget = "nix-infra@sambar";

  networking.hostName = "sambar";
  # ids.uids.nixbld = 300;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";

  environment.systemPackages = with pkgs; [
    btop
    tailscale
  ];

  services = {
    openssh.enable = true;
    tailscale.enable = true;
  };

  nix.enable = true;

  # Legacy admin user, `nix-infra`. Keeping for compat.
  users.users.nix-infra = {
    name = "nix-infra";
    uid = 502;
    home = "/Users/nix-infra";
    openssh.authorizedKeys.keys = [
      flake.config.me.sshKey
    ];
  };
}
