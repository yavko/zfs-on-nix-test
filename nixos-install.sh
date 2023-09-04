#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

sudo cp \
    ./zfs-on-nix-test-main/configuration.nix \
    ./zfs-on-nix-test-main/chaotic.nix \
    /mnt/etc/nixos

sudo nixos-install