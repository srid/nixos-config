{ pkgs, ... }:
{
  programs.himalaya = {
    enable = true;
    settings = {};
  };
  accounts.email.accounts = {
    icloud = {
      primary = true;
      himalaya.enable = true;
      address = "srid@srid.ca";
      realName = "Sridhar Ratnakumar";
      userName = "happyandharmless";
      passwordCommand = "op item get iCloud --fields label=himalaya";
      imap = {
        host = "imap.mail.me.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "smtp.mail.me.com";
        port = 587;
        tls.enable = true;
      };
    };
  };
}

