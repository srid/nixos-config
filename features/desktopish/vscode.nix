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
    nodejs-16_x # Need this for https://nixos.wiki/wiki/Vscode server
  ];

  # https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "524288";
  };
}
