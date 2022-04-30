{ config, pkgs, lib, ... }:

{
  # Let me login
  users.users = {
    root.openssh.authorizedKeys.keys = [ (builtins.readFile ./id_rsa.pub) ];
    srid.openssh.authorizedKeys.keys = [ (builtins.readFile ./id_rsa.pub) ];
  };
}
