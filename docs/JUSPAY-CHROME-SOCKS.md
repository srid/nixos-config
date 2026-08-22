# Chrome through the Juspay jumphost SOCKS (macOS)

Internal hosts like `10.10.68.56` (Grafana, `pu`) are not on the public
internet. From a laptop they are reached through the **jumphost SOCKS5**
tunnel that `programs.jumphost.socks5Proxy` already keeps on
`127.0.0.1:1080`.

`juspay-run` is the CLI version of that: it points `ALL_PROXY` at `:1080` and
wraps the command in proxychains. `jcurl` is the curl one-liner. Chrome needs
its own flag; nixpkgs `google-chrome` is Linux-only, so this is how you do it
on macOS.

```
browser  --proxy-server=socks5://127.0.0.1:1080
              ↓
         jumphost SOCKS   (already running; not `ssh -D`)
              ↓
         idli / internal net
              ↓
         10.10.68.56/grafana/
```

You do **not** run `ssh -fN -D 127.0.0.1:1080 …`. That would fight the
existing launchd tunnel.

## 1. Tunnel up?

```bash
# should succeed (connection refused = tunnel down)
nc -z 127.0.0.1 1080
```

If it is down: unlock 1Password, then:

```bash
launchctl kickstart -k "gui/$(id -u)/org.nix-community.home.jumphost-socks5-proxy"
```

On Linux the equivalent is `systemctl --user restart jumphost-socks5-proxy`.
Same check `juspay-run` prints when `:1080` is dead.

## 2. Open Chrome through the proxy

Installed Chrome, not `nix run nixpkgs#google-chrome`. If Chrome is already
running it **ignores** new flags, so start a **new** instance with a throwaway
profile:

```bash
open -na "Google Chrome" --args \
  --proxy-server="socks5://127.0.0.1:1080" \
  --user-data-dir="$HOME/.chrome-juspay" \
  http://10.10.68.56/grafana/
```

Or the binary:

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --proxy-server="socks5://127.0.0.1:1080" \
  --user-data-dir="$HOME/.chrome-juspay" \
  http://10.10.68.56/grafana/
```

`--proxy-server` is Chrome’s analog of `juspay-run`’s `ALL_PROXY`.
`--user-data-dir` keeps this session off your everyday profile (cookies,
extensions, “Chrome is already running”).

## 3. Same SOCKS, other clients

| Tool | How |
| --- | --- |
| CLI (any binary) | `juspay-run <cmd>` |
| curl | `jcurl …` (`curl --socks5 localhost:1080`) |
| Chrome (macOS) | `--proxy-server=socks5://127.0.0.1:1080` as above |

`10.10.68.56` is `pu` (`PU_HOST` in `modules/home/work/juspay-run.nix`). Swap
the URL for any other host that is only visible behind the jumphost.
