#!/bin/sh

# This is the full NixOS setup process for all of my computers (hope it works uniformly everywhere!).
# It used to be a markdown file, but then I realized it's better to make it into a shell script.
# It's based on [this post of Chris Martin](chris-martin.org/2015/installing-nixos).

## Partition table

# | Device    | Size | Code | Name                 |
# | --------- | ---- | ---- | -------------------- |
# | /dev/sda1 | 500M |      | boot                 |
# | /dev/sda2 | rest | 8E00 | Linux LVM            |

# Download a description of the above partition table and put it to disk with `sfdisk`.
# Beware: it's the weakest part of this script and it may not work.

sudo curl https://raw.githubusercontent.com/wkolowski/nixos-config/master/partition-table-non-uefi.sfdisk > ptable.sfdisk
sudo sfdisk /dev/sda < ptable.sfdisk

## Disk setup

# Setup disk encryption using LUKS:

sudo cryptsetup luksFormat /dev/sda2
sudo cryptsetup luksOpen /dev/sda2 sda2_crypt

# Create LVM groups and volumes:

sudo pvcreate /dev/mapper/sda2_crypt

sudo vgcreate vg /dev/mapper/sda2_crypt

sudo lvcreate -n swap vg -L 8G
sudo lvcreate -n root vg -l 100%FREE

# Make new filesystems and swap:

sudo mkfs.vfat -n BOOT /dev/sda1
sudo mkfs.ext4 -L root /dev/vg/root
sudo mkswap -L swap /dev/vg/swap

## Installation

# Mount everything and activate the swap:

sudo mount /dev/vg/root /mnt

sudo mkdir /mnt/boot
sudo mount /dev/sda1 /mnt/boot

sudo swapon /dev/vg/swap

# Generate nix configuration.
# Keep the hardware configuration.
# Overwrite the software configuration with the one taken from this repo.

sudo nixos-generate-config --root /mnt
sudo curl https://raw.githubusercontent.com/wkolowski/nixos-config/master/configuration-non-uefi.nix > tmp
sudo mv tmp /mnt/etc/nixos/configuration.nix

# Finish the installation:

sudo nixos-install

# Set a new password for root.
sudo passwd root

# Create a user and set a new password.
sudo useradd wk
sudo passwd wk
