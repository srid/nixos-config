{ pkgs, ... }:
let 
  realName = "Sridhar Ratnakumar";
  # IMAP/SMTP settings for standard email servers
  servers = {
    icloud = {
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
    protonmail = {
      imap = {
        host = "127.0.0.1";
        port = 1143;
        tls.enable = true;
        tls.useStartTls = true;
      };
      smtp = {
        host = "127.0.0.1";
        port = 1025;
        tls.enable = true;
      };
    };
  };
in {
  programs.himalaya = {
    enable = true;
    settings = {};
  };
  accounts.email.accounts = {
    proton = servers.protonmail // {
      inherit realName;
      primary = true;
      himalaya.enable = true;
      address = "srid@srid.ca";
      userName = "hey@srid.ca";
      passwordCommand = "cat /Users/srid/.protonmail.password";  # Local only, so I don't care
    };
    icloud = servers.icloud // {
      inherit realName;
      address = "happyandharmless@icloud.com";
      userName = "happyandharmless";
      passwordCommand = "op item get iCloud --fields label=himalaya";
    };
  };
}

