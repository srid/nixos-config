{ lib, ... }:
{
  disk = lib.genAttrs [ "/dev/nvme0n1" "/dev/nvme1n1" ]
    (disk: {
      type = "disk";
      device = disk;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            name = "boot";
            start = "0";
            end = "1M";
            part-type = "primary";
            flags = [ "bios_grub" ];
          }
          {
            name = "ESP";
            start = "1M";
            end = "1GiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "mdraid";
              name = "boot";
            };
          }
          {
            name = "nixos";
            start = "1GiB";
            end = "100%";
            content = {
              type = "mdraid";
              name = "nixos";
            };
          }
        ];
      };
    });
  mdadm = {
    boot = {
      type = "mdadm";
      level = 1;
      metadata = "1.0";
      content = {
        type = "filesystem";
        format = "vfat";
        mountpoint = "/boot";
      };
    };
    nixos = {
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
      };
    };
  };
}
