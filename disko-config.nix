let
  partitions = [
    {
      content = {
        format = "vfat";
        mountpoint = "/boot";
        type = "filesystem";
      };
      size = "512M";
      type = "EF00";
    }
    {
      size = "100%";
      content = {
        pool = "zroot";
        type = "zfs";
      };
    }
  ];
in {
  disk = {
    sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "table";
        format = "gpt";
        inherit partitions;
      };
    };
    sdb = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "table";
        format = "gpt";
        inherit partitions;
      };
    };
    sdc = {
      type = "disk";
      device = "/dev/sdc";
      content = {
        type = "table";
        format = "gpt";
        inherit partitions;
      };
    };
  };

  zpool = {
    zroot = {
      type = "zpool";
      mode = "mirror";
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
}
