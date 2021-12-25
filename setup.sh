#!/bin/sh

# This is the full NixOS setup process for all of my computers (hope it works uniformly everywhere!).
# It used to be a markdown file, but then I realized it's better to make it into a shell script.
# It's based on [this post of Chris Martin](chris-martin.org/2015/installing-nixos).

## Partition table

# | Device    | Size | Code | Name                 |
# | --------- | ---- | ---- | -------------------- |
# | /dev/sda1 | 1M   | EF02 | BIOS boot partition  |
# | /dev/sda2 | 500M | EF00 | EFI System Partition |
# | /dev/sda3 | rest | 8E00 | Linux LVM            |

# Download a description of the above partition table and put it to disk with `sfdisk`.
# Beware: it's the weakest part of this script and it may not work.

sudo curl https://raw.githubusercontent.com/wkolowski/nixos-config/master/partition-table.sfdisk > ptable.sfdisk
sudo sfdisk /dev/sda < ptable.sfdisk

## Disk setup

# Setup disk encryption using LUKS:

sudo cryptsetup luksFormat /dev/sda3
sudo cryptsetup luksOpen /dev/sda3 sda3_crypt

# Create LVM groups and volumes:

sudo pvcreate /dev/mapper/sda3_crypt

sudo vgcreate vg /dev/mapper/sda3_crypt

sudo lvcreate -n swap vg -L 8G
sudo lvcreate -n root vg -l 100%FREE

# Make new filesystems and swap:

sudo mkfs.vfat -n BOOT /dev/sda2
sudo mkfs.ext4 -L root /dev/vg/root
sudo mkswap -L swap /dev/vg/swap

## Installation

# Mount everything and activate the swap:

sudo mount /dev/vg/root /mnt

sudo mkdir /mnt/boot
sudo mount /dev/sda2 /mnt/boot

sudo swapon /dev/vg/swap

# Generate nix configuration.
# Keep the hardware configuration.
# Overwrite the software configuration with the one taken from this repo.

sudo nixos-generate-config --root /mnt
sudo curl https://raw.githubusercontent.com/wkolowski/nixos-config/master/configuration.nix > tmp
sudo mv tmp /mnt/etc/nixos/configuration.nix

# Finish the installation:
sudo nixos-install

# Set a new password for root.
echo "Setting up password for user root."
sudo passwd root

# Create a user and set a new password.
echo "Setting up password for user wk."
sudo useradd wk
sudo passwd wk