{ pkgs, lib, ... }:

{
  # Nix configuration is managed globally by nix-darwin.
  # Prevent $HOME nix.conf from disrespecting it.
  home.file.".config/nix/nix.conf".text = "";

  # Global session path for all shells
  # Normally, we do this on macOS only. And it is not necessary on NixOS. Yet,
  # non-NixOS Linux will need it (when using the official Nix installer).
  home.sessionPath = [
    "/etc/profiles/per-user/$USER/bin"
    "/nix/var/nix/profiles/system/sw/bin"
    "$HOME/.nix-profile/bin"
    "/usr/local/bin"
  ];
}
