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

In the Nix devShell, use the existing secrets workflow:

```bash
cd secrets
just edit tailscale-operator-oauth.yaml.age
```

Enter this manifest with the real OAuth values in the editor:

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

The recipient list includes naiveintent's SSH host key. Add the encrypted `.age`
file to Git so the flake includes it, then run `just activate` in the Nix devShell
on naiveintent. Agenix decrypts it as root under `/run/agenix`; K3s reads it through
an auto-deploy symlink. Plaintext never enters the Nix store. Without the encrypted
file, evaluation warns and the operator waits for its Secret.

To rotate credentials, edit the same encrypted file and activate again. Once K3s
has updated the Secret, restart the operator to reload the credentials:

```bash
sudo k3s kubectl -n tailscale rollout restart deployment/operator
```

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
