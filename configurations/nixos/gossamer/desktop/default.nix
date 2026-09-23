{
  imports = [
    ./plasma.nix
    ./niri.nix
    ./noctalia.nix
    ./power.nix
    ./displays.nix
    ./keyring.nix
    ./video.nix
    ./recording.nix
  ];

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "niri";
}
