# Dell XPS 16 DA16260 (2026), Intel Panther Lake.
{
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
