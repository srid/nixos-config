# Kubernetes

Single-node K3s learning clusters, one per host. A host imports
[`default.nix`](default.nix), which enables K3s, and then the apps it runs:

- naiveintent: [`apps/olai`](apps/olai), the olai deployment with persistent
  storage and a Tailscale HTTPS Ingress.
- pureintent: [`apps/odu`](apps/odu), odu's board, CI service, and Nix binary
  cache with a Tailscale HTTPS Ingress.

Shared by every cluster:

- [`tailscale.nix`](tailscale.nix): Tailscale operator and agenix credentials.
- [`modules`](modules): composable SSH, Git, Nix, and 1Password options for apps.
- [`network.nix`](network.nix): host firewall guard for pod traffic.

Add applications under `apps/<name>/default.nix` and import them from the host's
configuration next to `k8s`. Each host sets `k8s.nodeIP` to its Ethernet
address (give it a DHCP reservation); K3s pins the node IP to it and the
1Password operator's egress policy allows the API there. Apply changes with
`just activate <host>` from the repository root in the Nix devShell. Client
devices such as gossamer need no rebuild. Tailnet hostnames (`<host>-k3s-operator`
and each app's Ingress) must stay unique across clusters, so run an app on one
host only.

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

5. From the repository root, in the Nix devShell:

   ```bash
   git add secrets/tailscale-operator-oauth.yaml.age
   just activate <host>
   ```

Agenix decrypts the file using the host's SSH host key; both cluster hosts are
recipients in [`secrets.nix`](../secrets/secrets.nix) and share one OAuth client
and one 1Password token. K3s reads the Secret through a runtime symlink;
plaintext stays out of Git and the Nix store. The Machines page should show
`<host>-k3s-operator`.

## Update credentials

Edit the same encrypted file, then run `just activate <host>` for each cluster.
Explicitly refresh the Kubernetes Secret before restarting; activation alone
does not reliably refresh credentials through the agenix symlink. The `kubectl`
commands below run on the cluster's host.

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

## 1Password app secrets

**1Password → External Secrets Operator → Kubernetes Secrets → app.**

[`modules/onepassword.nix`](modules/onepassword.nix) installs the pinned operator
with the SDK provider, without a Connect server. Apps declare item/field
mappings; only their namespaces may use the shared `Kubernetes` vault. The
read-only service-account token is bootstrapped through agenix using
`secrets/onepassword-token.json.age`. Apps never receive that token. Gossamer
can be off; the cluster talks directly to 1Password. Every cluster uses the
same token, so each can read any item in the `Kubernetes` vault.

Secrets refresh hourly. Source errors retain the last synchronized values;
check `kubectl get externalsecret -A` for failures. Pod restarts are manual after
rotation because environment variables and init-copied files do not reload.
See [olai's instructions](apps/olai/README.md#credentials-and-rotation).

To rotate the bootstrap token, update its encrypted manifest with agenix,
activate, then apply the decrypted file (do not rely on the changed symlink):

```bash
sudo k3s kubectl apply -f /run/agenix/onepassword-token.json
sudo k3s kubectl -n external-secrets rollout restart deployment/external-secrets
```

The operator may reach cluster DNS, the Kubernetes API, and public HTTPS; other
traffic is denied. Its API endpoint allowlist follows this single-node cluster.
Tailscale operator credentials remain on agenix.

## Roadmap: app isolation

Olai enables the reusable [hardening module](modules/hardening.nix): no mounted
service-account token, no privilege escalation, no Linux capabilities,
`RuntimeDefault` seccomp, and read-only roots with explicit writable mounts.
App modules also emit namespace-wide default-deny NetworkPolicies. Olai opts
into cluster DNS, public TCP 80/443 (web), 22 (Git), and 465/587/993 (mail).
Private/LAN, tailnet, cluster, and link-local destinations are excluded. Among
other pods, only olai's Tailscale ingress proxy may initiate connections to its
web port. Kubernetes still permits traffic originating on the local node.
The host firewall blocks pod access to ordinary host services; only cluster
API/kubelet ports remain available for infrastructure, and olai's egress policy
blocks those too. This setup is IPv4-only; no IPv6 egress is allowed.

Remaining work:

- Add CPU/memory limits. Choose
  storage with an enforced quota if disk isolation is needed.
- Replace the whole-host `/nix/store` mount with an image containing the app's
  required packages.
- Run agents in separate execution containers with limited mounts and credentials
  when they should not have olai's full access to Vault, Git, and mail.
