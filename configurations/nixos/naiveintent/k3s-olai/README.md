# olai on K3s

Open **http://olai-k3s** from a device using this tailnet's MagicDNS, including
gossamer. The full name is **http://olai-k3s.rooster-blues.ts.net**.
The Tailscale operator creates a proxy device for the olai Service; both the
proxy and olai run on naiveintent. No client hosts entries or custom DNS are
needed. This exposes HTTP over the encrypted tailnet; HTTPS is not configured.

The example runs the host's Nix-built olai in a BusyBox container. A local-path
PVC preserves `/data` across pod replacements. Its requested size is not a disk
quota. `Recreate` updates stop the old instance before starting its replacement.

## One-time Tailscale setup

Follow the [operator installation guide](https://tailscale.com/docs/kubernetes-operator/install-operator)
to configure these tag owners in the existing tailnet policy:

```json
"tagOwners": {
  "tag:k8s-operator": [],
  "tag:k8s": ["tag:k8s-operator"]
}
```

Create an OAuth client with write permissions for **General/Services**,
**Devices/Core**, and **Keys/Auth Keys**, scoped to `tag:k8s-operator`.
Ensure the tailnet policy permits your user/devices to reach `tag:k8s` on TCP 80.
Olai has no application authentication, so this policy controls tailnet access.

With K3s running on naiveintent, create the credentials Secret outside Nix.
Save the client ID and secret as two private files (without trailing newlines),
then run, substituting their paths:

```bash
sudo k3s kubectl create namespace tailscale --dry-run=client -o yaml \
  | sudo k3s kubectl apply -f -
sudo k3s kubectl -n tailscale create secret generic operator-oauth \
  --from-file=client_id=/path/to/client-id \
  --from-file=client_secret=/path/to/client-secret \
  --dry-run=client -o yaml | sudo k3s kubectl apply -f -
```

Remove the temporary credential files after importing them. The Secret persists
in the cluster; never put these credentials in a Nix expression or Git.

Run `just activate` in the Nix devShell on naiveintent. K3s installs the pinned
operator chart and applies the olai manifest. On a fresh host, activate first
to start K3s, then create the Secret; the operator waits for it automatically.

## Migrating the earlier experiment

After activation, remove the old olai Ingress if it was deployed. K3s does not
delete resources merely because they disappeared from an auto-deploy manifest.
Also remove the earlier ResourceQuota, which required resource limits omitted
from this minimal example. These commands preserve the PVC and its data:

```bash
sudo k3s kubectl -n olai-k3s delete ingress olai --ignore-not-found
sudo k3s kubectl -n olai-k3s delete resourcequota olai-k3s --ignore-not-found
```

## Verify

```bash
sudo k3s kubectl -n tailscale rollout status deployment/operator --timeout=180s
sudo k3s kubectl -n olai-k3s rollout status deployment/olai --timeout=180s
sudo k3s kubectl -n tailscale get pods
sudo k3s kubectl -n olai-k3s describe service olai
```

The Tailscale Machines page should show `naiveintent-k3s-operator` and `olai-k3s`.
From gossamer, run `curl --fail http://olai-k3s/`, then open it in the browser.
