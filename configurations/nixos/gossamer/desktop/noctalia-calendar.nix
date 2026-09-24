{
  home-manager.sharedModules = [
    {
      # Account identity is selected in Google's browser authorization flow.
      # Tokens stay in Secret Service, outside the Nix store and repository.
      xdg.configFile."noctalia/calendar.toml".text = ''
        [calendar]
        enabled = true
        refresh_minutes = 15

        [calendar.account.google]
        type = "google"
        name = "Google Calendar"

        [control_center.calendar]
        show_events_card = true
      '';
    }
  ];
}
