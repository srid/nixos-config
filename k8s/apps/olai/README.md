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
separate from the host's. Open an interactive shell with:

```bash
sudo k3s kubectl -n olai-k3s exec -it deployment/olai -- /bin/sh
```

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

## GitHub repo deploy key

`secrets/olai-ssh.yaml.age` holds the GitHub repo deploy key for
[`srid/Vault`](https://github.com/srid/Vault). Agenix decrypts a Kubernetes Secret
named `olai-ssh` in `olai-k3s`.
An init container copies `id_ed25519` and `id_ed25519.pub` into memory-backed
storage owned by olai; `/data/.ssh` is mounted read-only, with private-key mode
`0600`. The key is not copied onto the data PVC. GitHub's published host key is
pinned in `known_hosts`.

Use the SSH remote `git@github.com:srid/Vault.git`. Register the public key as
a deploy key on that repository; enable write access there if olai should push.

To rotate it, edit the encrypted manifest with
`cd secrets && just edit olai-ssh.yaml.age`. Keep the Namespace document and the
Secret's `stringData.id_ed25519` and `stringData.id_ed25519.pub` entries. Then run
`just activate` from the repository root and refresh the Secret explicitly:

```bash
sudo k3s kubectl apply -f /run/agenix/olai-ssh.yaml
sudo k3s kubectl -n olai-k3s rollout restart deployment/olai
```

The restart reloads the keys into memory. The container's SSH files are managed
by this configuration; change trusted hosts here rather than inside the pod.

## Gmail OAuth

[`mail.nix`](mail.nix) uses `secrets/olai-mail-oauth-client.json.age`, the Google
Web OAuth client JSON. Agenix decrypts it on naiveintent; activation converts it
into a root-only manifest at `/run/olai-mail/secret.json`. K3s supplies its
`client_id` and `client_secret` through Secret references in olai's environment.
Plaintext stays outside Git, the Nix store, and the data PVC.

Register this authorized redirect URI on the Google OAuth client:
`https://olai-k3s.rooster-blues.ts.net/_olai/mail/oauth`.
Then connect Gmail through olai's mail settings.

After editing the encrypted JSON, run `just activate` in the Nix devShell, then:

```bash
sudo k3s kubectl apply -f /run/olai-mail/secret.json
sudo k3s kubectl -n olai-k3s rollout restart deployment/olai
```

## Check access

On naiveintent: `sudo k3s kubectl -n olai-k3s get pods,service,ingress,pvc`.
On gossamer: `curl --fail https://olai-k3s.rooster-blues.ts.net/`.

The Ingress ADDRESS field reports the actual HTTPS hostname. When migrating
from the old exposed Service, its proxy must release `olai-k3s` before the
Ingress proxy claims it; check for a suffixed hostname if they overlap.
On first startup, HTTPS can time out while Tailscale obtains its certificate.
The proxy logs in the `tailscale` namespace show `tls-cert-pending`, then
`got cert` when ready. Use HTTPS explicitly; HTTP does not redirect automatically.
