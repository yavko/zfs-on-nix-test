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
        partitions = {
          esp = {
            content = {
              format = "vfat";
              mountpoint = "/boot-" + disk;
              type = "filesystem";
            };
            size = "512M";
            type = "EF00";
          };
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
          acltype = "posixacl";
          atime = "off";
          canmount = "off";
          compression = "zstd";
          dedup = "on";
          devices = "off";
          mountpoint = "none";
          xattr = "sa";
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
          "ROOT/residues" = {
            mountpoint = "/var/residues";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
          "data/persistent" = {
            mountpoint = "/var/persistent";
            options.mountpoint = "legacy";
            type = "zfs_fs";
          };
          "reserved" = {
            options = {
              mountpoint = "none";
              reservation = "10G";
            };
            type = "zfs_fs";
          };
        };
      };
    };
  };
}
