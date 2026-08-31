# Kernel audit of kill-family syscalls (SIGTERM/SIGKILL and tkill/tgkill/
# pidfd_send_signal). Records sender pid/uid/comm and target at syscall
# entry — including root, including SIGKILL. Logs: /var/log/audit/
#
# Query: ausearch -k sigterm-audit --start today
{ ... }:
{
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    "-a always,exit -F arch=b64 -S kill -F a1=15 -k sigterm-audit"
    "-a always,exit -F arch=b64 -S kill -F a1=9 -k sigkill-audit"
    # Filter on the signal (a2 here, a1 for kill) — unfiltered, this records
    # every Go-runtime SIGURG preemption from tailscaled/incusd and floods
    # /var/log/audit.
    "-a always,exit -F arch=b64 -S tkill,tgkill,pidfd_send_signal -F a2=15 -k sig-audit"
    "-a always,exit -F arch=b64 -S tkill,tgkill,pidfd_send_signal -F a2=9 -k sig-audit"
  ];
}
