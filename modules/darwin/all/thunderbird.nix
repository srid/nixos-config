{
  # https://github.com/nix-community/home-manager/issues/3407#issuecomment-1312712582
  launchd.user.envVariables = {
    MOZ_LEGACY_PROFILES = "1"; # thunderbird
    MOZ_ALLOW_DOWNGRADE = "1"; # thunderbird
  };
}
