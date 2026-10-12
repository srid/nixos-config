# croissant

OVHcloud dedicated server (RISE-S: Ryzen 7 9700X, 64 GB, 2×512 GB NVMe in
mdadm RAID1), Gravelines. Public IP `37.187.28.109`.

- **Access**: `ssh root@37.187.28.109` (key only, root only). The `srid` user
  is for use over Tailscale.
- **Deploy**: `just activate croissant`.
- **Secrets**: agenix decrypts with the host key `/etc/ssh/ssh_host_ed25519_key`,
  which was generated locally and injected at install time with
  `nixos-anywhere --extra-files`, so its public half could go into
  `secrets/secrets.nix` before the first boot.

## Reinstall

1. OVH panel → server → *Boot* → rescue mode with your SSH key; restart.
2. `nix run github:nix-community/nixos-anywhere -- --flake .#croissant --extra-files <dir-with-etc/ssh/host-key> --no-reboot root@37.187.28.109`
3. OVH panel → *Boot* → boot from hard disk; then `ssh root@... reboot`.

## Gotcha: first boot stuck on `md-name-any:root-part1`

The nixos-anywhere installer kernel can be newer than the kernel croissant
boots. A newer md driver writes `logical_block_size` at byte 224 of the
mdadm v1.2 superblock; older kernels (6.18, OVH's 6.12 rescue) treat those
bytes as padding and refuse the array ("does not have a valid v1.2
superblock"). The initrd then times out waiting for the root device.

Fix from rescue: zero bytes 224..227 of the superblock (sector 8 of each
`*-mdadm` partition) and recompute the checksum (sum of little-endian u32
words over `256 + max_dev*2` bytes with `sb_csum` zeroed, folded to 32 bits),
then `mdadm --assemble --scan`. Once a supported kernel has written the
superblock back, the field stays zero.
