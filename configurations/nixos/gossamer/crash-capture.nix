# Crash capture: make the next hard freeze leave evidence.
#
# This machine freezes occasionally (2026-09-22, -09-23, -09-25, -09-29,
# 2026-10-09) and the journal simply stops: an unclean power loss with nothing
# in /sys/fs/pstore, even though efi_pstore is registered here and has captured
# panics before (/var/lib/systemd/pstore/1790117332). NixOS leaves every hook
# off: with panic_on_oops=0 and panic=0 an oops neither reboots nor persists,
# and with soft/hardlockup_panic=0 a lockup is silent. Turn them on so the next
# event becomes a *panic*: efi_pstore writes the dmesg into EFI variables,
# systemd-pstore archives it under /var/lib/systemd/pstore, and the machine
# comes back on its own 30s later instead of sitting there dead.
#
# Deliberately NOT kernel.panic_on_warn: this box throws benign-but-noisy
# warnings on the Thunderbolt teardown path (xhci_pci_remove → pci_disable_device,
# drivers/pci/pci.c:2198), and rebooting on those would be worse than the freeze.
{
  # kdump: the 2026-11-16 crash panicked (28 s from the last journal write to
  # the next boot, matching panic=30) yet wrote no pstore record, so the dmesg
  # that would name the fault was lost. Reserve memory and pre-load the running
  # kernel + initrd as a crash kernel at every boot: a panic — including the
  # lockup panics above, and nmi_watchdog=panic which this module adds —
  # kexecs into it with the dead kernel's memory at /proc/vmcore instead of
  # rebooting blind. The crash boot lands in a rescue shell
  # (`boot.shell_on_fail`); save the dump before rebooting, e.g.
  # `cp /proc/vmcore /var/crash/vmcore-$(date +%s)`, or
  # `makedumpfile -l /proc/vmcore /var/crash/vmcore` to skip free pages.
  boot.crashDump = {
    enable = true;
    reservedMemory = "256M";
  };

  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = 1;
    "kernel.panic" = 30;
    "kernel.hardlockup_panic" = 1;
    "kernel.softlockup_panic" = 1;
  };

  # An unclean power loss keeps only what journald fsynced; the default
  # SyncIntervalSec=5m covers most of the interesting tail. 5s keeps the last
  # moments of the log — the exact window that has been empty on every freeze.
  services.journald.settings.Journal.SyncIntervalSec = "5s";
}
