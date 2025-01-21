{ pkgs, ... }:
{
  imports = [
    ./configuration.nix
  ];


  # Hello world service
  services.nginx = {
    enable = true;
    # Return "Hello World" on / request
    virtualHosts."_" = {
      root = "${pkgs.writeTextDir "index.html" "Hello World"}";
    };
  };
  networking.firewall = {
    allowedTCPPorts = [ 80 ];
  };
}
