# Kernel audit of kill-family syscalls (SIGTERM/SIGKILL and tkill/tgkill/
# pidfd_send_signal). Records sender pid/uid/comm and target at syscall
# entry — including root, including SIGKILL. Logs: /var/log/audit/
#
# Query: ausearch -k sigterm-audit --start today
{ ... }:
{
  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules =
    let
      # Filter on the signal, else this records every SIGURG the Go runtime
      # sends for async preemption (tailscaled, incusd) and floods the log.
      #
      # The signal's argument index differs per syscall, so the rules have to
      # be split:
      #   kill(pid, sig)                            -> a1
      #   tkill(tid, sig)                           -> a1
      #   pidfd_send_signal(pidfd, sig, info, flags) -> a1
      #   tgkill(tgid, tid, sig)                    -> a2
      rules = sig: key: [
        "-a always,exit -F arch=b64 -S kill -F a1=${toString sig} -k ${key}"
        "-a always,exit -F arch=b64 -S tkill,pidfd_send_signal -F a1=${toString sig} -k sig-audit"
        "-a always,exit -F arch=b64 -S tgkill -F a2=${toString sig} -k sig-audit"
      ];
    in
    rules 15 "sigterm-audit" ++ rules 9 "sigkill-audit";
}
