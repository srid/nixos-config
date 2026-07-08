# Loosen kernel hardening so LLM agents can debug without sudo.
#
# NixOS defaults `kernel.dmesg_restrict` to 1, so reading the kernel ring
# buffer (`dmesg`) requires CAP_SYSLOG — i.e. sudo. The kernel log is
# read-only, and handing an agent sudo just to tail it is a far bigger
# hammer than the problem. Setting this to 0 lets unprivileged users (and
# the agents running as them) run `dmesg` directly.
{ ... }:
{
  boot.kernel.sysctl."kernel.dmesg_restrict" = 0;
}
