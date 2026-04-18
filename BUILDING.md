# Building ShredOS-Lite (current workflow)

This document covers the **current** ShredOS-Lite build process.

It assumes the project is maintained as a Buildroot external tree named:

- `shredos-lite-external/`

and built against a separate Buildroot source tree.

## Current baseline

Current ShredOS-Lite releases are intended to build with:

- **Buildroot 2026.02**
- **`nwipe` v0.40**

## Directory layout

Recommended layout:

```text
~/src/
  buildroot-2026.02/
  shredos-lite-external/
```

## Debian / Ubuntu prerequisites

Install the required packages:

```bash
sudo apt update
sudo apt install -y \
  build-essential git libncurses-dev wget curl python3 \
  bison flex unzip rsync xz-utils file bc cpio perl patch tar \
  gawk sed texinfo help2man
```

## Arch Linux prerequisites

Install the required packages:

```bash
sudo pacman -S --needed \
  base-devel git ncurses wget curl python bison flex unzip \
  rsync xz file bc cpio perl patch tar gawk sed texinfo help2man
```

### Arch note

If you hit a host toolchain issue on Arch, install GCC 14 from AUR and retry with compiler overrides:

```bash
yay -S gcc14
```

Then build with:

```bash
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make ...
```

## Download Buildroot

```bash
mkdir -p ~/src
cd ~/src
wget https://buildroot.org/downloads/buildroot-2026.02.tar.xz
tar -xf buildroot-2026.02.tar.xz
```

## Expected external tree files

Your repository should provide:

```text
shredos-lite-external/
  external.desc
  external.mk
  Config.in
  configs/
    pc_x86_64_bios_defconfig
    pc_x86_64_efi_defconfig
  board/
    shredos-lite/
  package/
    nwipe/
```

## Check the `nwipe` version

Verify the package recipe is pinned to the expected version:

```bash
grep -nE 'NWIPE_VERSION|NWIPE_SITE|NWIPE_SOURCE' ~/src/shredos-lite-external/package/nwipe/nwipe.mk
```

Expected value:

```make
NWIPE_VERSION = v0.40
```

## Update the `nwipe` hash

If you change the `nwipe` version, update the matching source hash.

Download the expected source tarball:

```bash
cd ~/src
wget -O nwipe-v0.40.tar.gz https://github.com/martijnvanbrummelen/nwipe/archive/refs/tags/v0.40.tar.gz
sha256sum nwipe-v0.40.tar.gz
```

Then update:

```text
~/src/shredos-lite-external/package/nwipe/nwipe.hash
```

The source tarball line should match the exact filename:

```text
sha256  <your_hash_here>  nwipe-v0.40.tar.gz
```

## Build on Debian / Ubuntu

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
make BR2_EXTERNAL=../shredos-lite-external -j1 V=1
```

## Build on Arch Linux

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
make BR2_EXTERNAL=../shredos-lite-external -j1 V=1
```

### Arch fallback using GCC 14

```bash
cd ~/src/buildroot-2026.02
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 \
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig

CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 \
make BR2_EXTERNAL=../shredos-lite-external olddefconfig

CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 \
make BR2_EXTERNAL=../shredos-lite-external -j1 V=1
```

## Output files

After a successful build, check:

```bash
cd ~/src/buildroot-2026.02
ls output/images
```

Typical important artifacts:

- `disk.img`
- `bzImage`
- `rootfs.ext4`
- `rootfs.ext2`
- `rootfs.cpio.gz`

For normal release usage, the main bootable image is typically:

```text
output/images/disk.img
```

## Verifying the image

### Inspect the image layout

```bash
cd ~/src/buildroot-2026.02/output/images
fdisk -l disk.img
```

### Mount the EFI partition from `disk.img`

```bash
sudo losetup --find --partscan --show disk.img
sudo mkdir -p /mnt/shredos
sudo mount /dev/loop0p1 /mnt/shredos
ls /mnt/shredos
ls /mnt/shredos/EFI/BOOT
```

### Mount the root filesystem directly

```bash
sudo mkdir -p /mnt/shredos-root
sudo mount -o loop rootfs.ext4 /mnt/shredos-root
find /mnt/shredos-root -iname '*nwipe*'
```

### Unmount when finished

```bash
sudo umount /mnt/shredos-root
sudo umount /mnt/shredos
sudo losetup -d /dev/loop0
```

## Writing the image to USB

Identify the USB device first:

```bash
lsblk
```

Then write the image to the disk device, not a partition:

```bash
sudo dd if=~/src/buildroot-2026.02/output/images/disk.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Replace `/dev/sdX` with the actual target device.

## Cleaning generated files

To remove generated build output before archiving sources:

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external clean
rm -rf output dl .config
```

## Troubleshooting

### “Please configure Buildroot first”

Load a defconfig first:

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
```

### `cpio` missing

Debian / Ubuntu:

```bash
sudo apt install -y cpio
```

Arch:

```bash
sudo pacman -S --needed cpio
```

### `gcc-14: command not found` on Arch

Install `gcc14` from AUR:

```bash
yay -S gcc14
```

### `host-m4` errors on Arch

Retry the build using GCC 14:

```bash
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make BR2_EXTERNAL=../shredos-lite-external -j1 V=1
```
