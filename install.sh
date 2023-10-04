#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

if [ -z "${SUDO_USER}" ]; then
  echo "Fatal: run as root" 2>&1
  exit 1
fi

if [ ! -d /mnt ]; then
  nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko-config.nix
fi

if [ ! -d /mnt ]; then
  echo "Fatal: /mnt does not exist" 2>&1
  exit 1
fi

if [ ! -d /mnt/etc/nixos ]; then
  nixos-generate-config --no-filesystems --root /mnt

  mount

#curl -F 'sprunge=<-' http://sprunge.us < /mnt/etc/nixos/configuration.nix

  cp \
    ./configuration.nix \
    ./disko-config.nix \
    /mnt/etc/nixos

  nixos-install
fi
