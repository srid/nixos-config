# Headless Dropbox via home-manager's services.dropbox.
#
# How the module works: the systemd user service runs the proprietary
# daemon under a FAKE home, ~/.dropbox-hm (inside a bubblewrap FHS env —
# works even in an unprivileged incus container). On first start it
# downloads the real client into ~/.dropbox-hm/.dropbox-dist, so expect
# a few crash-loop restarts until that finishes. The synced folder ends
# up at ~/.dropbox-hm/Dropbox — point consumers there directly (see
# configurations/nixos/myolai/olai.nix).
#
# The `dropbox` CLI must be told about the fake home or it reports
# "Dropbox isn't running!" while the daemon is in fact fine:
#
#   HOME=$HOME/.dropbox-hm dropbox status
#
# One-time account link: `... dropbox status` prints a
# https://www.dropbox.com/cli_link_nonce?nonce=… URL. Nonces are
# single-use, and the page's email-login form is broken under ad
# blockers — sign in to dropbox.com first, then open a FRESH nonce URL
# (re-run status) to get a plain "Connect" confirmation.
#
# Selective sync (imperative state, like the link): exclude every
# top-level folder except the one you want, as soon as folders start
# materializing (re-run to catch stragglers; check `dropbox status`):
#
#   export HOME=$HOME/.dropbox-hm
#   cd ~/Dropbox
#   for d in */; do d=${d%/}; [ "$d" = "MyOlai" ] || dropbox exclude add "$d"; done
#   dropbox exclude list
#
# Excluded folders are deleted locally only; loose top-level files
# still sync (exclude big ones by name if needed).
{
  services.dropbox = {
    enable = true;
  };
}
