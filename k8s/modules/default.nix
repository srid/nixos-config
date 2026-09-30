# Composable pod configuration; apps still own their Deployment, PVC and Service.
# Each k8s.apps.<name> is a submodule. Enabled features merge contributions into
# lists; the app must wire manifests and pod fields into its own resources.
# No Deployment is generated here, so storage and lifecycle policy stay with the app.
{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  list = type: mkOption { type = types.listOf type; default = [ ]; };
in
{
  options.k8s.apps = mkOption {
    default = { };
    type = types.attrsOf (types.submodule ({ config, name, ... }: {
      imports = [ ./ssh.nix ./git.nix ./tailscale.nix ./hardening.nix ./network.nix ];
      options = {
        namespace = mkOption { type = types.str; default = name; };
        image = mkOption { type = types.str; };
        home = mkOption { type = types.str; default = "/data"; };
        user = {
          name = mkOption { type = types.str; default = name; };
          uid = mkOption { type = types.ints.positive; default = 1000; };
          gid = mkOption { type = types.ints.unsigned; default = 1000; };
        };
        packages = list types.package;
        env = list types.attrs;
        volumeMounts = list types.attrs;
        volumes = list types.attrs;
        initContainers = list types.attrs;
        manifests = list types.attrs;
        # Features merge pod-level controls with the shared non-root identity.
        securityContext = mkOption { type = types.attrsOf types.anything; default = { }; };
      };
      config = {
        _module.args.pkgs = pkgs;
        env = [
          { name = "HOME"; value = config.home; }
          { name = "PATH"; value = "${lib.makeBinPath config.packages}:/bin:/usr/bin"; }
        ];
        securityContext = {
          runAsNonRoot = true;
          runAsUser = config.user.uid;
          runAsGroup = config.user.gid;
          fsGroup = config.user.gid;
        };
      };
    }));
  };
}
