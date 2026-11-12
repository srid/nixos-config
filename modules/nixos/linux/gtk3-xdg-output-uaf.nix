# GTK3's Wayland backend never destroys a monitor's zxdg_output_v1 proxy, whose
# listener carries the monitor as user data. When the compositor removes the
# wl_output global the monitor is finalized and its name freed, yet xdg_output
# events already queued on the wire still reach xdg_output_handle_name() and
# crash in g_free(monitor->name). Any compositor that tears down wl_output on
# display hotplug exposes it; Chrome died this way when the Studio Display
# disconnected and reconnected (2026-10-27).
#
# Backport of upstream commit 692439ec ("monitor/wayland: Don't leak
# zxdg_output_v1 proxy", MR 10014), which is on the gtk-3-24 branch but not in
# the 3.24.52 release this nixpkgs ships.
# https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/10014
{ lib, ... }:
{
  nixpkgs.overlays = [
    (final: prev: {
      gtk3 = prev.gtk3.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/gtk3-xdg-output-uaf.patch ];
      });

      # The patched gtk3 changes gjs, and libsecret 0.21.8 added gjs as a check
      # input for its JS test harness. The substitution therefore misses and the
      # package builds from source, where the D-Bus secret-service suite is
      # flaky: test-collection's /collection/set-label-prop aborts with
      # "recipient disconnected from message bus without replying" (seen
      # 2026-11-12, which failed `just activate` after 20 minutes of rebuilds).
      # Keep the backport, drop the checks for the versions that gained gjs.
      libsecret = prev.libsecret.overrideAttrs (
        old: lib.optionalAttrs (lib.versionAtLeast old.version "0.21.8") { doCheck = false; }
      );
    })
  ];
}
