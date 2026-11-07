# The odu pod's CI lane: its SSH key, the packages a run needs, and the
# substituter trust odu hands it. Host configs add only their extras.
{ lib, pkgs, ... }:
{
  users.users.ci = {
    isNormalUser = true;
    description = "odu CI lane";
    packages = [ pkgs.just ];
    openssh.authorizedKeys.keys = [
      # The odu pod (odu-lane keypair, `odu-lane-ssh`).
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFD3DbMP0DjYFBhlp4ckqyaG4ZW/Pk6Z3y34TDw8abFQ odu-k3s@pureintent"
    ];
  };
  # odu hands CI runs the kolu-r2 substituter and its key; untrusted users
  # ignore both.
  nix.settings.trusted-users = lib.mkAfter [ "ci" ];
}
