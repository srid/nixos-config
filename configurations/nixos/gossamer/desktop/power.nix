{
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  # Plasma inhibits logind and applies its own power policy. In Niri, logind
  # handles the lid and Noctalia holds the delay inhibitor to lock before sleep.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Noctalia runs only with Niri. Keep idle policy separate from appearance.
  home-manager.sharedModules = [
    {
      xdg.configFile."noctalia/power.toml".text = ''
        [lockscreen]
        enabled = true
        lock_before_suspend = true
        fingerprint = false

        [idle.behavior.lock]
        enabled = true
        timeout = 600
        action = "lock"

        [idle.behavior.screen-off]
        enabled = true
        timeout = 660
        action = "screen_off"

        [idle.behavior.suspend]
        enabled = true
        timeout = 1800
        action = "lock_and_suspend"
      '';
    }
  ];
}
