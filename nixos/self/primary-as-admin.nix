# Make flake.config.peope.myself the admin of the machine
{ flake, pkgs, lib, ... }:

{
  # Login via SSH with mmy SSH key
  users.users =
    let
      people = flake.config.people;
      myKeys = [ people.users.${people.myself}.sshKey ];
    in
    {
      root.openssh.authorizedKeys.keys = myKeys;
      ${people.myself} = {
        openssh.authorizedKeys.keys = myKeys;
      } // lib.optionalAttrs pkgs.stdenv.isLinux {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
    };

  # Make me a sudoer without password
  security = lib.optionalAttrs pkgs.stdenv.isLinux {
    sudo.execWheelOnly = true;
    sudo.wheelNeedsPassword = false;
  };
}
