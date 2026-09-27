{ pkgs, lib, ... }:
{
  home-manager.sharedModules = [
    {
      services.voxtype = {
        enable = true;
        package = pkgs.voxtype-vulkan;
        loadModels = [ "medium.en" ];
        settings = {
          hotkey.enabled = false; # Niri owns shortcuts; no raw keyboard access.
          osd.enabled = false; # Use notifications; no separately packaged OSD.
          audio = {
            device = "default";
            max_duration_secs = 120;
          };
          whisper = {
            model = "medium.en";
            language = "en";
            mode = "local";
            threads = 2;
            flash_attention = true;
          };
          output = {
            mode = "type";
            fallback_to_clipboard = true;
            auto_submit = false;
            shift_enter_newlines = true;
            notification = {
              on_recording_start = true;
              on_recording_stop = true;
              on_transcription = false;
            };
          };
        };
      };

      # Inherit Niri's session environment instead of hard-coding its socket.
      systemd.user.services.voxtype = {
        Unit.PartOf = lib.mkForce [ "niri.service" ];
        Unit.After = [ "niri.service" ];
        Install.WantedBy = lib.mkForce [ "niri.service" ];
        # Bound CPU load even if an inference path falls back from the GPU.
        Service.CPUQuota = "200%";
      };

      xdg.configFile."niri/dictation.kdl".text = ''
        binds {
          Mod+D repeat=false { spawn "${pkgs.voxtype-vulkan}/bin/voxtype" "record" "toggle"; }
          Mod+Shift+D repeat=false { spawn "${pkgs.voxtype-vulkan}/bin/voxtype" "record" "cancel"; }
        }
      '';
    }
  ];
}
