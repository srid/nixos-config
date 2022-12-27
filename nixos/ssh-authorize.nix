{ config, pkgs, lib, flake, ... }:

{
  # Let me login
  users.users =
    let
      people = flake.config.people;
      myPubKey = people.users.${people.myself}.sshKeyPub;
    in
    {
      root.openssh.authorizedKeys.keys = [
        myPubKey
      ];
      ${people.myself}.openssh.authorizedKeys.keys = [
        myPubKey
      ];
    };
}
