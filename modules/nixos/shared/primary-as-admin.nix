# Make flake.config.me the admin of the machine
{ flake, pkgs, lib, ... }:

{
  # Login via SSH with my SSH key
  users.users =
    let
      me = flake.config.me;
      isLinux = pkgs.stdenv.hostPlatform.isLinux;
      myKeys = [ me.sshKey ];
    in
    {
      root.openssh.authorizedKeys.keys = myKeys;
      ${me.username} = {
        openssh.authorizedKeys.keys = myKeys;
        shell = if isLinux then pkgs.bash else pkgs.zsh;
      } // lib.optionalAttrs isLinux {
        isNormalUser = lib.mkDefault true;
        extraGroups = [ "networkmanager" "wheel" ];
      };
    };

  programs.zsh.enable = lib.mkIf pkgs.stdenv.hostPlatform.isLinux true;

  security = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
    sudo.execWheelOnly = true;
  };
}
