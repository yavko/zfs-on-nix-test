#!/bin/sh

sudo nix --extra-experimental-features "nix-command flakes" run github:nix-community/disko -- --mode disko ./zfs-on-nix-test-main/disko-config.nix