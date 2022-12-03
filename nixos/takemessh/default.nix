{ config, pkgs, lib, flake, ... }:

{
  # Let me login
  users.users = {
    root.openssh.authorizedKeys.keys = [ (builtins.readFile ./id_rsa.pub) ];
    ${flake.config.people.myself}.openssh.authorizedKeys.keys = [ (builtins.readFile ./id_rsa.pub) ];
  };
}
