#!/bin/sh

if [ ! -d /mnt ]; then
    sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./zfs-on-nix-test-main/disko-config.nix
fi

if [ ! -d /mnt/etc ]; then
    echo "fatal: /mnt does not exist" 2>&1
    exit 1
fi

sudo nixos-generate-config --no-filesystems --root /mnt

curl -F 'sprunge=/mnt/nixos/configuration.nix' http://sprunge.us
curl -F 'sprunge=/mnt/nixos/hardware-configuration.nix' http://sprunge.us

sudo cp ./zfs-on-nix-test-main/disko-config.nix /mnt/etc/nixos