# olai on K3s

Open **http://olai-k3s** from gossamer or another device on the same tailnet
with MagicDNS enabled. No client configuration or rebuild is needed.

Olai and its Tailscale proxy run on naiveintent. The container uses the host's
Nix-built olai; a PVC preserves `/data` across restarts. Updates stop the old
instance before starting another. Access is HTTP over Tailscale, without HTTPS
or application authentication; tailnet policy controls who can connect.

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
   **Keys/Auth Keys**, scoped to `tag:k8s-operator`. Allow your user/devices to
   reach `tag:k8s` on TCP 80 in the tailnet policy.
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
The Machines page should show `naiveintent-k3s-operator` and `olai-k3s`.

## Update credentials

Edit the same encrypted file, then run `just activate` from the repository root.
Explicitly refresh the Kubernetes Secret before restarting: replacing the agenix
symlink did not refresh the live Secret during our credential change.

```bash
sudo k3s kubectl apply -f /run/agenix/tailscale-operator-oauth.yaml
sudo k3s kubectl -n tailscale rollout restart deployment/operator
```

## Check access

On naiveintent: `sudo k3s kubectl -n tailscale get pods`.
For operator errors: `sudo k3s kubectl -n tailscale logs deployment/operator --tail=30`.
On gossamer: `curl --fail http://olai-k3s/`.
If the device is missing, check the selected tailnet and its access policy.

## Remove the earlier Traefik experiment

K3s does not delete resources removed from manifests. After switching to Tailscale,
remove the old route and quota; these commands preserve olai's data:

```bash
sudo k3s kubectl -n olai-k3s delete ingress olai --ignore-not-found
sudo k3s kubectl -n olai-k3s delete resourcequota olai-k3s --ignore-not-found
```
