# olai on K3s

Open **http://olai-k3s** from gossamer or another device on the same tailnet
with MagicDNS enabled. For cluster and credential setup, see the
[cluster README](../../README.md).

Olai and its Tailscale proxy run on naiveintent. The container uses the host's
Nix-built olai through a read-only `/nix/store` mount. A local-path PVC preserves
`/data` across restarts; its size request is not a disk quota. `Recreate` updates
stop the old instance before starting another.

The container command uses olai's `lib.webArgs`, shared with its Home Manager module.

The container's PATH includes Git and agent-distro's vanilla `claude` and `codex`
launchers. Their configuration and login state live under `/data` (`HOME`),
separate from the host's. Open an interactive shell with:

```bash
sudo k3s kubectl -n olai-k3s exec -it deployment/olai -- /bin/sh
```

Access is HTTP over Tailscale, without HTTPS or application authentication;
tailnet policy controls who can connect. Allow the intended users/devices to
reach `tag:k8s` on TCP 80. The Machines page should show `olai-k3s`.

## Check access

On naiveintent: `sudo k3s kubectl -n olai-k3s get pods,service,pvc`.
On gossamer: `curl --fail http://olai-k3s/`.
