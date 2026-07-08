# Linux internet issues on pureintent

Notes from debugging an outage on `pureintent`, a NixOS machine with Ethernet as the
primary interface and Wi-Fi as fallback.

## Expected setup

`pureintent` has both interfaces on the same LAN:

| Interface | Role | Example IP | Expected metric |
|-----------|------|------------|-----------------|
| `enp1s0` | Ethernet, primary | `192.168.2.43` | `100` |
| `wlp2s0` | Wi-Fi, fallback | `192.168.2.152` | `600` |
| `tailscale0` | Tailscale tunnel | `100.122.32.106` | table `52` |

The default route should prefer Ethernet:

```bash
ip route get 1.1.1.1
```

Expected result:

```text
1.1.1.1 via 192.168.2.1 dev enp1s0 src 192.168.2.43
```

## Symptoms seen

The machine was reachable over SSH and Tailscale, but internet access from
`pureintent` itself was broken.

Observed behavior:

- `ping 1.1.1.1` failed.
- `curl http://1.1.1.1` timed out before connecting.
- DNS lookups timed out because `/etc/resolv.conf` pointed at Tailscale DNS:

  ```text
  nameserver 100.100.100.100
  ```

- `tailscale status` showed Tailscale was running.
- `tailscale debug prefs` showed no exit node was active:

  ```text
  "RouteAll": false
  "ExitNodeID": ""
  "CorpDNS": true
  ```

- LAN reachability still worked for some peers, e.g. `192.168.2.129`.

This means the issue was not simply "Tailscale stole the route". Normal internet
traffic was still supposed to leave via the LAN gateway.

## Useful triage commands

Run these from another machine:

```bash
ssh pureintent 'ip -br addr; ip route; cat /etc/resolv.conf'
```

Check raw IP connectivity first, before DNS:

```bash
ssh pureintent 'ping -c 2 -W 2 1.1.1.1'
ssh pureintent 'curl -4 -sS --connect-timeout 4 --max-time 8 -o /dev/null -w "exit=%{exitcode} http=%{http_code} remote=%{remote_ip}\n" http://1.1.1.1'
```

Check which interface the kernel would use:

```bash
ssh pureintent 'ip route get 1.1.1.1'
```

Check gateway reachability per interface:

```bash
ssh pureintent 'ping -I enp1s0 -c 2 -W 2 192.168.2.1'
ssh pureintent 'ping -I wlp2s0 -c 2 -W 2 192.168.2.1'
```

Check Tailscale state:

```bash
ssh pureintent 'tailscale status'
ssh pureintent 'tailscale debug prefs'
```

## What fixed it

Ethernet was the preferred default route, but the Ethernet path appeared stale:
the link was up and had a DHCP address, but traffic over that path was not
returning.

Disconnecting Ethernet temporarily proved Wi-Fi was healthy:

```bash
nmcli dev disconnect enp1s0
```

With only Wi-Fi active:

- `ping -I wlp2s0 192.168.2.1` succeeded.
- `ping -I wlp2s0 1.1.1.1` succeeded.
- `curl --interface wlp2s0 http://1.1.1.1` succeeded.

Reconnecting Ethernet restored the primary route:

```bash
nmcli con up "Wired connection 1"
```

After reconnecting:

```text
default via 192.168.2.1 dev enp1s0 metric 100
default via 192.168.2.1 dev wlp2s0 metric 600
```

And:

```bash
ping -c 1 -W 2 1.1.1.1
curl -4 https://github.com
```

both worked.

## NetworkManager settings applied

The wired profile had a bad autoconnect priority:

```text
Wired connection 1  autoconnect-priority -999
drapeau             autoconnect-priority 0
```

This was corrected imperatively:

```bash
nmcli connection modify "Wired connection 1" \
  connection.autoconnect yes \
  connection.autoconnect-priority 100 \
  ipv4.route-metric 100 \
  ipv6.route-metric 100 \
  ipv4.never-default no \
  ipv6.never-default no

nmcli connection modify "drapeau" \
  connection.autoconnect yes \
  connection.autoconnect-priority 0 \
  ipv4.route-metric 600 \
  ipv6.route-metric 600 \
  ipv4.never-default no \
  ipv6.never-default no
```

Verify:

