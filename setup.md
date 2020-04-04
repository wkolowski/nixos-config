# My NixOS

This is the full setup process for my NixOS virtual machine (and soon also my desktop).
It's based on [this post of Christ Martin](chris-martin.org/2015/installing-nixos).

## Disk setup

### Partition table

Use `gparted` (or `fdisk`) to get something like this:

| Name      | Mounted | Size |
| --------- | ------- | ---- |
| /dev/sda1 | /boot   | 500M |
| /dev/sda2 | /       | rest |

Setup disk encyprtion using LUKS:

```bash
cryptsetup luksFormat /dev/sda2
cryptsetup luksOpen /dev/sda2 sda2_crypt
```
Create LVM groups and volumes:

```bash
pvcreate /dev/mapper/sda2_crypt

vgcreate vg /dev/mapper/sda2_crypt

lvcreate -n swap vg -L 8G
lvcreate -n root vg -l 100%FREE
```

Make new filesystems and swap:

```bash
mkfs.vfat -n BOOT /dev/sda1
mkfs.btrfs -L root /dev/vg/root
mkswap -L swap /dev/vg/swap
```

## Installation

Mounting everything in the desired places and activate the swap:

```bash
mount /dev/vg/root /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

swapon /dev/vg/swap
```

Generate nix configuration for hardware and use nix configuration for software from this repo:

```bash
nixos-generate-config --root /mnt
mv configuration.nix /mnt/etc/nixos/
```

Finish the installation:

```bash
nixos-install
```

Set a password for myself:

```bash
passwd wk
```

Set up git credentials:
```bash
git config --global user.name TODO
git config --global user.email TODO
```
