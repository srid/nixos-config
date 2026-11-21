{ pkgs, lib, ... }:
{
  # Records through DRM/KMS and encodes on the GPU with VA-API. The NixOS
  # module installs a setcap'd gsr-kms-server, so monitor capture needs neither
  # an xdg-desktop-portal picker nor a root prompt. Intel's H.264 encoder caps
  # out at 4096 px wide, so the 5K Studio Display records HEVC at native
  # resolution (or H.264 scaled to 4K).
  programs.gpu-screen-recorder = {
    enable = true;
    gtk.enable = true;
  };

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

      # gpu-screen-recorder-gtk owns this file at runtime, so seed it once
      # instead of symlinking it from the store (the app rewrites the file on
      # every settings change). HEVC is required above 4096 px wide on Intel.
      home.activation.gsrDefaults = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        gsr_config="$HOME/.config/gpu-screen-recorder/config"
        if [[ ! -e "$gsr_config" ]]; then
          mkdir -p "$(dirname "$gsr_config")"
          cat > "$gsr_config" <<'EOF'
main.codec hevc
main.fps 60
main.quality very_high
main.audio_codec aac
main.audio_input device:Default output
EOF
        fi
      '';
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
