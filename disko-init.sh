#!/bin/sh

if [ ! -d /mnt ]; then
    sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./zfs-on-nix-test-main/disko-config.nix
fi

if [ ! -d /mnt ]; then
    echo "fatal: /mnt does not exist" 2>&1
    exit 1
fi

if [ ! -d /mnt/etc/nixos ]; then
    sudo nixos-generate-config --no-filesystems --root /mnt

    curl -F 'sprunge=<-' http://sprunge.us < /mnt/etc/nixos/configuration.nix

    sudo cp ./zfs-on-nix-test-main/disko-config.nix /mnt/etc/nixos
fi

sudo cp ./zfs-on-nix-test-main/configuration.nix /mnt/etc/nixos