```bash
nmcli -f NAME,TYPE,AUTOCONNECT,AUTOCONNECT-PRIORITY connection show
nmcli -f ipv4.route-metric,ipv6.route-metric connection show "Wired connection 1"
nmcli -f ipv4.route-metric,ipv6.route-metric connection show "drapeau"
```

## NixOS durable fix

Because this is NixOS, the long-term fix should be declarative. At the time of
debugging, `/etc/nixos/configuration.nix` only had:

```nix
networking.networkmanager.enable = true;
```

It did not declare the NetworkManager profiles.

Add the profile priorities and route metrics declaratively, either in
`/etc/nixos/configuration.nix` or the equivalent module in this repo:

```nix
networking.networkmanager.ensureProfiles.profiles = {
  "Wired connection 1" = {
    connection = {
      id = "Wired connection 1";
      type = "ethernet";
      interface-name = "enp1s0";
      autoconnect = true;
      autoconnect-priority = 100;
    };
    ipv4 = {
      method = "auto";
      route-metric = 100;
    };
    ipv6 = {
      method = "auto";
      route-metric = 100;
    };
  };

  drapeau = {
    connection = {
      id = "drapeau";
      type = "wifi";
      interface-name = "wlp2s0";
      autoconnect = true;
      autoconnect-priority = 0;
    };
    ipv4 = {
      method = "auto";
      route-metric = 600;
    };
    ipv6 = {
      method = "auto";
      route-metric = 600;
    };
  };
};
```

If Wi-Fi secrets are managed elsewhere, do not duplicate the Wi-Fi profile. Put
the fallback metric and priority in the existing `drapeau` profile instead.

## Recovery shortcut

If Ethernet is up but internet is broken while Wi-Fi works:

```bash
nmcli dev disconnect enp1s0 && nmcli con up "Wired connection 1"
```

Then verify:

```bash
ip route get 1.1.1.1
ping -c 2 -W 2 1.1.1.1
curl -4 -sS --connect-timeout 4 --max-time 8 https://github.com >/dev/null
```

## Variant: MagicDNS with no upstream resolver

Different outage, similar-looking symptom: `/etc/resolv.conf` again pointed only
at `100.100.100.100`, but this time IP-layer routing was healthy and the cause
was purely DNS.

Symptoms:

- `ping 1.1.1.1` works.
- `ping google.com` fails with `Name or service not known`.
- `getent hosts github.com` returns nothing.
- `*.ts.net` lookups still work (split-DNS route is independent).

Smoking gun in `journalctl -u tailscaled`:

```text
dns: resolver: forward: no upstream resolvers set, returning SERVFAIL
```

And `tailscale dns status` shows:

```text
Resolvers (in preference order):
  (no resolvers configured, system default will be used: see 'System DNS configuration' below)
...
  (failed to read system DNS configuration: Access denied: dns-osconfig dump access denied)
```

What's happening: Tailscale is managing `/etc/resolv.conf` (`accept-dns=true`)
and MagicDNS handles `*.ts.net` via the split-DNS route, but for every other
query it needs an upstream resolver. If the tailnet admin console has no
**Global nameservers** configured, Tailscale tries to fall back to the device's
system DNS — which on NixOS/tailscale 1.98 fails with the `dns-osconfig`
access-denied error above. Result: SERVFAIL for everything non-tailnet.

Fix in the admin console at <https://login.tailscale.com/admin/dns>:

1. Under **Global nameservers**, add an upstream (e.g. Cloudflare `1.1.1.1`).
2. Turn **Override DNS servers ON**. With it off, the global nameserver is only
   used when the device's own OS DNS is readable — which on this host it isn't.

Netmap propagation is near-instant; no daemon restart needed. Verify:

```bash
ssh pureintent 'tailscale dns status | sed -n "/Resolvers/,/Split/p"'
ssh pureintent 'getent hosts github.com && ping -c2 google.com'
```

The "Resolvers (in preference order)" list should now contain the upstream IPs
instead of `(no resolvers configured ...)`.

## Main lesson

When both Ethernet and Wi-Fi are on the same subnet, a stale primary interface can
look superficially healthy: it has carrier, DHCP, ARP entries, and LAN
reachability, but public traffic still times out. Test raw public IPs before DNS,
force tests through each interface, and only then look at Tailscale DNS or exit
node settings.
