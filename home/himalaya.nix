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
in
{
  home.shellAliases = {
    H = "himalaya";
    Hd = "himalaya message delete";
  };

  programs.himalaya = {
    enable = true;
  };

  accounts.email.accounts = {
    "srid@srid.ca" = iCloudMailSettings // {
      primary = true;
      realName = "Sridhar Ratnakumar";
      address = "happyandharmless@icloud.com";
      aliases = [ "srid@srid.ca" ];
      userName = "happyandharmless";
      passwordCommand = "op read op://Personal/iCloud/himalaya";
      himalaya = {
        enable = true;
        settings.sync.enable = true;
      };
    };
  };
}
