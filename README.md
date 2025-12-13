# Buildroot NWipe Appliance (x86_64 UEFI)

## Overview

This project provides a minimal Linux appliance built with Buildroot for secure disk erasure using **nwipe**.

The system boots entirely into RAM (initramfs) and never mounts internal disks, making it suitable for IT asset disposal, decommissioning, and audit/compliance workflows.

## Key Features

- nwipe (v0.39+)
- RAM-based boot (initramfs)
- SATA and NVMe support (including Intel VMD / RST)
- PDF erasure certificates
- Optional persistent FAT32 partition for reports
- Appliance-style root shell (no login prompt)
- Fully reproducible Buildroot build

## What This Image Does

- Boots on x86_64 UEFI systems
- Detects SATA and NVMe storage devices
- Allows secure disk wiping using nwipe
- Generates PDF wipe reports
- Optionally stores reports on the boot USB

**WARNING:** This image permanently destroys data. Always verify target disks before wiping.

## Repository Structure

├── board/pc/
│ ├── genimage-efi.cfg
│ ├── grub-efi.cfg
│ ├── linux-nwipe.config
│ └── overlay/
│ └── etc/
├── configs/
│ └── pc_x86_64_nwipe_defconfig
├── package/
│ └── nwipe/
└── README.md


## Host System Requirements

A Linux system with standard Buildroot dependencies installed.

### Debian / Ubuntu

sudo apt install
build-essential git libncurses5-dev libncursesw5-dev
wget curl python3 bison flex unzip rsync
xz-utils file bc


## Building the Image

### Step 1: Configure Buildroot

make pc_x86_64_efi_defconfig


### Step 2: Build

make


Buildroot will automatically download all required sources and generate a bootable image.

## Build Output

After a successful build, the image will be located at:

output/images/disk.img


## Writing the Image to USB

**WARNING:** This will erase the target USB device.

sudo dd if=output/images/disk.img of=/dev/sdX bs=4M status=progress conv=fsync


Replace `/dev/sdX` with the correct USB device.

## Booting the Appliance

1. Insert the USB into the target system
2. Boot via UEFI
3. Disable Secure Boot if enabled
4. The system boots directly into a root shell (default login: root, password: none)

To start nwipe:

nwipe


## Using NWipe

From the ncurses interface you can:

- Select disks
- Choose wipe methods
- Enable verification
- Generate PDF erasure certificates

## Optional: Persistent Reports Partition

The image can include a FAT32 partition labeled `REPORTS`.

If enabled, it is automatically mounted at:

/mnt/reports


### Saving Reports

cp /var/log/nwipe/*.pdf /mnt/reports/
sync


## Optional: NWipe PDF Customization Script

This project supports an optional customization mechanism that can automatically populate fields in the nwipe PDF erasure report.

Customizable fields include:

- Organization name
- Customer name
- Operator name
- System serial number (via `dmidecode`)

The repository ships **example configuration files only**.  
They must be copied into the root filesystem overlay before rebuilding.

---

### Enabling PDF Customization (Please see CUSTOMIZATION.md for more in-depth instructions)

#### Step 1: Copy example configuration files

From the root of the repository:

mkdir -p board/pc/overlay/etc/nwipe
cp examples/nwipe/nwipe.conf.example board/pc/overlay/etc/nwipe/nwipe.conf
cp examples/nwipe/nwipe_customers.csv.example board/pc/overlay/etc/nwipe/nwipe_customers.csv


Edit the copied files as needed:

board/pc/overlay/etc/nwipe/nwipe.conf

---

#### Step 2: Enable the customization init script

Ensure the following init script exists and is executable:

board/pc/overlay/etc/init.d/S20nwipe-serial


This script runs at boot and:

- Reads the system serial number
- Updates `nwipe.conf`
- Updates `nwipe_customers.csv`

---

#### Step 3: Rebuild the image

After copying and editing the configuration files, rebuild the image:

make


The generated image will now include the customized nwipe PDF fields.

---

### Disabling PDF Customization

To disable customization and use default nwipe behavior:

rm board/pc/overlay/etc/init.d/S20nwipe-serial

Rebuild and nwipe will use default behavior.

## BIOS / Firmware Notes

- UEFI boot required
- Secure Boot must be disabled
- NVMe supported in AHCI and Intel VMD / RST modes

## Reproducible Builds

This repository is designed to be clone-and-build:

git clone <repo-url>
cd <repo>
make pc_x86_64_nwipe_defconfig
make


All sources are downloaded automatically by Buildroot.

## License

- Buildroot: GPLv2
- Linux kernel: GPLv2
- nwipe: GPLv2

## Disclaimer

This software permanently destroys data. Use with care.
