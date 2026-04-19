# ShredOS-Lite

ShredOS-Lite is a lightweight, Buildroot-based ShredOS image designed to boot straight into **nwipe** for disk erasure.

This repository contains the source and project files used to build modern ShredOS-Lite releases.

## Start here

If you are here to **use ShredOS-Lite**, the easiest option is to download the latest ready-to-use release from the **Releases** page.

If you are here to **build ShredOS-Lite from source**, start with [BUILDING.md](BUILDING.md).

## Recommended version

For the best experience, use **v1.0.3 or newer**.

Version 1.0.3 updates the project to a newer Buildroot base, a newer nwipe version, and a cleaner source layout that is easier to build and maintain.

If you are working with **v1.0.2 or older**, see [README_LEGACY.md](README_LEGACY.md).

## What you will find in this repository

This repository contains the ShredOS-Lite project files and documentation needed to build current versions of ShredOS-Lite.

Important files:

- `shredos-lite-external/` — project-specific Buildroot files
- [BUILDING.md](BUILDING.md) — current build instructions for Debian/Ubuntu and Arch Linux
- [README_LEGACY.md](README_LEGACY.md) — instructions for older builds such as v1.0.2 and earlier
- [RELEASING.md](RELEASING.md) — release preparation notes

## What should I do next?

### I just want to use ShredOS-Lite
Go to the **Releases** page and download the latest release image.

### I want to build the latest version from source
Read [BUILDING.md](BUILDING.md).

### I need to rebuild an older release
Read [README_LEGACY.md](README_LEGACY.md).

## Building the current version

Current build instructions are in [BUILDING.md](BUILDING.md).

That guide includes:

- Debian/Ubuntu prerequisites
- Arch Linux prerequisites
- the current Buildroot workflow
- notes about nwipe updates
- troubleshooting and cleanup steps

## Older releases

Older ShredOS-Lite releases such as **v1.0.2 and earlier** used an older layout and may need extra workarounds on newer systems.

If you need to work with one of those older source packages, use [README_LEGACY.md](README_LEGACY.md).

## Purpose of this repository

The purpose of this repository is to provide a clear, maintained source home for ShredOS-Lite along with build documentation for current users and contributors.

If you are looking for the latest source, use this repository.  
If you are looking for ready-to-use build artifacts, use the **Releases** page.
