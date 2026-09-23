{ pkgs, ... }:
{
  imports = [
    ./restart
    ./session
  ];
  environment.systemPackages = [ pkgs.google-chrome ];
  # Preserve the existing browser defaults when Home Manager owns mimeapps.list.
  home-manager.sharedModules = [
    {
      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/http" = [ "google-chrome.desktop" ];
        "x-scheme-handler/https" = [ "google-chrome.desktop" ];
        "text/html" = [ "google-chrome.desktop" ];
      };
    }
  ];

  # Chrome otherwise selects a different encryption-key store by desktop.
  # Use the existing Plasma wallet in both sessions so cookies stay readable.
  nixpkgs.overlays = [
    (_final: prev: {
      google-chrome = prev.google-chrome.override {
        commandLineArgs = "--password-store=kwallet6";
      };
    })
  ];
}
