# Opt-in container hardening for k8s.apps.<name>.
# Wire automountServiceAccountToken and securityContext into the pod, and
# containerSecurityContext into EVERY container, including init containers.
# SSH/Git init modules already do this; custom containers must do the same.
# Writable state belongs on explicit mounts: the app's home/PVC and this /tmp.
# This limits process privileges, not network access or access to app credentials.
{ config, lib, name, ... }:
let
  cfg = config.hardening;
  inherit (lib) mkOption types;
in
{
  options = {
    hardening = {
      enable = lib.mkEnableOption "non-escalating containers with read-only roots";
      # Disk-backed scratch, discarded with the pod; not persistent app storage.
      tmpSizeLimit = mkOption { type = types.str; default = "1Gi"; };
    };
    automountServiceAccountToken = mkOption { type = types.bool; default = true; };
    containerSecurityContext = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    # Olai and its tools do not need Kubernetes API credentials.
    automountServiceAccountToken = false;
    securityContext.seccompProfile.type = "RuntimeDefault";
    containerSecurityContext = {
      allowPrivilegeEscalation = false;
      capabilities.drop = [ "ALL" ];
      readOnlyRootFilesystem = true;
    };
    volumes = [{ name = "${name}-tmp"; emptyDir.sizeLimit = cfg.tmpSizeLimit; }];
    volumeMounts = [{ name = "${name}-tmp"; mountPath = "/tmp"; }];
  };
}
