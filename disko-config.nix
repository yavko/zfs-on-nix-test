{
  disks ? ["sda" "sdb" "sdc"],
  lib,
  ...
}: {
  disko.devices = {
    disk = lib.genAttrs disks (disk: {
      type = "disk";
      device = "/dev/" + disk;
      content = {
        type = "gpt";
        partitions =
          (
            if (disk == (builtins.elemAt disks 0))
            then {
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
            else {}
          )
          // {
            zfs = {
              size = "100%";
              content = {
                pool = "zroot";
                type = "zfs";
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
            options.mountpoint = "none";
            type = "zfs_fs";
          };
          "ROOT" = {
            options.mountpoint = "none";
            type = "zfs_fs";
          };
          "ROOT/empty" = {
            mountpoint = "/";
            options.mountpoint = "legacy";
            postCreateHook = ''
              zfs snapshot zroot/ROOT/empty@start
            '';
            type = "zfs_fs";
          };
          "ROOT/nix" = {
            mountpoint = "/nix";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
        };
      };
    };
  };
}
