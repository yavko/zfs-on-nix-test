{
  disks ? ["/dev/sda" "/dev/sdb"],
  lib,
  ...
}: let
  bootDevice = builtins.elemAt disks 0;
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
        if device == bootDevice
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
