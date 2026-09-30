# Kubernetes

A single-node K3s learning cluster on naiveintent. The host imports
[`default.nix`](default.nix), which enables K3s and lists its components:

- [`tailscale.nix`](tailscale.nix): shared Tailscale operator and agenix credentials.
- [`apps/olai`](apps/olai): olai deployment, persistent storage, and Tailscale HTTPS Ingress.
- [`modules`](modules): composable SSH and Git options for apps.

Add applications under `apps/<name>/default.nix` and import them in `default.nix`.
Apply changes with `just activate` from the repository root in the Nix devShell
on naiveintent. Client devices such as gossamer need no rebuild.

## First-time setup

1. In [Tailscale admin](https://console.tailscale.com/admin/machines), select the
   **tailnet containing gossamer and naiveintent**. OAuth credentials determine
   which tailnet the operator joins.
2. Merge these entries into the policy's `tagOwners`:

   ```json
   "tag:k8s-operator": [],
   "tag:k8s": ["tag:k8s-operator"]
   ```

3. Create an [OAuth client](https://console.tailscale.com/admin/settings/trust-credentials)
   with write access to **General/Services**, **Devices/Core**, and
   **Keys/Auth Keys**, scoped to `tag:k8s-operator`. Each app's README describes
   the access its users need in the tailnet policy.
4. From the repository's Nix devShell, run
   `cd secrets && just edit tailscale-operator-oauth.yaml.age` and save:

   ```yaml
   apiVersion: v1
   kind: Namespace
   metadata:
     name: tailscale
   ---
   apiVersion: v1
   kind: Secret
   metadata:
     name: operator-oauth
     namespace: tailscale
   stringData:
     client_id: "<OAuth client ID>"
     client_secret: "<OAuth client secret>"
   ```

5. From the repository root on naiveintent, in the Nix devShell:

   ```bash
   git add secrets/tailscale-operator-oauth.yaml.age
   just activate
   ```

Agenix decrypts the file using naiveintent's SSH host key. K3s reads the Secret
through a runtime symlink; plaintext stays out of Git and the Nix store.
The Machines page should show `naiveintent-k3s-operator`.

## Update credentials

Edit the same encrypted file, then run `just activate` from the repository root.
Explicitly refresh the Kubernetes Secret before restarting; activation alone
does not reliably refresh credentials through the agenix symlink.

```bash
sudo k3s kubectl apply -f /run/agenix/tailscale-operator-oauth.yaml
sudo k3s kubectl -n tailscale rollout restart deployment/operator
```

## Check the operator

```bash
sudo k3s kubectl -n tailscale get pods
sudo k3s kubectl -n tailscale logs deployment/operator --tail=30
```

If a device is missing from the tailnet, check the selected tailnet and its access
policy. See each app's README for its browser address and app-specific checks.

## Roadmap: 1Password app secrets

Keep agenix for now. As we add apps, use 1Password as the source of app secrets:

- Create a dedicated 1Password vault for Kubernetes secrets, including olai's
  GitHub repo deploy key.
- Give a [service account](https://developer.1password.com/docs/service-accounts/)
  read access to that vault and bootstrap its token through agenix.
- Use External Secrets Operator's
  [1Password SDK provider](https://external-secrets.io/latest/provider/1password-sdk/)
  to synchronize items into Kubernetes Secrets, without a Connect server.
- Keep app modules consuming the same Secrets (such as `olai-ssh`). When migrating,
  replace their agenix provisioning and arrange pod restarts for credentials
  copied by init containers.

The cluster accesses 1Password directly; gossamer's desktop app does not need to
be running, and the laptop can be off.

## Roadmap: app isolation

- Add a reusable hardening module: disable service-account token mounting,
  prevent privilege escalation, drop Linux capabilities, and use `RuntimeDefault`
  seccomp. Make the root filesystem read-only with explicit writable mounts.
- Add NetworkPolicies for required ingress/egress and CPU/memory limits. Choose
  storage with an enforced quota if disk isolation is needed.
- Replace the whole-host `/nix/store` mount with an image containing the app's
  required packages.
- Run agents in separate execution containers with limited mounts and credentials
  when they should not have olai's full access to Vault, Git, and mail.
