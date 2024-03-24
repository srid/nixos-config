
# Self-Hosted CI on Macbook Pro

**WARNING: WIP Notes**. Expect final version in nixos.asia as a blog post.

## `ci.nix`

Create a classic token, and store it impurely:

```sh
sudo sh -c "echo 'ghp_...' > /run/github-token-ci"
```

Setup ci.nix for first time, and then:

```sh
sudo chown _github-runner:_github-runner /run/github-token-ci
```

## Linux Builder

### Via Paralles

- Setup Ubuntu
    - Rename hostname, let Parallels Tools install
    - Shutdown
- Resize resources
    - Then start the VM
- `ssh-copy-id` your keys to both parallels@ and root@

```
j remote-deploy
```

### Via linux-builder

See `nix-darwin/linux-builder`. Follow the instructions.