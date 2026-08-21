# GitHub login in front of Caddy

When Caddy is on the public internet, put **oauth2-proxy** in front of it and
allow a short list of GitHub usernames. Anyone can hit the URL; only those
accounts get through.

```
internet → public HTTPS :443 → oauth2-proxy :4180 → Caddy :8080
                                 GitHub OAuth
                                 allow: listed usernames
```

Caddy keeps serving the site. The proxy is the lock.

Encrypt Client ID, Client Secret, and the cookie secret with **agenix** (same
pattern as `hedgedoc.env.age`). The username allowlist can live in Nix.

## 1. Create a GitHub OAuth App

1. Open [GitHub Developer settings → OAuth Apps](https://github.com/settings/developers) → **New OAuth App**.
2. Fill in (use the public URL of the site):
   - **Application name:** anything
   - **Homepage URL:** `https://<public-host>/`
   - **Redirect URI** (under **Redirect URIs**; GitHub used to call this
     “Authorization callback URL”): `https://<public-host>/oauth2/callback`
     Leave **Allow wildcard matching** and **Enable Device Flow** unchecked.
3. Register, then **Generate a new client secret**.
4. Save **Client ID** and **Client Secret**. The secret is shown once.

You also need the allowed GitHub **usernames** (login names, not emails).

## 2. Encrypt the secrets with agenix

oauth2-proxy reads an env file. Store it as `secrets/oauth2-proxy.env.age`,
like HedgeDoc’s `hedgedoc.env.age`.

### Recipients

`secrets/secrets.nix` lists who can decrypt. Add the new file next to the
others, with the same `users ++ systems` keys:

```nix
"oauth2-proxy.env.age".publicKeys = users ++ systems;
```

If the machine that will *run* oauth2-proxy is not already a recipient, do this
once on that host, then add the **public** key to `users` (or `systems`) and
`just rekey` from `secrets/`:

```bash
# on the host, if ~/.ssh/agenix does not exist
ssh-keygen -t ed25519 -f ~/.ssh/agenix -C agenix -N ""
cat ~/.ssh/agenix.pub
```

Home-manager decrypts with `~/.ssh/agenix` (`modules/home/agenix.nix`). Without
that identity in `secrets.nix`, activation cannot decrypt.

### File contents

From the repo, with `~/.ssh/agenix` available:

```bash
cd secrets
just edit oauth2-proxy.env.age
```

Paste:

```
OAUTH2_PROXY_CLIENT_ID=...
OAUTH2_PROXY_CLIENT_SECRET=...
OAUTH2_PROXY_COOKIE_SECRET=...
```

Cookie secret must be 16, 24, or 32 bytes:

```bash
openssl rand -base64 32
```

Commit `oauth2-proxy.env.age` and `secrets.nix`. Never commit the plaintext.

## 3. Run Caddy on localhost only

Caddy should listen on `127.0.0.1:8080` (or any high port), not on the public
interface. A minimal Caddyfile:

```
{
  admin off
  auto_https off
}

:8080 {
  bind 127.0.0.1
  root * /path/to/site
  encode gzip
  file_server
}
```

home-manager user service sketch:

```nix
systemd.user.services.caddy = {
  Unit = {
    Description = "Caddy web server";
    After = [ "network.target" ];
  };
  Service = {
    ExecStart = "${pkgs.caddy}/bin/caddy run --config ${caddyfile} --adapter caddyfile";
    Restart = "on-failure";
    RestartSec = "2s";
  };
  Install.WantedBy = [ "default.target" ];
};
```

## 4. Add oauth2-proxy

- Import `modules/home/agenix.nix`.
- Decrypt `oauth2-proxy.env.age` to a **literal** path (systemd `EnvironmentFile`
  does not expand `$XDG_RUNTIME_DIR`).
- Add `pkgs.oauth2-proxy` and the user service. Replace the public URL and
  GitHub usernames.

```nix
{ pkgs, flake, config, ... }:
{
  imports = [
    (flake.inputs.self + /modules/home/agenix.nix)
  ];

  age.secrets."oauth2-proxy.env" = {
    file = flake.inputs.self + /secrets/oauth2-proxy.env.age;
    path = "${config.home.homeDirectory}/.config/agenix/oauth2-proxy.env";
  };

  home.packages = [
    pkgs.caddy
    pkgs.oauth2-proxy
  ];

  systemd.user.services.oauth2-proxy = {
    Unit = {
      Description = "oauth2-proxy (GitHub login)";
      After = [ "network.target" "caddy.service" ];
      Requires = [ "caddy.service" ];
    };
    Service = {
      EnvironmentFile = config.age.secrets."oauth2-proxy.env".path;
      ExecStart = ''
        ${pkgs.oauth2-proxy}/bin/oauth2-proxy \
          --provider=github \
          --email-domain=* \
          --github-user=alice \
          --github-user=bob \
          --github-user=carol \
          --redirect-url=https://<public-host>/oauth2/callback \
          --upstream=http://127.0.0.1:8080 \
          --http-address=127.0.0.1:4180 \
          --reverse-proxy=true \
          --cookie-secure=true \
          --cookie-samesite=lax
      '';
      Restart = "on-failure";
      RestartSec = "2s";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
```

`--email-domain=*` is required with `--github-user`: GitHub emails are often
private/`noreply`, so domain checks are useless. The allowlist is the usernames.

Leave Caddy on `:8080`. Point public HTTPS at **4180**, not 8080.

## 5. Activate and check the units

Activate the home config, then:

```bash
systemctl --user is-active caddy oauth2-proxy
```

Both should be `active`. If oauth2-proxy fails:

```bash
journalctl --user -u oauth2-proxy -e -n 50
```

Typical causes: agenix decrypt failed (`~/.ssh/agenix` missing or not a
recipient), wrong cookie-secret length, or port 4180 already taken.

## 6. Point public HTTPS at oauth2-proxy

Whatever terminates public TLS must proxy to `127.0.0.1:4180`, not Caddy.

With Tailscale Funnel:

```bash
sudo tailscale funnel --https=443 off
sudo tailscale funnel --bg 4180
tailscale funnel status
```

Expected:

```text
https://<public-host> (Funnel on)
|-- / proxy http://127.0.0.1:4180
```

Caddy stays local-only. The public URL still works, now behind GitHub login.

If Funnel (or any other reverse proxy) still targets 8080, auth is skipped.

## 7. Check it

In a private browser window:

1. Open `https://<public-host>/`
2. GitHub login should appear.
3. An allowed account sees the site.
4. Any other GitHub account is denied after login.

Local bypass (no GitHub), on the host only:

```bash
curl -sS -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8080/
# 200 — Caddy itself is unauthenticated on localhost
```

The public URL without a session should redirect to GitHub, not return the site.

## 8. Change who can log in

Edit the `--github-user=` flags and re-activate the home config. No Funnel
change needed.

Rotate GitHub client secret or cookie secret with:

```bash
cd secrets
just edit oauth2-proxy.env.age
```

Then re-activate the home config. Rotating the cookie secret signs everyone out.

## Notes

- **Why a proxy.** Caddy has no built-in GitHub allowlist. oauth2-proxy is the
  small, usual layer for this. Caddy security plugins, Authentik, and Keycloak
  all work and are more moving parts than a few GitHub users need.
- **Serve vs Funnel.** Tailscale Serve is tailnet-only (no GitHub needed).
  Funnel is public; that is why this proxy exists.
- **Linger.** systemd user services only stay up after logout if lingering is
  on: `sudo loginctl enable-linger $USER`.
