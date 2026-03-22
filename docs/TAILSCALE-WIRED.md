# Tailscale & Network Interface Selection on pureintent

pureintent has both ethernet (`enp1s0`) and wifi (`wlp2s0`) enabled on the same LAN subnet (192.168.2.0/24). Linux uses **route metrics** to decide which interface handles outbound traffic — lower metric = lower cost = preferred.

## Interface Overview

| Interface | Type | IP | Metric | Tailscale IP |
|-----------|------|------|--------|--------------|
| enp1s0 | Ethernet | 192.168.2.43 | 100 | — |
| wlp2s0 | WiFi | 192.168.2.134 | 600 | — |
| tailscale0 | Tunnel | 100.122.32.106 | — | 100.122.32.106 |

## How It Works

When multiple default routes exist, the kernel picks the one with the **lowest metric**. NetworkManager assigns ethernet a lower metric (100) than wifi (600) by default.

This means:
- **Ethernet is always preferred** when both are connected.
- Tailscale peers connecting remotely (e.g. from a coffee shop) reach pureintent via its Tailscale IP. The Tailscale daemon (`tailscaled`) sends/receives its tunnel traffic (WireGuard UDP) through the default route — **ethernet**.
- If ethernet is unplugged, the kernel automatically falls back to wifi (next lowest metric).

## Routing Table

```
default via 192.168.2.1 dev enp1s0 proto dhcp src 192.168.2.43 metric 100
default via 192.168.2.1 dev wlp2s0 proto dhcp src 192.168.2.134 metric 600
```

Both routes point to the same gateway (192.168.2.1), but the metric decides which wins.

## Connection Types

When a remote peer runs `tailscale ping`, the response reveals the connection type:

- **Direct** (`via <ip>:<port>`) — UDP hole-punch succeeded; traffic flows peer-to-peer. Low latency (~4ms on LAN).
- **DERP relay** (`via DERP(xxx)`) — NAT traversal failed; traffic is relayed through Tailscale's servers. Higher latency.

Example direct connection:
```
pong from pureintent (100.122.32.106) via 192.168.2.43:41641 in 4ms
```

The `192.168.2.43` confirms traffic is arriving on the ethernet interface.

## Verification Commands

```bash
# Check which interface a Tailscale connection uses
tailscale ping <tailscale-ip>

# View route metrics (lower = preferred)
ip route

# See real-time per-interface byte counters
ip -s link show enp1s0
ip -s link show wlp2s0

# Watch live traffic on a specific interface
iftop -i enp1s0

# Check Tailscale peer status (direct vs relayed)
tailscale status

# Inspect active Tailscale connections
ss -tunp | grep tailscale
```

## References

- [Route Priorities - Metric Values](https://www.marcusfolkesson.se/blog/route-metric-values/)
- [Linux Routing Fundamentals](https://blog.sdn.clinic/2025/01/linux-routing-fundamentals/)
