# A server for (remote) development purposes.
{ pkgs, inputs, ... }: {
  imports = [
    inputs.nixos-vscode-server.nixosModules.system
  ];
  environment.systemPackages = [
    # https://old.reddit.com/r/NixOS/comments/uoklud/nix_development_container/i8hn64w/?context=2
    (pkgs.writeShellApplication {
      name = "fix-vscode-server";
      text = ''
        if [[ -d "$HOME/.vscode-server/bin" ]]; then
          for versiondir in "$HOME"/.vscode-server/bin/*; do
            echo "!! Fixing $versiondir/node"
            ln -sf "${pkgs.nodejs-16_x}/bin/node" "$versiondir/node"
          done
        fi
      '';
    })
  ];
  # FIXME: This doesn't seem to work; hence the fix-vscode-server above.
  services.auto-fix-vscode-server.enable = true;

  # https://code.visualstudio.com/docs/setup/linux#_visual-studio-code-is-unable-to-watch-for-file-changes-in-this-large-workspace-error-enospc
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = "524288";
  };
}
