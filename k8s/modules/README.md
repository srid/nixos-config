# Reusable app modules

Import this directory in an app's NixOS module and configure `k8s.apps.<name>`:

```nix
{
  imports = [ ../../modules ];
  k8s.apps.example = {
    namespace = "example";
    image = "busybox:1.36.1";
    home = "/data";
    tailscale = {
      enable = true;
      hostname = "example-k3s";
    };
    ssh = {
      enable = true;
      secretName = "example-deploy-key";
      knownHosts = (import ../../known-hosts.nix).github;
    };
    git = {
      enable = true;
      url = "git@github.com:OWNER/REPO.git";
      directory = "/data/repo";
      userName = "Example";
      userEmail = "example@example.com";
    };
  };
}
```

The SSH and Git modules independently contribute packages, environment,
ConfigMaps, volumes, mounts, and init containers. SSH runs before Git. Use the
resulting `manifests`, `env`, `securityContext`, `volumes`, `volumeMounts`, and
`initContainers` in the app's resources; [olai](../apps/olai/default.nix) shows
this wiring. Each app still owns its Deployment, PVC, Service, and secret source.

The Tailscale module contributes an HTTPS Ingress to `manifests`, using the
cluster's Tailscale operator. `hostname` and `serviceName` default to the app name;
`servicePort` defaults to 80. The Service remains internal, without Tailscale
exposure annotations. Enable HTTPS certificates in the tailnet and allow access
to `tag:k8s` on TCP 443. The operator manages the proxy and certificate.
Browse `https://<hostname>.<tailnet>.ts.net`; the Ingress ADDRESS field gives
the assigned name. This app module uses the operator installed by
[`../tailscale.nix`](../tailscale.nix), which owns cluster credentials and Helm setup.

The SSH module expects an existing Secret with `id_ed25519` and
`id_ed25519.pub`. It creates a passwd entry, copies keys into tmpfs as the pod's
non-root user, and mounts them read-only. `user.name` defaults to the app name;
`user.uid` and `user.gid` default to 1000. Known hosts are explicit app policy;
shared public keys live in [`known-hosts.nix`](../known-hosts.nix).

Git config lives outside the checkout. The Git module clones only when absent,
never pulls or resets on restart, and does not change commit/push policy. It
needs a writable mount containing `git.directory`'s parent and an appropriate
transport (enable SSH for SSH remotes). These minimal containers need BusyBox
utilities and `/nix/store`; mount the home with `lib.mkBefore` so it precedes
nested config mounts. Mounts and environment are shared with the Git init step.
