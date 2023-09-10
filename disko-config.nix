{
  disks ? ["/dev/sda" "/dev/sdb" "/dev/sdc"],
  lib,
  ...
}: let
  zfs = {
    type = "zfs";
    pool = "zroot";
  };
in {
  disko.devices = {
    disk = lib.genAttrs disks (device: {
      type = "disk";
      name = lib.removePrefix "_" (builtins.replaceStrings ["/"] ["_"] device);
      device = device;
      content =
        if (device == (builtins.elemAt disks 0))
        then {
          type = "gpt";
          partitions = {
            esp = {
              type = "EF00";
              size = "512M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            zfs = {
              size = "100%";
              content = zfs;
            };
          };
        }
        else zfs;
    });
    zpool = {
      zroot = {
        type = "zpool";
        mode = "raidz";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        mountpoint = "/";
        postCreateHook = "zfs snapshot zroot@blank";
        datasets = {
          "root" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
        };
      };
    };
  };
}
