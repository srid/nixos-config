# Enable hardening.enable for non-root containers with read-only filesystems.
# Writable data needs explicit mounts; /tmp is provided here.
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
    # Wire these pod fields into the app Deployment.
    automountServiceAccountToken = mkOption { type = types.bool; default = true; };
    # Apply to every container, including custom init containers.
    containerSecurityContext = mkOption {
      type = types.attrsOf types.anything;
      default = { };
    };
  };

  config = lib.mkIf cfg.enable {
    # Network policy and access to app credentials are managed separately.
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
