# olai on K3s

Open **http://olai-k3s** from gossamer or another device on the same tailnet
with MagicDNS enabled. For cluster and credential setup, see the
[cluster README](../../README.md).

Olai and its Tailscale proxy run on naiveintent. The container uses the host's
Nix-built olai through a read-only `/nix/store` mount. A local-path PVC preserves
`/data` across restarts; its size request is not a disk quota. `Recreate` updates
stop the old instance before starting another.

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
and `codex` launchers. Their configuration and login state live under `/data` (`HOME`),
separate from the host's. Open an interactive shell with:

```bash
sudo k3s kubectl -n olai-k3s exec -it deployment/olai -- /bin/sh
```

Access is HTTP over Tailscale, without HTTPS or application authentication;
tailnet policy controls who can connect. Allow the intended users/devices to
reach `tag:k8s` on TCP 80. The Machines page should show `olai-k3s`.

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

## Check access

On naiveintent: `sudo k3s kubectl -n olai-k3s get pods,service,pvc`.
On gossamer: `curl --fail http://olai-k3s/`.
