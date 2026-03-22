# Git over SSH on remote machines

Using git (and other SSH operations) on remote machines like `pureintent`, authenticated via 1Password SSH agent on the Mac (`zest`).

## How it works

1. **Mac (zest)**: 1Password provides the SSH agent with keys
2. **SSH connection**: `ssh -A pureintent` forwards the agent
3. **Remote (`~/.ssh/rc`)**: Updates a stable symlink at `~/.ssh/ssh_auth_sock` on each connect (see `modules/home/cli/ssh-agent-forwarding.nix`)
4. **Zellij/tmux**: `SSH_AUTH_SOCK` points to the symlink, so sessions survive reconnects

The weak link: step 2 requires a live SSH connection. When it dies, the socket goes stale and git stops working.

## Automating the persistent connection

Add `autossh` as a launchd agent via home-manager on zest. This keeps a backgrounded SSH connection alive and restarts it on failure.

### home-manager config (Mac side)

```nix
# modules/home/cli/autossh-pureintent.nix
{ pkgs, ... }:
{
  home.packages = [ pkgs.autossh ];

  launchd.agents.autossh-pureintent = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.autossh}/bin/autossh"
        "-M" "0"          # no monitoring port; rely on ServerAlive
        "-N"               # no remote command
        "-A"               # forward agent
        "-o" "ServerAliveInterval=30"
        "-o" "ServerAliveCountMax=3"
        "-o" "ExitOnForwardFailure=yes"
        "pureintent"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "$HOME/Library/Logs/autossh-pureintent/stdout";
      StandardErrorPath = "$HOME/Library/Logs/autossh-pureintent/stderr";
    };
  };
}
```

Then import from `configurations/home/srid@zest.nix`.

> [!NOTE]
> `launchd` doesn't expand `$HOME` in log paths. Use the full literal path (`/Users/srid/Library/Logs/...`) or use `config.home.homeDirectory` in the nix expression.

## Manual fallback

If the autossh connection is down and you need a quick fix in a stale session:

```bash
# Find any active socket with a specific key
export SSH_AUTH_SOCK=$(for sock in ~/.ssh/agent/s.*; do
  SSH_AUTH_SOCK="$sock" ssh-add -l 2>/dev/null | grep -q 'id_ed25519' && echo "$sock" && break
done)
```

## Clean up stale sockets

```bash
for sock in ~/.ssh/agent/s.*; do
  SSH_AUTH_SOCK="$sock" ssh-add -l 2>/dev/null || rm "$sock"
done
```
