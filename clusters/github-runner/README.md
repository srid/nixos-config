# Self-Hosted CI on Macbook Pro

**WARNING: WIP Notes**. Expect final version in nixos.asia as a blog post.

## Approach

While we could use the `nix-darwin` module for Github Runners, we do it the other way. First, create a aarch64-linux NixOS VM (I use Parallels Desktop) and do everything there. Then, setup distributed builds to have the VM do aarch64-darwin builds remotely on the host machine (the Macbook Pro). The former is done buy `./nixos-module.nix`, while the latter is done by `./darwin-module.nix`.

### Facts

- I use 1Password (managed by colmena secrets) to store the GitHUb classic PAT.
- On macOS, go to Remote Login and allow SSH access for the `github-runner` user, or allow for all users; otherwise our Linux VM won't be able to remote build on the Mac.
  - The Linux VM's `/etc/ssh/ssh_host_ed25519_key` is used to authorize itself to connect to the Mac.
- The author has observed the official "linux-builder" to be slow, in comparison to a Parallels VM. Prefer setting up a Parallels VM if you can.

## Usage

- `/systems/darwin.nix` (macOS config)
- `/systems/github-runner.nix` (NixOS Linux VM config)

## See also

- [Zulip notes](https://nixos.zulipchat.com/#narrow/stream/413948-nixos/topic/Self-hosted.20GitHub.20runners)
