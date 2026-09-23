{ pkgs, ... }:
{
  imports = [ ./restart ];
  environment.systemPackages = [ pkgs.google-chrome ];

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
