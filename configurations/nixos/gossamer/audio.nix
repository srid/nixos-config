{
  # Shared audio infrastructure for both desktops. Hardware-specific output
  # preferences belong with the device, e.g. apple-studio-display.nix.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
