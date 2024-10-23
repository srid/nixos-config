{
  nix.settings.trusted-public-keys = [
    "om.cachix.org-1:ifal/RLZJKN4sbpScyPGqJ2+appCslzu7ZZF/C01f2Q="
    "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
  ];
  nix.settings.substituters = [
    "https://om.cachix.org"
    "https://hyprland.cachix.org"
  ];
}
