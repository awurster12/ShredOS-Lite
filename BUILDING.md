# Building ShredOS-Lite

This document covers building **ShredOS-Lite** with the current Buildroot-based workflow on both **Debian/Ubuntu** and **Arch Linux**.

The current recommended base is **Buildroot 2026.02**. Buildroot lists `2026.02.x` as the current stable series, while `2025.11.x` is old stable and EOL. The latest upstream `nwipe` release is `v0.40`. citeturn0search0turn0search4

## Overview

ShredOS-Lite is built using:

- a clean upstream Buildroot checkout
- a `br2-external` tree containing the ShredOS-Lite board files, configs, and custom package definitions

This keeps the project-specific files separate from upstream Buildroot and makes future upgrades much easier.

## Directory Layout

A typical working layout looks like this:

```text
~/src/
├── buildroot-2026.02/
└── shredos-lite-external/
```

The external tree should contain at least:

```text
shredos-lite-external/
├── Config.in
├── external.desc
├── external.mk
├── board/
│   └── shredos-lite/
├── configs/
│   ├── pc_x86_64_bios_defconfig
│   └── pc_x86_64_efi_defconfig
└── package/
    └── nwipe/
```

## 1. Get Buildroot

Download the current stable Buildroot release:

```bash
cd ~/src
git clone --branch 2026.02 --depth 1 https://gitlab.com/buildroot.org/buildroot.git buildroot-2026.02
```

## 2. Debian / Ubuntu Build Dependencies

Install the required host packages:

```bash
sudo apt update
sudo apt install -y \
  build-essential git libncurses-dev wget curl python3 \
  bison flex unzip rsync xz-utils file bc cpio perl patch tar
```

## 3. Arch Linux Build Dependencies

Install the required host packages:

```bash
sudo pacman -S --needed \
  base-devel git ncurses wget curl python bison flex unzip \
  rsync xz file bc cpio perl patch tar
```

## 4. Build Commands

Run all build commands from the Buildroot tree:

```bash
cd ~/src/buildroot-2026.02
```

### UEFI build

```bash
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
make BR2_EXTERNAL=../shredos-lite-external
```

### BIOS build

```bash
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_bios_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
make BR2_EXTERNAL=../shredos-lite-external
```

### Verbose single-job build

If you need easier-to-read logs during migration or troubleshooting:

```bash
make BR2_EXTERNAL=../shredos-lite-external -j1 V=1
```

## 5. Output Files

Build artifacts are written to:

```text
buildroot-2026.02/output/images/
```

List them with:

```bash
ls ~/src/buildroot-2026.02/output/images
```

## 6. Updating `nwipe`

Moving to a newer Buildroot does **not** automatically update `nwipe` if ShredOS-Lite is using its own custom `package/nwipe/` recipe.

Check the current version with:

```bash
grep -nE '^NWIPE_VERSION|^NWIPE_SITE|^NWIPE_SOURCE' ~/src/shredos-lite-external/package/nwipe/nwipe.mk
```

If you want the latest upstream `nwipe`, update the package recipe and its hash file accordingly. The latest upstream release is currently `v0.40`. citeturn0search4turn0search1

## 7. Cleaning the Build Tree

To remove generated files before committing source changes:

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external clean
rm -rf output
```

Use `distclean` only if you intentionally want to reset the Buildroot configuration as well.

## 8. Arch Linux Notes

On the **legacy Buildroot 2025.11 tree**, native Arch builds could fail in `host-m4-1.4.20` when using Arch's default GCC 15 toolchain. That older release series is now EOL. Buildroot documents `2025.11.x` as old stable / EOL and `2026.02.x` as current stable. citeturn0search0

For the **current Buildroot 2026.02 workflow**, start by building with Arch's normal compiler.

If you hit a host-compiler regression on Arch and need a fallback, install `gcc14` from AUR and build with explicit compiler overrides:

```bash
yay -S gcc14
```

Then:

```bash
cd ~/src/buildroot-2026.02
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 \
  make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig

CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 \
  make BR2_EXTERNAL=../shredos-lite-external olddefconfig

CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 \
  make BR2_EXTERNAL=../shredos-lite-external
```

Arch's current `gcc` package is GCC 15.2.1, which is why the GCC 14 fallback can still be useful for older Buildroot trees. citeturn0search0turn0search9

## 9. Common Problems

### `cpio` missing

If Buildroot stops with a message saying `You must install 'cpio' on your build machine`, install the missing host package:

- Debian / Ubuntu: `sudo apt install cpio`
- Arch Linux: `sudo pacman -S cpio`

### Custom defconfig not found

Make sure the command is being run inside the Buildroot tree:

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external list-defconfigs
```

If your external defconfigs do not appear, verify that `shredos-lite-external/` contains:

- `external.desc`
- `external.mk`
- `Config.in`
- `configs/pc_x86_64_efi_defconfig` and/or `configs/pc_x86_64_bios_defconfig`

### Old in-tree paths after migration

If you migrated from an older in-tree layout, make sure your defconfigs and board scripts no longer reference `board/pc/...` directly for project files.

For external-tree files, use:

```make
$(BR2_EXTERNAL_SHREDOS_LITE_PATH)/board/shredos-lite/...
```

while Buildroot-owned helpers such as `support/scripts/genimage.sh` should remain unchanged.

## 10. Recommended Git Workflow

Commit only the project-specific external tree files, not generated build output.

Typical source changes to commit:

- `shredos-lite-external/Config.in`
- `shredos-lite-external/external.desc`
- `shredos-lite-external/external.mk`
- `shredos-lite-external/configs/*`
- `shredos-lite-external/board/shredos-lite/*`
- `shredos-lite-external/package/nwipe/*`

Do **not** commit:

- `buildroot-2026.02/output/`
- generated images
- downloaded tarballs
- temporary build artifacts

## 11. Quick Start Summary

### Debian / Ubuntu

```bash
sudo apt update
sudo apt install -y build-essential git libncurses-dev wget curl python3 bison flex unzip rsync xz-utils file bc cpio perl patch tar
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
make BR2_EXTERNAL=../shredos-lite-external
```

### Arch Linux

```bash
sudo pacman -S --needed base-devel git ncurses wget curl python bison flex unzip rsync xz file bc cpio perl patch tar
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
make BR2_EXTERNAL=../shredos-lite-external olddefconfig
make BR2_EXTERNAL=../shredos-lite-external
```

### Arch Linux fallback with GCC 14

```bash
yay -S gcc14
cd ~/src/buildroot-2026.02
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make BR2_EXTERNAL=../shredos-lite-external pc_x86_64_efi_defconfig
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make BR2_EXTERNAL=../shredos-lite-external olddefconfig
CC=gcc-14 HOSTCC=gcc-14 CXX=g++-14 HOSTCXX=g++-14 make BR2_EXTERNAL=../shredos-lite-external
```
