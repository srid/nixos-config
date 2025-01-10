{
  # Nix configuration is managed globally by nix-darwin.
  # Prevent $HOME nix.conf from disrespecting it.
  home.file."~/.config/nix/nix.conf".text = "";
}
