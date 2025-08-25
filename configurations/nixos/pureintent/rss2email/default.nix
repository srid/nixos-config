{ ... }:

{
  services.rss2email = {
    enable = true;
    to = "srid@srid.ca";
    interval = "1h"; # Check every hour
    config = {
      digest = true;
      digest-type = "multipart/mixed"; # Put content in email body instead of .eml attachments
    };
    feeds = import ./feeds.nix;
  };
}
