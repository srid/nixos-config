# olai on K3s

Open **https://olai-k3s.rooster-blues.ts.net** from gossamer or another device on the same tailnet
with MagicDNS enabled. For cluster and credential setup, see the
[cluster README](../../README.md).

Olai and its Tailscale proxy run on naiveintent. The container uses the host's
Nix-built olai through a read-only `/nix/store` mount. A local-path PVC preserves
`/data` across restarts; its size request is not a disk quota. `Recreate` updates
stop the old instance before starting another.

The app and its init containers run non-root with a read-only root filesystem,
all Linux capabilities dropped, privilege escalation disabled, and the runtime's
default seccomp filter. No Kubernetes API token is mounted. `/data` remains
writable; `/tmp` is disposable scratch. These controls come from
[`hardening.nix`](../../modules/hardening.nix). Agents still share the app's
credentials and data; separate agent execution remains on the
[roadmap](../../README.md#roadmap-app-isolation).

Networking denies everything except cluster DNS, public web/AI APIs (TCP 80/443),
Git SSH (22), Gmail (465/587/993), and inbound HTTP from this app's Tailscale proxy.
Host, LAN, tailnet, other pod, and link-local destinations are blocked for outbound
connections. Public IPv4 destinations are allowed on those ports; IPv6 is denied.

Before olai starts, an init container clones `git@github.com:srid/Vault.git` into
`~/Vault` (`/data/Vault`) if absent. Olai serves that checkout. Existing checkouts
are never pulled, reset, or replaced at startup, preserving local edits and
unpushed commits. A failed first clone is discarded before retrying.

Git uses the name and email from this configuration's `me` settings. Its config,
SSH keys, and agent login files stay outside the vault, so olai's automatic
commits cannot include them. Auto-commit/push policy comes from the vault's
`_olai/Settings.olai`; pushing requires write access on the repo deploy key.

The container command uses olai's `lib.webArgs`, shared with its Home Manager module.

The container's PATH includes Git, OpenSSH, and agent-distro's vanilla `claude`
and `codex` launchers, plus `nix`. Their configuration and login state live under `/data` (`HOME`),
separate from the host's. From the repository root on naiveintent:

```bash
just apps olai shell    # Interactive shell in the app's home directory
just apps olai logs     # Follow application logs
just apps olai status   # Pods, routing, storage, and secret sync
just apps olai restart  # Reload credentials and wait for readiness
```

For host-side tools and unrestricted Nix builds, use `just apps olai host-shell`.
It discovers the Vault's current volume and temporarily bind-mounts it into a
private mount namespace. The shell runs as your host user; Ctrl+D releases the
mount. This is the live Vault: olai can auto-commit your edits, so avoid concurrent
Git operations.

Inside the app, fetch and run cached packages with `nix run nixpkgs#hello` or
`nix shell nixpkgs#jq`. A dedicated, untrusted Nix socket downloads into the host
store; the pod cannot write store files directly. Host builds are disabled, so
packages missing from the configured binary cache cannot be built here.
Downloads share the host's disk and garbage collection.

The Tailscale Ingress manages HTTPS and certificates, forwarding HTTP to the
internal Service. Enable HTTPS certificates in the
[Tailscale DNS settings](https://login.tailscale.com/admin/dns) and allow the
intended users/devices to reach `tag:k8s` on TCP 443. Tailnet policy controls
access; olai has no separate application authentication. Use the full DNS name
for HTTPS, not the short name or IP address. No manual `tailscale serve` is needed.

## Credentials and rotation

The `Kubernetes` vault in 1Password supplies both Secrets via
[`secrets.nix`](secrets.nix):

| Item | Kubernetes Secret | Fields |
|---|---|---|
| `olai-git` (SSH Key) | `olai-ssh` | Private key in OpenSSH format, public key |
| `olai-mail` (Secure Note) | `olai-mail` | `client_id`, `client_secret` |

The GitHub repo deploy key needs write access for automatic pushes. SSH init
copies it into memory-backed storage with private-key mode `0600`, mounted
read-only at `/data/.ssh`. Mail credentials enter the app through environment
references. Neither is copied onto the data PVC.

For Gmail, register the app's HTTPS address plus `/_olai/mail/oauth` as the
Google OAuth redirect URI, then connect Gmail through olai's mail settings.

After changing an item, allow up to an hour for synchronization or request it:

```bash
sudo k3s kubectl -n olai-k3s annotate externalsecret olai-ssh olai-mail force-sync="$(date +%s)" --overwrite
sudo k3s kubectl -n olai-k3s get externalsecret -o 'custom-columns=NAME:.metadata.name,READY:.status.conditions[0].status,SYNCED:.status.refreshTime'
```

Once `SYNCED` reflects the update and both are ready, reload credentials:

```bash
sudo k3s kubectl -n olai-k3s rollout restart deployment/olai
```

See the [cluster README](../../README.md#1password-app-secrets) for bootstrap-token
management.

## Check access

On naiveintent: `sudo k3s kubectl -n olai-k3s get pods,service,ingress,pvc`.
On gossamer: `curl --fail https://olai-k3s.rooster-blues.ts.net/`.

The Ingress ADDRESS field reports the actual HTTPS hostname. When migrating
from the old exposed Service, its proxy must release `olai-k3s` before the
Ingress proxy claims it; check for a suffixed hostname if they overlap.
On first startup, HTTPS can time out while Tailscale obtains its certificate.
The proxy logs in the `tailscale` namespace show `tls-cert-pending`, then
`got cert` when ready. Use HTTPS explicitly; HTTP does not redirect automatically.
