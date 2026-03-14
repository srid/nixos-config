# Fix SSH agent forwarding for long-running sessions (zellij, tmux, etc.)
#
# Problem: SSH agent forwarding creates a new socket path on each connection
# (e.g., /tmp/ssh-XXXXXX/agent.1234). Long-running processes (zellij, daemons)
# have the old SSH_AUTH_SOCK baked in, so they can't auth after reconnect.
#
# Solution: Use a stable symlink that gets updated on each SSH connect.
# Git/ssh read the symlink at execution time, so they always find the current socket.
#
# How it works:
# 1. On each SSH connect to this machine: ~/.ssh/rc updates the symlink
# 2. SSH_AUTH_SOCK points to the symlink path (set in zellij)
# 3. Git/ssh follow the symlink to the current valid socket
#
# Reference: https://stackoverflow.com/a/23187030

{ config, lib, pkgs, ... }:

let
  sshAuthSockLink = "${config.home.homeDirectory}/.ssh/ssh_auth_sock";
in
{
  # Create ~/.ssh/rc to update symlink on each SSH connect
  # This runs on the remote machine when someone SSHs in with agent forwarding
  home.file.".ssh/rc" = {
    executable = true;
    text = ''
      #!/bin/sh
      # Update symlink to current SSH agent socket
      if [ -n "$SSH_AUTH_SOCK" ] && [ "$SSH_AUTH_SOCK" != "${sshAuthSockLink}" ]; then
        ln -sf "$SSH_AUTH_SOCK" "${sshAuthSockLink}"
      fi
    '';
  };

  programs.zellij.settings = {
    # Set stable SSH_AUTH_SOCK for all zellij sessions
    # New panes inherit this, and git/ssh follow the symlink at runtime
    env = {
      SSH_AUTH_SOCK = sshAuthSockLink;
    };
  };
}
