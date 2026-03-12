#!/bin/sh

# This is the full NixOS setup process for my XMG laptop.
# It's based on [this post of Chris Martin](chris-martin.org/2015/installing-nixos) and recently refactored with the help of GPT and Claude.

# We assume that before running this script, the following was done:
# git clone https://github.com/wkolowski/nixos-config .
# cd nixos-config

# The above guarantees that all the needed files are present.
# Usage: sudo ./setup-nvme.sh

# Fail on first error.
set -e

## Colorful diagnostic messages.

GREEN='\033[0;32m'
NC='\033[0m' # No Color

info()
{
  printf "${GREEN}%s${NC}\n" "$1"
}

## Partition table

# | Device         | Size | Code | Name                 |
# | -------------- | ---- | ---- | -------------------- |
# | /dev/nvme0n1p1 | 1GiB | EF00 | EFI System Partition |
# | /dev/nvme0n1p2 | rest | 8300 | Linux partition      |

info "Partitioning /dev/nvme0n1"
sfdisk /dev/nvme0n1 < partition-table-nvme.sfdisk

## Disk setup

info "Setting up disk encryption using LUKS"
cryptsetup luksFormat /dev/nvme0n1p2
cryptsetup luksOpen /dev/nvme0n1p2 nvme0n1p2_crypt

info "Creating filesystems: FAT32 for boot, ext4 for the rest"
mkfs.vfat -F 32 -n BOOT /dev/nvme0n1p1
mkfs.ext4 -L root /dev/mapper/nvme0n1p2_crypt

# Mount everything.

info "Mounting..."

mount /dev/mapper/nvme0n1p2_crypt /mnt

mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

## NixOS configuration.

info "Generating NixOS configuration"

# Generate the configuration.
nixos-generate-config --root /mnt

# Replace /mnt/etc/nixos/ with the current repo,
# preserving the generated hardware configuration.
cp /mnt/etc/nixos/hardware-configuration.nix .
rm -rf /mnt/etc/nixos/
cp -r . /mnt/etc/nixos/

info "You can adjust the configuration now"
nano /mnt/etc/nixos/configuration.nix

## Installation

info "Installing NixOS"
nixos-install

## Post-installation

info "Setting up password for user wk."
nixos-enter --root /mnt -c 'passwd wk'

info "Installation successful!"
