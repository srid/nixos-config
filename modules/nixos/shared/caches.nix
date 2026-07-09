# Extra binary caches, shared by NixOS hosts and home-manager configs.
#
# Uses extra-* (not substituters/trusted-public-keys) so it is purely additive:
# the default cache.nixos.org is preserved whether this lands in a system
# /etc/nix/nix.conf (pureintent) or a user ~/.config/nix/nix.conf (zest, where
# srid is a trusted user so the setting is honoured).
{
  nix.settings.extra-substituters = [
    "https://cache.nixos.asia/oss"
  ];
  nix.settings.extra-trusted-public-keys = [
    "oss:KO872wNJkCDgmGN3xy9dT89WAhvv13EiKncTtHDItVU="
  ];
}
