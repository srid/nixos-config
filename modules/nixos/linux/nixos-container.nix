{ lib, config, ... }:

let
  localAddress = (builtins.head (builtins.head (lib.attrValues config.networking.interfaces)).ipv4.addresses).address;
in
{
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-+" ];
    externalInterface = "eth0";
  };

  # Proof-of-concept hello world container
  #
  # $ sudo nixos-container root-login hello
  # > hello
  containers.hello = {
    inherit localAddress;
    autoStart = true;
    hostAddress = "192.168.100.10";
    config = { config, pkgs, ... }: {
      environment.systemPackages = with pkgs; [
        hello
      ];
      #services.resolved.enable = true;
      #networking.useHostResolvConf = lib.mkForce false;
      system.stateVersion = "23.11";
    };
  };
}
