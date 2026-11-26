# pce

MINISFORUM MS-A2 mini workstation/server.

| | |
|---|---|
| CPU | AMD Ryzen 9 9955HX (16C/32T) |
| GPU | Radeon iGPU (amdgpu) |
| RAM | 60 GiB usable (64 GiB, iGPU carve-out) |
| Disk | 1 TB Crucial `CT1000E100SSD8` (`/dev/nvme0n1`) |
| NICs | RTL8125 2.5G (`enp3s0`), Intel I225-V 2.5G (`enp4s0`), dual Intel X710 10G (`enp5s0f0np0`, `enp5s0f1np1`) |
| Wi-Fi/BT | MediaTek MT7921 (`wlp6s0`) |
| Firmware | AMI UEFI 2.90, BIOS 1.03 (2026-04-01), Secure Boot off, TPM2 |

## Disk layout

Adopted from the stock NixOS 26.05 graphical install: GPT with a 1 GiB ESP
(`/boot`, vfat `1DA2-A6F1`) and an unencrypted ext4 root on `nvme0n1p2`
(`86c170f9-dfe7-435d-bacd-47c66c2d6489`). No disk swap; `zramSwap` at 50% RAM.

Reinstalling with LUKS + disko remains possible later (the earlier layout had a
1 GiB ESP and a LUKS `cryptroot` ext4 root).

## Installation

The machine is DHCP at `192.168.2.56` (`enp4s0`). First activation needs one
interactive sudo step; after that `security.sudo.extraRules` in `default.nix`
grants passwordless `nixos-rebuild switch` to `srid`.

```console
just activate pce
```

## After installing

- Log in to Tailscale once: `sudo tailscale up`.
- pce is an odu CI lane (`ci@pce`, via `k8s/odu-lane.nix`); it is reachable by
  the odu pod only after Tailscale is up and the tailnet policy allows
  `tag:k8s` → `pce:22`.
