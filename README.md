This project provides a minimal, RAM-booted Buildroot Linux appliance designed specifically for secure disk erasure using nwipe.

The resulting image:

Boots on x86_64 UEFI systems

Runs entirely from RAM (initramfs) — internal disks are never mounted

Supports SATA and NVMe (including Intel VMD / RST setups)

Generates PDF erasure certificates

Optionally includes a persistent FAT32 partition on the boot USB for storing reports

The appliance is intended for IT asset disposal, decommissioning, and audit-friendly disk wiping.

Key Features

🧼 nwipe (0.39 or newer)

⚡ Fast RAM-based boot

💾 SATA + NVMe + Intel VMD support

📄 PDF wipe reports

🔌 Optional persistent FAT32 partition for reports

🔐 Runs as root (appliance-style, no login required)

🔧 Fully reproducible Buildroot build

Repository Structure
.
├── board/pc/
│   ├── genimage-efi.cfg        # Disk image layout (EFI + optional reports partition)
│   ├── grub-efi.cfg            # GRUB EFI configuration
│   ├── linux-nwipe.config      # Custom Linux kernel configuration
│   └── overlay/                # Root filesystem overlay
│       ├── etc/
│       │   ├── init.d/         # Init scripts (optional customizations)
│       │   └── nwipe/           # Optional nwipe config files
├── configs/
│   └── pc_x86_64_nwipe_defconfig
├── package/
│   └── nwipe/                  # Custom nwipe Buildroot package
└── README.md

**Host System Requirements**

You need a Linux build host with standard Buildroot dependencies.

Debian / Ubuntu
sudo apt install \
  build-essential git libncurses5-dev libncursesw5-dev \
  wget curl python3 bison flex unzip rsync \
  xz-utils file bc


Other distributions should install equivalent packages.

**Building the Image**

From the root of the repository:

make pc_x86_64_nwipe_defconfig
make


Buildroot will automatically:

Download all required sources

Build the toolchain

Compile the Linux kernel + initramfs

Build nwipe and dependencies

Generate a bootable UEFI disk image

**Output**

After a successful build, the bootable image will be located at:

output/images/disk.img

**Writing the Image to USB**

⚠️ This will erase the target USB device.

sudo dd if=output/images/disk.img of=/dev/sdX bs=4M status=progress conv=fsync


Replace /dev/sdX with your USB device (not a partition).

**Booting and Using NWipe**

Insert the USB into the target system

Boot via UEFI (Secure Boot must be disabled)

The system boots directly into a root shell

Launch nwipe:

nwipe


Select disks and wiping method

Run the wipe

Generate PDF reports as needed

Because the system runs from RAM, internal disks are never mounted or used.

**Optional: Persistent Reports Partition**

The image can include a 2 GB FAT32 partition on the USB labeled REPORTS.

If enabled:

It is automatically mounted at /mnt/reports

PDF wipe reports can be copied there

The USB can be removed and plugged into another PC to retrieve reports

Example:

cp /var/log/nwipe/*.pdf /mnt/reports/
sync

**Optional: NWipe PDF Customization Script**

This project supports an optional customization script that can automatically populate fields in the nwipe PDF report, such as:

Organization name

Customer name

Operator name

System serial number (via dmidecode)

**How it Works**

An init script runs at boot

It reads the system serial number

It updates:

/etc/nwipe/nwipe.conf

/etc/nwipe/nwipe_customers.csv

This allows fully automated, audit-ready PDF certificates with no manual data entry.

**Enabling the Customization**

Add an init script such as:

board/pc/overlay/etc/init.d/S20nwipe-serial


Include template files:

board/pc/overlay/etc/nwipe/nwipe.conf
board/pc/overlay/etc/nwipe/nwipe_customers.csv


Rebuild the image:

make

**Disabling / Removing Customization**

For a neutral, public GitHub version:

Remove the init script:

rm board/pc/overlay/etc/init.d/S20nwipe-serial


Remove or blank the nwipe config files in the overlay

Rebuild and nwipe will behave exactly like upstream.

**BIOS / Firmware Notes**

UEFI boot required

Secure Boot must be disabled

For Intel systems:

NVMe works in both AHCI and Intel VMD/RST modes

VMD support is compiled directly into the kernel

**Reproducibility**

This repository is designed to be clone-and-build:

git clone <repo>
cd <repo>
make pc_x86_64_nwipe_defconfig
make


All sources are fetched automatically by Buildroot.

No prebuilt artifacts are committed.

**License**

Buildroot: GPLv2

Linux kernel: GPLv2

nwipe: GPLv2

This repository: see individual file headers where applicable

Disclaimer

⚠️ This software irreversibly destroys data.
Always verify target disks before wiping.
