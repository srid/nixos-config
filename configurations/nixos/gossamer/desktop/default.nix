{
  imports = [
    ./plasma.nix
    ./niri.nix
    ./noctalia.nix
    ./power.nix
    ./displays.nix
    ./keyring.nix
    ./recording.nix
  ];

  services.displayManager.sddm.enable = true;
  # Niri's module supplies its own default; keep Plasma as the fallback session.
  services.displayManager.defaultSession = "plasma";
}
