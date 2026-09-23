# Dell XPS 16 DA16260 (2026), Intel Panther Lake.
{ flake, ... }:

{
  imports = [ flake.inputs.nixos-hardware.nixosModules.common-gpu-intel ];
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  hardware.intelgpu = {
    # Panther Lake uses Xe rather than the module's default i915 driver.
    driver = "xe";
    # Modern Intel GPUs use iHD for VA-API video acceleration; omit legacy i965.
    vaapiDriver = "intel-media-driver";
    # Xe already loads automatically; early graphics in the initrd are unnecessary.
    loadInInitrd = false;
  };

  # Let Dell's firmware adapt charging to plugged-in/battery usage patterns.
  boot.kernelModules = [ "dell_wmi_sysman" ];
  systemd.services.dell-adaptive-charging = {
    description = "Select Dell Adaptive battery charging";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-modules-load.service" ];
    unitConfig.ConditionPathExists = "/sys/class/firmware-attributes/dell-wmi-sysman/attributes/PrimaryBattChargeCfg/current_value";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      setting=/sys/class/firmware-attributes/dell-wmi-sysman/attributes/PrimaryBattChargeCfg/current_value
      if [ "$(cat "$setting")" != Adaptive ]; then
        printf '%s' Adaptive > "$setting"
      fi
      test "$(cat "$setting")" = Adaptive
    '';
  };

  # Linux 7.2.7's intel_cvs camera driver claims the GPIO used by all four
  # CS35L57 speaker amplifiers, preventing the ALSA sound card from appearing.
  # Backport the upstream fix instead of disabling the camera driver.
  # https://github.com/thesofproject/sof/issues/11152
  # https://lore.kernel.org/linux-media/20260913133017.624919-1-junjie.cao@intel.com/
  # Remove this backport once the selected kernel includes the upstream fix.
  boot.kernelPatches = [
    {
      name = "intel-cvs-wake-irq";
      patch = ./intel-cvs-wake-irq.patch;
    }
  ];
}
