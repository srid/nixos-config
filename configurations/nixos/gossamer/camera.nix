# Intel hardware ISP and OV08X40 tuning, following Omarchy's Panther Lake stack.
# https://github.com/omacom/omarchy-pkgs/pull/418
{ pkgs, lib, ... }:
{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        omarchyPatch =
          path: hash:
          prev.fetchurl {
            url = "https://raw.githubusercontent.com/omacom/omarchy-pkgs/59732a3e6fc5f158360b480ad38f479faf1f3677/pkgbuilds/${path}";
            inherit hash;
          };
      in
      {
        # Match the binary image-processing libraries to Omarchy's HAL revision.
        ipu7-camera-bins = prev.ipu7-camera-bins.overrideAttrs (_: {
          version = "omarchy-403c67d";
          src = prev.fetchFromGitHub {
            owner = "intel";
            repo = "ipu7-camera-bins";
            rev = "403c67db6b279dd02752f11db6a34552f31a3ac5";
            hash = "sha256-Sj1jBOOegTk8tdmDN06MYEa7KmutnfSb5AEhXhoQkSc=";
          };
        });
        ipu75xa-camera-hal =
          (prev.ipu75xa-camera-hal.override {
            ipu7-camera-bins = final.ipu7-camera-bins;
          }).overrideAttrs
            (old: {
              version = "omarchy-b1f6ebe";
              src = prev.fetchFromGitHub {
                owner = "intel";
                repo = "ipu7-camera-hal";
                rev = "b1f6ebef12111fb5da0133b144d69dd9b001836c";
                hash = "sha256-fz3ALh2F57NWYU6D1XuKfAzES2754GfZr1xQBwfkG3U=";
              };
              # Linux 7.2 inserts Intel CVS between the sensor and IPU7. The HAL
              # must route through that bridge and configure both of its pads.
              patches = (old.patches or [ ]) ++ [
                (omarchyPatch "intel-ipu7-camera/0005-camhal-MediaControl-route-through-Intel-CVS-bridge.patch" "sha256-RoXRaI3RcEUc3VjOjLJYIBL7Mu1MTIkgagCy79fgf0g=")
                (omarchyPatch "intel-ipu7-camera/0006-camhal-ipu75xa-ov08x40-Intel-CVS-formats.patch" "sha256-wyZHihTekMmPfaGxdJZ6VS6dGxSHkTHOoGIyxorqhqE=")
              ];
            });
        # Omarchy's idle-reset fix lets successive browser sessions reopen the
        # loopback camera without leaving the hardware pipeline running idle.
        v4l2-relayd = prev.v4l2-relayd.overrideAttrs (old: {
          version = "0.2.0";
          src = prev.fetchurl {
            url = "https://gitlab.com/vicamo/v4l2-relayd/-/archive/upstream/0.2.0/v4l2-relayd-upstream-0.2.0.tar.gz";
            sha256 = "0c063edf18dcc6edcdef46e695128cfc2b2d60964ea8538c7e79a2454310c53d";
          };
          patchFlags = [ "-p0" ];
          patches = (old.patches or [ ]) ++ [
            (omarchyPatch "v4l2-relayd/0001-reset-output-on-idle.patch" "sha256-B3IqhwjO1I0tuVdfPq5bEmaGjSWdJgY14G6aELrd7Hg=")
            (omarchyPatch "v4l2-relayd/0002-escape-optional-splashsrc-expansion.patch" "sha256-PLiQVq8nbu16Rd/JZDXo5IVY5OEcllYDYNRtYxscC2w=")
          ];
        });
      }
    )
  ];

  # Nixpkgs' PSYS driver already includes Omarchy's bus-registration fix.
  # Keep the in-tree ISYS/CVS drivers and the speaker GPIO fix in dell-xps-16.nix.
  hardware.ipu7 = {
    enable = true;
    platform = "ipu75xa";
  };
  boot.kernelModules = [ "intel_ipu7_psys" ];

  services.v4l2-relayd.instances.ipu7 = {
    cardLabel = "Built-in Front Camera (Intel ISP)";
    input = {
      # Intel's sensor tuning handles exposure, colour and noise reduction;
      # these image controls match Omarchy's tested configuration. The HAL
      # already delivers an upright image on this laptop.
      pipeline = lib.mkForce "icamerasrc device-name=ov08x40-uf sharpness=80 ev=-1 saturation=10";
      width = 3840;
      height = 2160;
      framerate = 30;
    };
    output.format = "NV12";
  };
  systemd.services.v4l2-relayd-ipu7 = {
    after = [ "systemd-modules-load.service" ];
    serviceConfig.RuntimeDirectory = "camera";
    serviceConfig.RestartSec = "3s";
    # exclusive_caps exposes capture only once the relay opens its writer.
    # Refresh udev's capabilities then, so an existing desktop finds the camera.
    postStart = ''
      device=$(cat "$V4L2_DEVICE_FILE")
      for attempt in $(seq 1 50); do
        if ${pkgs.v4l-utils}/bin/v4l2-ctl -d "$device" --get-fmt-video >/dev/null 2>&1; then
          ${pkgs.systemd}/bin/udevadm trigger --action=change "/sys/class/video4linux/$(basename "$device")"
          exit 0
        fi
        sleep 0.1
      done
      echo "Camera relay did not expose a capture format" >&2
      exit 1
    '';
  };
  # Release the HAL before suspend and reopen it after resume, without
  # unloading the CVS driver or disrupting the sensor's media graph.
  systemd.services.camera-sleep = {
    wantedBy = [ "sleep.target" ];
    before = [ "sleep.target" ];
    unitConfig.StopWhenUnneeded = true;
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.systemd}/bin/systemctl stop v4l2-relayd-ipu7.service";
      ExecStop = "${pkgs.systemd}/bin/systemctl --no-block start v4l2-relayd-ipu7.service";
    };
  };

  # Avoid two camera stacks competing for the same sensor. Browsers see the
  # processed V4L2 loopback feed; USB cameras remain available through V4L2.
  services.pipewire.wireplumber.extraConfig."10-camera" = {
    "wireplumber.profiles".main."monitor.libcamera" = "disabled";
  };
  # Hide unprocessed Bayer capture nodes from desktop applications. The root
  # relay can still access them. Do not use WirePlumber's device.disabled rule:
  # it can deadlock audio discovery in WirePlumber 0.5.17 (Omarchy #12720).
  services.udev.packages = [
    (pkgs.writeTextDir "lib/udev/rules.d/71-ipu7-hide-isys.rules" ''
      SUBSYSTEM=="video4linux", ATTR{name}=="Intel IPU7 ISYS Capture *", TAG-="uaccess", TAG-="seat", MODE="0600", GROUP="root"
    '')
  ];
}
