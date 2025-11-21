{
  # Global session path for all shells
  # Normally, we do this on macOS only. And it is not necessary on NixOS. Yet,
  # non-NixOS Linux will need it (when using the official Nix installer).
  home.sessionPath = [
    "/run/wrappers/bin" # Workaround NixOS upstream sudo fuckery
    "/etc/profiles/per-user/$USER/bin"
    "/nix/var/nix/profiles/system/sw/bin"
    "$HOME/.nix-profile/bin"
    "/usr/local/bin"
  ];
}
