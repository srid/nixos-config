{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    protonvpn-cli
  ];

  security.sudo.extraRules = [
    {
      users = [ "srid" ];
      commands = [
        {
          command = "${pkgs.protonvpn-cli}/bin/protonvpn";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
