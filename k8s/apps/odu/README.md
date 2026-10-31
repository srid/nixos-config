# odu on K3s

Runs in pureintent's cluster at **https://odu-k3s.rooster-blues.ts.net**. What
stands in front of the board is odu's own sign-in, not the tailnet: the daemon
runs in [server mode](https://odu.kolu.dev/docs/#server-mode), so an anonymous
browser meets a GitHub sign-in page, `/mcp` answers 401 without a token, and
every verb runs as a signed-in person with a role. Public buckets are still read
without an account, and pushes still carry a bucket token.

The Tailscale Ingress is tailnet-only for now. Making it public, a
[Funnel](https://tailscale.com/kb/1223/funnel) (`tailscale.funnel = true` in
[`default.nix`](default.nix)), is the last step, once sign-in has been proven on
the pod. Nothing goes public before the door is configured.

One process serves the board, its CI runs, and a Nix binary cache; there is no
separate nginx. The pod uses the host's Nix-built
[odu](https://github.com/juspay/odu) (PR 134) through the read-only `/nix/store`
mount. A `local-path` PVC holds the run catalog, the auth database, and the
cache's chroot store. The cache is pointed at that chroot store
(`ODU_CACHE_STORE=local?root=/data/cache-store`) rather than the host store, so
unsigned pushes never need a trusted-user grant on the untrusted Nix daemon the
[`nix` module](../../modules/nix.nix) exposes.

## Sign-in

The GitHub App is created by hand; the docs describe the form field by field,
the installation, first sign-in and the root-token bootstrap of roles, and
tokens for machines and agents:
**https://odu.kolu.dev/docs/#server-mode**. Its callback URL is
`https://odu-k3s.rooster-blues.ts.net/auth/github/callback`.

The App's credentials are the `odu-github-app` item in the `Kubernetes`
1Password vault, fields `client_id` and `client_secret`; [`secrets.nix`](secrets.nix)
syncs them to the `odu-github-app` Secret exactly like the root token. The
client ID is environment, the secret a mounted file. `ODU_GITHUB_ALLOW` in
[`default.nix`](default.nix) is the allow-list (`org:<name>`,
`team:<org>/<slug>`, or logins, comma-separated). It starts as the single login
`srid`: a login list needs no App installation, so it proves sign-in on the pod.
`org:juspay` follows once a Juspay org owner installs the App. odu refuses to
start with a partial configuration, so an ingress never fronts an open board.

When the Ingress becomes a Funnel, the tailnet needs two things: Funnel enabled,
and the `funnel` node attribute granted to the operator's proxies in the policy
file:

```json
"nodeAttrs": [{ "target": ["tag:k8s"], "attr": ["funnel"] }]
```

Grant the first owner from the pod, once, with the root token:

```sh
just apps odu shell
odu auth grant <github login> owner --origin http://127.0.0.1:18440
```

## Cache

The root token is the `odu-root-token` item in the `Kubernetes` 1Password vault,
field `token`; [`secrets.nix`](secrets.nix) syncs it to the `odu-root-token`
Secret through External Secrets. On a daemon with a door, granting roles is its
only job. `ODU_PUBLIC_ORIGIN` makes `odu cache create` print the public
substituter URL.

After rotating either item, restart the Deployment: environment variables and
mounted Secret files do not reload, and synchronization is hourly (or force it
on the ExternalSecret).

Create the bucket with `--no-upstream`. The cache normally skips paths signed by
a client-supplied upstream key, and a chroot store starts empty, so a referrer
of glibc would defer forever if the client skipped it:

```sh
just apps odu shell
odu cache create main --no-upstream -o json
odu cache token mint main --write
```

Trust the printed URL and key in a client:

```nix
{
  nix.settings = {
    extra-substituters = [ "https://odu-k3s.rooster-blues.ts.net/cache/main" ];
    extra-trusted-public-keys = [ "main-1:<public key>" ];
  };
}
```

Push from any machine with `odu cache push <url> <path>` or plain
`nix copy --to <url-with-token> <path>`. `ODU_CACHE_TOKEN` supplies the token to
`odu cache push`.

## Operations

From the repository root on any machine that can SSH to pureintent (the
commands run there over SSH, or directly when run on pureintent):

```sh
just apps odu shell    # Interactive shell in the pod
just apps odu logs     # Follow logs
just apps odu status   # Pods, routing, storage, and secrets
just apps odu restart  # Restart the service
just apps odu use      # Print the `main` bucket's substituter URL and key
```

The service is a single writer (SQLite plus a pid gate): one replica with
`Recreate`. The Deployment requests 512 MiB; measured cache peaks are ~330 MiB.
`GET /` is the readiness and liveness probe; to an anonymous probe that is the
sign-in page. Commands run inside the pod (`just apps odu shell`, `just apps
odu use`) are the local owner and need no token.

## Known limits

- The board is a catalog viewer until checkouts and SSH keys exist in the pod;
  `run_start` takes an absolute checkout path on the service host.
- Server-side substitution of upstream references into a non-host store is
  deferred to PR 2; buckets for this chroot store use `--no-upstream`.
- A failed first clone, missing keys, or a stale gate is visible in
  `just apps odu logs`.
