{
  nix.settings.trusted-public-keys = [
    "om.cachix.org-1:ifal/RLZJKN4sbpScyPGqJ2+appCslzu7ZZF/C01f2Q="
    "nammayatri.cachix.org-1:PiVlgB8hKyYwVtCAGpzTh2z9RsFPhIES6UKs0YB662I="
  ];
  nix.settings.substituters = [
    "https://om.cachix.org"
    "https://nammayatri.cachix.org?priority=42"
  ];
}
