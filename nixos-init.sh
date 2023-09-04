#!/bin/sh
set -euo pipefail
IFS=$'\n\t'

sudo cp ./zfs-on-nix-test-main/configuration.nix /mnt/etc/nixos