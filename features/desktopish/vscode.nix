{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-vscode-server.nixosModules.system
  ];
  services.auto-fix-vscode-server.enable = true;

  # https://unix.stackexchange.com/q/659901/14042
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    # (vscode-with-extensions.override
    #  { vscodeExtensions = with vscode-extensions; [ ms-vsliveshare.vsliveshare ]; })
    vscode
    nodejs-14_x # Need this for https://nixos.wiki/wiki/Vscode server
  ];
}
