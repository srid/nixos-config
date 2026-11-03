# odu on K3s

Runs in pureintent's cluster. Open **https://odu-k3s.rooster-blues.ts.net**
from the tailnet: the Tailscale Ingress is Serve, not Funnel, so the board is
tailnet-only. Bucket domains (below) are public through the Cloudflare tunnel.
The daemon also runs in
[server mode](https://odu.kolu.dev/docs/#server-mode), so an anonymous browser
meets a GitHub sign-in page, `/mcp` answers 401 without a token, and every verb
runs as a signed-in person with a role. Public buckets are still read without an
account, and pushes still carry a bucket token.

One process serves the board, its CI runs, and a Nix binary cache; there is no
separate nginx. The pod uses the host's Nix-built
[odu](https://github.com/juspay/odu) (master) through the read-only `/nix/store`
mount. A `local-path` PVC holds the run catalog, the auth database, and the
cache's objects: each bucket's compressed NARs as files under
`/data/state/cache/objects`. The cache needs no Nix store, so pushes never touch
the untrusted Nix daemon the [`nix` module](../../modules/nix.nix) exposes.

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

Grant the first owner from the pod, once, with the root token:

```sh
just apps odu shell
odu surface auth user_grant --origin http://127.0.0.1:18440 \
  --input '{"rootToken":"'"$ODU_ROOT_TOKEN"'","login":"<github login>","role":"owner"}'
```

`role` is `owner`, `admin` or `member`.

## Bucket domains through Cloudflare

odu's cloudflare row gives a bucket a name of its own, such as
`cache.kolu.dev`. Set a domain on the bucket and odu creates one Cloudflare
Tunnel for this server, routes the name through it, keeps the proxied DNS
record, and runs `cloudflared` as a child of the daemon. The whole walk, from
creating the token to removing a domain, is in odu's docs:
**[A domain for a bucket](https://odu.kolu.dev/cache/#a-domain-for-a-bucket)**.

The tunnel is outbound only. `cloudflared` dials Cloudflare's edge on port 7844
(QUIC over UDP, HTTP/2 over TCP), so the pod's network policy allows those along
with HTTPS. Nothing listens, no port opens on the LAN, and pureintent's address
never appears in DNS. The bucket's name serves only the bucket; the board,
`/mcp` and `/auth` answer 404 there.

The token is the `odu-cloudflare` item in the `Kubernetes` 1Password vault,
field `api_token`. [`secrets.nix`](secrets.nix) syncs it to the `odu-cloudflare`
Secret like the others, and the pod reads it as a mounted file through
`ODU_CLOUDFLARE_API_TOKEN_FILE`. It needs **Zone → DNS → Edit**, **Zone → Zone →
Read** and **Account → Cloudflare Tunnel → Edit**. A missing or inactive token
refuses the row at boot with Cloudflare's own reason.

**The board can go public the same way.** The tunnel carries the server's own
origin, the board, `/mcp` and the websocket, once `ODU_PUBLIC_ORIGIN` names a
host in a zone the token can edit. Today the origin is on `ts.net`, which
Cloudflare cannot route, so the board stays tailnet-only. Moving it means a new
`ODU_PUBLIC_ORIGIN` and the GitHub App's callback following it.

## Cache

The root token is the `odu-root-token` item in the `Kubernetes` 1Password vault,
field `token`; [`secrets.nix`](secrets.nix) syncs it to the `odu-root-token`
Secret through External Secrets. On a daemon with a door, granting roles is its
only job. `ODU_PUBLIC_ORIGIN` makes `bucket_create` answer the public
substituter URL.

After rotating any item, restart the Deployment: environment variables and
mounted Secret files do not reload, and synchronization is hourly (or force it
on the ExternalSecret).

The CLI keeps `odu cache use|login|push`; buckets and tokens are the board's
Cache view or the API verbs, `odu surface cache <verb> --input '{…}' --json`.
Each takes a `rootToken` field. On this daemon the root token alone is refused
("this connection carries no principal"), so run them signed in as an admin
(`odu auth login`) with `"rootToken":""`, as odu's docs show.

A bucket with upstream keys (the default, `cache.nixos.org-1`) does not store
paths that `cache.nixos.org` already signs; its consumers fetch those from
`cache.nixos.org`. `"upstreamKeys": []` makes a bucket store everything it is
pushed. A write token is answered once, as `{token, facts}`:

```sh
odu surface cache bucket_create --json --input \
  '{"rootToken":"","name":"main","public":true,"retentionDays":30,"upstreamKeys":[]}'
odu surface cache token_mint --json --input \
  '{"rootToken":"","bucket":"main","scope":"write"}' | jq -r .token
```

### The `r2` store

A bucket keeps its objects in a store chosen at creation: `local`, the PVC,
or `r2`, the private R2 bucket `odu-test` on account
`dcb5b29c06cda32324ce9924df2b5e86`. odu's walk is
[Keep a bucket on S3](https://odu.kolu.dev/cache/#keep-a-bucket-on-s3).
[`default.nix`](default.nix) writes the declaration to the Nix store and names
it in `ODU_OBJECT_STORES`; it holds no secret.

The keys are the `odu-r2` item in the `Kubernetes` 1Password vault, fields
`access_key_id` and `secret_access_key` (an R2 token scoped to the bucket,
object read and write). [`secrets.nix`](secrets.nix) syncs them to the
`odu-r2` Secret like the others. odu reads one `KEY=value` file per store, so
the `odu-r2-credentials` init container joins the two keys into
`/run/odu/r2/credentials` (tmpfs, owner-only), the store's `credentialsFile`.
A missing key or unreadable file refuses boot with an `odu:` sentence in
`just apps odu logs`.

```sh
odu surface cache bucket_create --json --input \
  '{"rootToken":"","name":"<name>","public":true,"retentionDays":30,"store":"r2"}'
```

(Signed in as an admin, as [above](#cache).)

A store a bucket still names cannot be removed: the cache row refuses to
mount rather than serve 404s.

### Clients

Trust the answered URL and key in a client:

```nix
{
  nix.settings = {
    extra-substituters = [ "https://odu-k3s.rooster-blues.ts.net/cache/main" ];
    extra-trusted-public-keys = [ "main-1:<public key>" ];
  };
}
```

Push from any machine with `odu cache push <bucket> <path>… --origin <origin>`
or plain `nix copy --to <url-with-token> <path>`. `ODU_CACHE_TOKEN` supplies the
token to `odu cache push`.

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
`Recreate`. The Deployment requests 1 GiB with an 8 GiB limit: pulls of large
NARs have pushed it past 2 GiB.
`GET /` is the readiness and liveness probe; to an anonymous probe that is the
sign-in page. `just apps odu use` needs no token (a bucket's URL and key are
public); the admin verbs need a signed-in admin even inside the pod.

## Known limits

- The board is a catalog viewer until checkouts and SSH keys exist in the pod;
  `run_start` takes an absolute checkout path on the service host.
- Upstream skipping is per bucket: with upstream keys a bucket leaves
  `cache.nixos.org`-signed paths to `cache.nixos.org`, and `"upstreamKeys": []`
  stores everything pushed. The switch can be changed later from the board's
  Cache view (**Skip upstream paths**).
- A failed first clone, missing keys, or a stale gate is visible in
  `just apps odu logs`.
