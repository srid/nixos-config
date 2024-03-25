
# Self-Hosted CI on Macbook Pro

**WARNING: WIP Notes**. Expect final version in nixos.asia as a blog post.

## `github-runner.nix`

Create a classic token, and store it impurely:

```sh
sudo sh -c "echo 'ghp_...' > /run/github-token-ci"
```

Setup github-runner.nix for first time, and then:

```sh
sudo chown _github-runner:_github-runner /run/github-token-ci
```

## Linux Builder

The author has observed the official "linux-builder" to be slow, in comparison to a Parallels VM. Prefer setting up a Parallels VM if you can.

### Via Parallels

- Create new VM, installing NixOS: https://nixos.asia/en/nixos-install-disko
    - Name it parallels-linux-builder`
    - CPU: 6; RAM 16GB; Disk 1TB; Use Rosetta
    - Post install
        - `sudo nano /etc/nixos/configuration.nix` and `services.openssh.enable = true;` and `sudo nixos-rebuild switch`
        - If you are not using disko, you must copy over `hardware-configuration.nix`
- `ssh-copy-id` your keys to both parallels@ and root@
    - `ssh-copy-id -o PubkeyAuthentication=no -o PreferredAuthentications=password  parallels@parallels-linux-builder`
    - `ssh parallels@parallels-linux-builder` and `sudo sh -c 'cp /home/parallels/.ssh/authorized_keys /root/.ssh'`
    - Verify `ssh root@parallels-linux-builder` works.
        - `service gdm stop` (we don't need)
- Adjust the mac host keys

```
j remote-install
```

As root, run `ssh -i /etc/ssh/ssh_host_ed25519_key srid@parallels-linux-builder ` to access it as known host.

### Via linux-builder

See `nix-darwin/linux-builder`. Follow the instructions.

## See also

- [Zulip notes](https://nixos.zulipchat.com/#narrow/stream/413948-nixos/topic/Self-hosted.20GitHub.20runners)
