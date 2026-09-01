{ flake, lib, ... }:

let
  inherit (flake) inputs;
  inherit (inputs) self;
  homeMod = self + /modules/home;
  # pu-managed CI fleet (kolu-ci-1 .. kolu-ci-8). These are ssh_config aliases
  # provided by `pu` (Include ~/.pu-state/*/ssh_config) and are reachable only
  # from pureintent, so drishti monitors them from here.
  ciHosts = map (n: "kolu-ci-${toString n}") (lib.range 1 8);
in
{
  nixos-unified.sshTarget = "srid@pureintent";
  # nixos-unified.sshTarget = "srid@192.168.2.134";

  imports = [
    self.nixosModules.default
    ./configuration.nix
    (self + /modules/nixos/linux/my-workstation.nix)
    (self + /modules/nixos/linux/juspay-run.nix)
    ./kolu-dev.nix
    (self + /modules/nixos/linux/beszel.nix)
    (self + /modules/nixos/linux/gc.nix)
    (self + /modules/nixos/linux/llm-debugging.nix)
    (self + /modules/nixos/linux/atuin.nix)
  ];

  home-manager.sharedModules = [
    "${homeMod}/cli/ssh-agent-forwarding.nix"
    "${homeMod}/cli/controlpersist.nix"
    "${homeMod}/services/kolu.nix"
    "${homeMod}/services/drishti"
    {
      services.kolu.host = "100.122.32.106"; # Tailscale IP of pureintent
      # Browser origin differs from the Host kolu sees (served via Tailscale
      # MagicDNS reverse proxy), so allow it for the CSWSH origin gate.
      services.kolu.allowedOrigins = [ "https://pureintent.rooster-blues.ts.net" ];
      # Point padi at zest for host switching (pureintent only). home-manager
      # concatenates this onto the module's own Environment list.
      systemd.user.services.kolu.Service.Environment = [ "KOLU_PADI_HOST=zest" ];
      # Watch the pu-managed CI fleet from here (only reachable from pureintent).
      services.drishti.hosts = [ "localhost" ] ++ ciHosts;
    }

    # "${homeMod}/services/dropbox.nix"
    # "${homeMod}/services/obsidian.nix"

    # Remote builders
    "${homeMod}/nix/buildMachines"
    "${homeMod}/nix/buildMachines/sincereintent.nix"
  ];

  # Prefer compressed in-RAM swap so page faults under build + Claude fleet
  # load become decompression instead of QLC disk I/O thrashing.
  # https://github.com/srid/nixos-config/issues/121
  zramSwap = {
    enable = true;
    memoryPercent = 50;
  };
  # Drop disk swap (install partition + prior 32G swapfile). Overflow onto a
  # DRAM-less QLC drive is what stalls the box; better to OOM-kill the runaway
  # process (earlyoom below) than thrash.
  swapDevices = lib.mkForce [ ];

  # Workaround `nixos-rebuild switch` hanging at "reloading the following units:
  # dbus-broker.service". The reload step stalls (broker has long-lived clients
  # holding the bus); skip reload/restart during activation. Bus policy changes
  # land on next boot instead. Same applies to the per-user broker
  # (`Failed to reload user unit dbus-broker.service` → exit 4).
  systemd.services.dbus-broker.reloadIfChanged = lib.mkForce false;
  systemd.services.dbus-broker.restartIfChanged = lib.mkForce false;
  systemd.user.services.dbus-broker.reloadIfChanged = lib.mkForce false;
  systemd.user.services.dbus-broker.restartIfChanged = lib.mkForce false;
}
