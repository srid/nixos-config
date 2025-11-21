{
  services.syncthing = {
    enable = true;

    # Optional: Configure settings
    settings = {
      gui = {
        theme = "dark";
        insecureAdminAccess = false;
      };
      options = {
        urAccepted = -1; # Disable usage reporting
        crashReportingEnabled = false;
        announceEnabled = true;
        localAnnounceEnabled = true;
        relaysEnabled = true;
      };
    };
  };
}
