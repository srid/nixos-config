# System-level Nix garbage collection + store optimisation.
#
# The home-manager `nix.gc` (modules/home/nix/gc.nix) runs as the user, so it
# can prune the *user* profile and collect the store, but it can never touch
# the root-owned `system-*` profile generations. Without a system-level GC,
# those pile up unbounded — pureintent accumulated ~480 system generations
# (~4 months of daily rebuilds), each pinning a full closure and keeping old
# kernels/packages from ever being collected. This prunes them; auto-optimise
# hardlinks identical files across the closures that remain.
{ ... }:
{
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.settings.auto-optimise-store = true;
}
