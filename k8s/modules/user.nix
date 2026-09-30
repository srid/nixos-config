# Shared Unix identity for the app and init containers that need user lookup.
{ config, lib, name, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.user = {
    name = mkOption { type = types.str; default = name; };
    uid = mkOption { type = types.ints.positive; default = 1000; };
    gid = mkOption { type = types.ints.unsigned; default = 1000; };
    # Init containers opt into this mount without inheriting all app mounts.
    volumeMount = mkOption {
      type = types.attrs;
      readOnly = true;
      default = { name = "${name}-user"; mountPath = "/etc/passwd"; subPath = "passwd"; readOnly = true; };
    };
  };
  config = {
    manifests = [{
      apiVersion = "v1";
      kind = "ConfigMap";
      metadata = { inherit (config) namespace; name = "${name}-user"; };
      data.passwd = "root:x:0:0:root:/root:/bin/sh\n${config.user.name}:x:${toString config.user.uid}:${toString config.user.gid}::${config.home}:/bin/sh\n";
    }];
    volumes = [{ name = "${name}-user"; configMap.name = "${name}-user"; }];
    volumeMounts = [ config.user.volumeMount ];
    securityContext = {
      runAsNonRoot = true;
      runAsUser = config.user.uid;
      runAsGroup = config.user.gid;
      fsGroup = config.user.gid;
    };
  };
}
