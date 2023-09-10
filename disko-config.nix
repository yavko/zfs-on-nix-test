{
  disks,
  lib,
  ...
}: {
  disko.devices = {
    disk = lib.genAttrs disks (device: {
      type = "disk";
      name = lib.removePrefix "_" (lib.replaceStrings ["/"] ["_"] device);
      device = device;
      content = {
        type = "gpt";
        partitions =
          (
            lib.mkIf (device == (builtins.elemAt disks 0)) {
              esp = {
                type = "EF00";
                size = "512M";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                };
              };
            }
          )
          // {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
      };
    });
    zpool = {
      zroot = {
        type = "zpool";
        mode = "raidz";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
        };
        datasets = {
          "data" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "ROOT" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "ROOT/empty" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = ''
              zfs snapshot zroot/ROOT/empty@start
            '';
          };
          "ROOT/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
          };
        };
      };
    };
  };
}
