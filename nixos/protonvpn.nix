{ pkgs, flake, ... }:

{
  environment.systemPackages = with pkgs; [
    protonvpn-cli
    protonvpn-gui
  ];

  security.sudo.extraRules = [
    {
      users = [ flake.config.people.myself ];
      commands = [
        {
          command = "${pkgs.protonvpn-cli}/bin/protonvpn";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
