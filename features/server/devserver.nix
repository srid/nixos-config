# A server for (remote) development purposes.
{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-vscode-server.nixosModules.system
  ];
  environment.systemPackages = with pkgs; [
    nodejs-14_x # Need this for https://nixos.wiki/wiki/Vscode server
    wget
  ];
  services.auto-fix-vscode-server.enable = true;
}
