# A server for (remote) development purposes.
{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-vscode-server.nixosModules.system
  ];
  environment.systemPackages = with pkgs; [
    nodejs-16_x # Need this for https://nixos.wiki/wiki/Vscode server
    wget
  ];
  services.auto-fix-vscode-server.enable = true;

  # https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "524288";
  };
}
