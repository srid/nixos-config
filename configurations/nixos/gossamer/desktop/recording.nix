{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.kooha ];

  home-manager.sharedModules = [
    ({ lib, ... }: {
      dconf.settings."io/github/seadve/Kooha" = {
        profile-id = "mp4";
        framerate = lib.hm.gvariant.mkTuple [
          60
          1
        ];
      };
    })
  ];

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
          # MP4 needs h264parse; use AAC rather than the stock MP3 audio for
          # browser/social-media compatibility. Keep the native capture size.
          buildInputs = old.buildInputs ++ [
            prev.gst_all_1.gst-plugins-bad
            prev.gst_all_1.gst-libav
          ];
          # Constant quality preserves detail without a fixed bitrate budget.
          # Keep ultrafast encoding for native-resolution, 60 fps capture.
          postPatch = (old.postPatch or "") + ''
            substituteInPlace data/resources/profiles.yml \
              --replace-fail 'lamemp3enc' 'avenc_aac bitrate=192000' \
              --replace-fail 'mpegaudioparse' 'aacparse' \
              --replace-fail 'x264enc qp-max=17' 'x264enc pass=qual quantizer=17'
          '';
        });
      }
    )
  ];
}
