# Two NVMe disks in mdadm RAID1 for /, with an ESP on each disk so the box
# boots from whichever survives (see boot.loader.grub.mirroredBoots).
let
  mkDisk = device: espMount: {
    inherit device;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        boot = {
          size = "1M";
          type = "EF02"; # BIOS boot partition, harmless on UEFI
        };
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = espMount;
            mountOptions = [ "umask=0077" ];
          };
        };
        mdadm = {
          size = "100%";
          content = {
            type = "mdraid";
            name = "root";
          };
        };
      };
    };
  };
in
{
  disko.devices = {
    disk = {
      nvme0 = mkDisk "/dev/nvme0n1" "/boot";
      nvme1 = mkDisk "/dev/nvme1n1" "/boot-fallback";
    };
    mdadm.root = {
      type = "mdadm";
      level = 1;
      content = {
        type = "gpt";
        partitions.root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
