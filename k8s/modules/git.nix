# Git identity and a persistent checkout, independent of its transport.
{ config, lib, pkgs, name, ... }:
let
  cfg = config.git;
  inherit (lib) mkOption types;
in
{
  options.git = {
    enable = lib.mkEnableOption "a Git checkout before the app starts";
    url = mkOption { type = types.str; };
    directory = mkOption { type = types.str; };
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
    volumeMounts = [{
      name = "${name}-git";
      mountPath = "${config.home}/.gitconfig";
      subPath = "gitconfig";
      readOnly = true;
    }];
    volumes = [{ name = "${name}-git"; configMap.name = "${name}-git"; }];
    initContainers = [{
      name = "${name}-clone";
      inherit (config) image env volumeMounts;
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
