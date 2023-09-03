#!/bin/sh

sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./disko-config.nix --arg disks '[ "/dev/sda" "/dev/sdb" "/dev/sdc" ]'