{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    protonvpn-cli
    protonvpn-gui
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
