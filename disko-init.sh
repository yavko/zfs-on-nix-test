#!/bin/sh

if [ ! -d mnt ]; then
    sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./zfs-on-nix-test-main/disko-config.nix
fi

if [ ! -d /mnt ]; then
    echo "fatal: /mnt does not exist" 2>&1
    exit 1
fi

nixos-generate-config --no-filesystems --root /mnt

gzip < /mnt/nixos/configuration.nix | curl -s http://0paste.com/pastes.txt -F "paste[is_private]=1" -F "paste[paste_gzip]=<-"
gzip < /mnt/nixos/hardware-configuration.nix | curl -s http://0paste.com/pastes.txt -F "paste[is_private]=1" -F "paste[paste_gzip]=<-"

cp ./zfs-on-nix-test-main/disko-config.nix /mnt/etc/nixos