# Enable git.enable to clone a repository before the app starts.
# Existing checkouts are preserved, including edits and unpushed commits.
{ config, lib, pkgs, name, ... }:
let
  cfg = config.git;
  inherit (lib) mkOption types;
  gitConfigMount = {
    name = "${name}-git";
    mountPath = "${config.home}/.gitconfig";
    subPath = "gitconfig";
    readOnly = true;
  };
in
{
  options.git = {
    enable = lib.mkEnableOption "a Git checkout before the app starts";
    url = mkOption { type = types.str; };
    # Its parent must be a writable mount. Enable ssh separately for SSH remotes.
    directory = mkOption { type = types.str; };
    # Only the checkout storage and transport credentials needed by the clone.
    volumeMounts = mkOption { type = types.listOf types.attrs; default = [ ]; };
    userName = mkOption { type = types.str; };
    userEmail = mkOption { type = types.str; };
  };

  config = lib.mkIf cfg.enable {
    packages = [ pkgs.git ];
    env = [{ name = "GIT_TERMINAL_PROMPT"; value = "0"; }];
    manifests = [{
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = { inherit (config) namespace; name = "${name}-git"; };
      data.gitconfig = lib.generators.toGitINI {
        user.name = cfg.userName;
        user.email = cfg.userEmail;
      };
    }];
    volumeMounts = [ gitConfigMount ];
    volumes = [
      { name = "${name}-git"; configMap.name = "${name}-git"; }
      { name = "${name}-git-store"; hostPath = { path = "/nix/store"; type = "Directory"; }; }
      { name = "${name}-git-tmp"; emptyDir.sizeLimit = "64Mi"; }
    ];
    # Clone gets explicit inputs, never the app's mail/agent environment or Nix socket.
    initContainers = [{
      name = "${name}-clone";
      inherit (config) image;
      env = [
        { name = "HOME"; value = config.home; }
        { name = "PATH"; value = "${lib.makeBinPath [ pkgs.git pkgs.openssh ]}:/bin:/usr/bin"; }
        { name = "GIT_TERMINAL_PROMPT"; value = "0"; }
        { name = "GIT_SSL_CAINFO"; value = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"; }
      ];
      volumeMounts = cfg.volumeMounts ++ [
        config.user.volumeMount
        gitConfigMount
        { name = "${name}-git-store"; mountPath = "/nix/store"; readOnly = true; }
        { name = "${name}-git-tmp"; mountPath = "/tmp"; }
      ];
      securityContext = config.containerSecurityContext;
      command = [
        "/bin/sh"
        "-ec"
        ''
          target=${lib.escapeShellArg cfg.directory}
          if [ ! -e "$target" ] && [ ! -L "$target" ]; then
            checkout=$(mktemp -d ${lib.escapeShellArg "${builtins.dirOf cfg.directory}/.${builtins.baseNameOf cfg.directory}-clone.XXXXXX"})
            trap 'rm -rf "$checkout"' EXIT
            git clone -- ${lib.escapeShellArg cfg.url} "$checkout"
            mv "$checkout" "$target"
          fi
          # Existing edits and unpushed commits belong to the app. Never pull,
          # reset, or replace an existing checkout on restart.
          test -e "$target/.git" || {
            echo "$target exists but is not a Git checkout" >&2
            exit 1
          }
          git -C "$target" rev-parse --verify HEAD >/dev/null
        ''
      ];
    }];
  };
}
