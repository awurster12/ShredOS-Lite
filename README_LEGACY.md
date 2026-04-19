# Legacy Builds (1.0.2 and older)

This document is for **ShredOS-Lite 1.0.2 and older**.

These older releases were distributed differently from the current workflow.
They typically shipped as a **full Buildroot source tree** inside a release archive instead of using a cleaner `br2-external` source layout.

## Recommendation

If possible, move to **1.0.3 or newer**.

Modern releases use:

- a cleaner Buildroot external-tree layout
- newer Buildroot base
- newer `nwipe`
- clearer Debian/Ubuntu and Arch instructions

For newer versions, see the [main README](https://github.com/awurster12/ShredOS-Lite/blob/main/README.md)..

## Legacy source layout

Older source releases commonly extracted to something like:

```text
buildroot-2025.11/
```

with custom files directly inside that tree, for example:

- `configs/pc_x86_64_efi_defconfig`
- `configs/pc_x86_64_bios_defconfig`
- `board/pc/`
- `package/nwipe/`

## Debian / Ubuntu prerequisites for legacy builds

```bash
sudo apt update
sudo apt install -y \
  build-essential git libncurses-dev wget curl python3 \
  bison flex unzip rsync xz-utils file bc cpio perl patch tar \
  gawk sed texinfo help2man
```

## Arch Linux prerequisites for legacy builds

```bash
sudo pacman -S --needed \
  base-devel git ncurses wget curl python bison flex unzip \
  rsync xz file bc cpio perl patch tar gawk sed texinfo help2man
```

### Important Arch note for legacy builds

Older 1.0.2-era trees may fail on newer Arch host compilers.
If that happens, install GCC 14 from AUR and build with overrides:

```bash
yay -S gcc14
```

Then use:

```bash
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make pc_x86_64_efi_defconfig
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make
```

## Legacy build example

```bash
cd ~/Downloads/buildroot-2025.11
make pc_x86_64_efi_defconfig
make
```

### Arch example with GCC 14

```bash
cd ~/Downloads/buildroot-2025.11
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make pc_x86_64_efi_defconfig
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make
```

## Typical legacy output

```bash
ls output/images
```

Look for:

- `disk.img`
- `bzImage`
- `rootfs.ext4`
- `rootfs.ext2`

## Legacy troubleshooting

### `cpio` missing

Arch:

```bash
sudo pacman -S --needed cpio
```

Debian / Ubuntu:

```bash
sudo apt install -y cpio
```

### `host-m4` / compiler issues on Arch

Legacy Buildroot trees may fail with newer Arch GCC releases. The usual workaround is to build with GCC 14:

```bash
yay -S gcc14
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make
```

## Migrating away from legacy builds

To modernize a legacy source release:

1. preserve the old full Buildroot tree as a reference
2. copy custom files into a separate `shredos-lite-external/` tree
3. build against a current Buildroot release
4. update `nwipe` and hashes
5. publish modern source layout in the repository

For the modern workflow, see [BUILDING.md](BUILDING.md).
