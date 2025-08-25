{ ... }:

{
  services.rss2email = {
    enable = true;
    to = "srid@srid.ca";
    interval = "1h"; # Check every hour
    config = {
      digest = true;
      digest-type = "multipart/mixed"; # Put content in email body instead of .eml attachments
      html-mail = true; # Send HTML emails for better formatting
      subject-format = "Daily digest: {feed-title}"; # Better subject line
      use-css = true;
      css = "body { font-family: Arial, sans-serif; line-height: 1.6; } h2 { color: #333; border-bottom: 2px solid #eee; padding-bottom: 5px; } a { color: #007acc; text-decoration: none; }";
      force-from = true; # Only use the configured 'from' address
      name-format = ""; # Don't add feed/author names to From field
    };
    feeds = import ./feeds.nix;
  };
}
