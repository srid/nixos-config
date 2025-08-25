{ flake, config, ... }:

{
  age.secrets."gmail-app-password" = {
    file = flake.inputs.self + /secrets/gmail-app-password.age;
    owner = "rss2email";
    group = "rss2email";
  };

  programs.msmtp = {
    enable = true;
    setSendmail = true;
    defaults = {
      auth = true;
      tls = true;
      tls_trust_file = "/etc/ssl/certs/ca-certificates.crt";
    };
    accounts.default = {
      host = "smtp.gmail.com";
      port = 587;
      from = "pervasiveproximity@gmail.com";
      user = "pervasiveproximity@gmail.com";
      passwordeval = "cat ${config.age.secrets."gmail-app-password".path}";
    };
  };
}
