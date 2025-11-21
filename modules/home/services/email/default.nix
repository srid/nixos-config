let
  iCloudMailSettings = {
    imap = {
      host = "imap.mail.me.com";
      port = 993;
    };
    smtp = {
      host = "smtp.mail.me.com";
      port = 587;
      tls.useStartTls = true;
    };
  };
  GmailSettings = {
    imap = {
      host = "imap.gmail.com";
      port = 993;
    };
    smtp = {
      host = "smtp.gmail.com";
      port = 465;
      # tls.useStartTls = true;
    };
  };
in
{
  imports = [
    ./himalaya.nix
    ./thunderbird.nix
  ];
  accounts.email.accounts = {
    "srid@srid.ca" = iCloudMailSettings // {
      primary = true;
      realName = "Sridhar Ratnakumar";
      address = "happyandharmless@icloud.com";
      aliases = [ "srid@srid.ca" ];
      userName = "happyandharmless";
      passwordCommand = "op read op://Personal/iCloud-Apple/home-manager";
    };
    "sridhar.ratnakumar@juspay.in" = GmailSettings // {
      realName = "Sridhar Ratnakumar";
      address = "sridhar.ratnakumar@juspay.in";
      userName = "sridhar.ratnakumar@juspay.in";
      passwordCommand = "op read op://Personal/Google-Juspay/home-manager";
    };
  };
}
