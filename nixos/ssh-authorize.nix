{ flake, pkgs, lib, ... }:

{
  # Let me login
  users.users =
    let
      people = flake.config.people;
      myKeys = people.users.${people.myself}.sshKeys;
    in
    {
      root.openssh.authorizedKeys.keys = myKeys;
      ${people.myself} = {
        openssh.authorizedKeys.keys = myKeys;
      } // lib.optionalAttrs pkgs.stdenv.isLinux {
        isNormalUser = true;
      };
    };
}
