# odu on K3s

Runs in pureintent's cluster. Open **https://odu-k3s.rooster-blues.ts.net**
from a tailnet device. One process
serves the board, its CI runs, and a Nix binary cache; there is no separate
nginx. The Tailscale Ingress is the only way in, so the tailnet policy is the
authentication boundary: the board and `/mcp` have none in this release, and
anyone who can reach them can start and cancel runs. Cache administration still
requires the root token.

The pod uses the host's Nix-built [odu](https://github.com/juspay/odu) (PR 133)
through the read-only `/nix/store` mount. A `local-path` PVC holds the run
catalog and the cache's chroot store. The cache is pointed at that chroot store
(`ODU_CACHE_STORE=local?root=/data/cache-store`) rather than the host store, so
unsigned pushes never need a trusted-user grant on the untrusted Nix daemon the
[`nix` module](../../modules/nix.nix) exposes.

## Cache

The root token is the `odu-root-token` item in the `Kubernetes` 1Password vault,
field `token`; [`secrets.nix`](secrets.nix) syncs it to the `odu-root-token`
Secret through External Secrets. `ODU_PUBLIC_ORIGIN` makes `odu cache create`
print the tailnet substituter URL.

After rotating the item, restart the Deployment: environment variables do not
reload, and synchronization is hourly (or force it on the ExternalSecret).

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
`GET /` is the readiness and liveness probe.

## Known limits

- The board is a catalog viewer until checkouts and SSH keys exist in the pod;
  `run_start` takes an absolute checkout path on the service host.
- Server-side substitution of upstream references into a non-host store is
  deferred to PR 2; buckets for this chroot store use `--no-upstream`.
- A failed first clone, missing keys, or a stale gate is visible in
  `just apps odu logs`.
