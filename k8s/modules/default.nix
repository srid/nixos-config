# Shared pod configuration for k8s.apps.<name>.
# Feature modules contribute fields; each app owns its Kubernetes resources.
{ lib, pkgs, ... }:
let
  inherit (lib) mkOption types;
  list = type: mkOption { type = types.listOf type; default = [ ]; };
in
{
  imports = [ ./nix.nix ./onepassword.nix ];

  options.k8s.apps = mkOption {
    default = { };
    type = types.attrsOf (types.submodule ({ config, name, ... }: {
      imports = [ ./ssh.nix ./git.nix ./tailscale.nix ./hardening.nix ./network.nix ./user.nix ];
      options = {
        namespace = mkOption { type = types.str; default = name; };
        image = mkOption { type = types.str; };
        home = mkOption { type = types.str; default = "/data"; };
        packages = list types.package;
        env = list types.attrs;
        volumeMounts = list types.attrs;
        volumes = list types.attrs;
        initContainers = list types.attrs;
        manifests = list types.attrs;
        # Features contribute policy; the app wires these fields into its pods.
        automountServiceAccountToken = mkOption { type = types.bool; default = true; };
        containerSecurityContext = mkOption { type = types.attrsOf types.anything; default = { }; };
        securityContext = mkOption { type = types.attrsOf types.anything; default = { }; };
      };
      config = {
        _module.args.pkgs = pkgs;
        env = [
          { name = "HOME"; value = config.home; }
          { name = "PATH"; value = "${lib.makeBinPath config.packages}:/bin:/usr/bin"; }
        ];
      };
    }));
  };
}
