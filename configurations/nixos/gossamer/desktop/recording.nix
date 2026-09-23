{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.kooha ];

  nixpkgs.overlays = [
    (
      _final: prev:
      let
        # Only Kooha's GStreamer source uses this build, not the system daemon.
        # Captured frames have PTS=0; its repeated final buffer gets an absolute
        # timestamp and stalls flushing. Honor do-timestamp for every buffer.
        capturePipewire = prev.pipewire.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./pipewire-source-timestamps.patch ];
        });
      in
      {
        # Kooha 2.3.1 can use a stalled PipeWire clock, leaving its timer at 00:00.
        # Backport the upstream clock/timestamp fix without updating the compositor.
        # https://github.com/SeaDve/Kooha/commit/7e940a9b6e3a5557e271d2fd5ecc6cf079e4f5dc
        kooha = (prev.kooha.override { pipewire = capturePipewire; }).overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./kooha-clock.patch ];
        });
      }
    )
  ];
}
