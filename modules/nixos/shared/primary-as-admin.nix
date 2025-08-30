# Make flake.config.peope.myself the admin of the machine
{ flake, pkgs, lib, ... }:

{
  # Login via SSH with mmy SSH key
  users.users =
    let
      me = flake.config.me;
      myKeys = [
        me.sshKey
      ];
    in
    {
      root.openssh.authorizedKeys.keys = myKeys;
      ${me.username} = {
        openssh.authorizedKeys.keys = myKeys;
        shell = pkgs.zsh;
      } // lib.optionalAttrs pkgs.stdenv.isLinux {
        isNormalUser = lib.mkDefault true;
        extraGroups = [ "networkmanager" "wheel" ];
      };
    };

  programs.zsh.enable = lib.mkIf pkgs.stdenv.isLinux true;

  security = lib.optionalAttrs pkgs.stdenv.isLinux {
    sudo.execWheelOnly = true;
  };
}
