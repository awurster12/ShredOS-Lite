# ShredOS-Lite

ShredOS-Lite is a compact Buildroot-based ShredOS image focused on booting directly into `nwipe` for disk erasure workflows.

## Use version 1.0.3 or newer

For the best experience, use **1.0.3 or newer**.

Version **1.0.3** modernizes the project layout around:

- **Buildroot 2026.02**
- **`nwipe` v0.40**
- a cleaner **`br2-external`** project structure
- updated build instructions for **Debian/Ubuntu** and **Arch Linux**

If you are using an older source package or release such as **1.0.2 or older**, see [README_LEGACY.md](README_LEGACY.md).

If you want the newest build, either:

- download the **latest source** from this repository, or
- download the **latest release** from the GitHub Releases page.

## Repository layout

This repository is intended to contain the project-specific files only:

- `shredos-lite-external/` - ShredOS-Lite Buildroot external tree
- `README.md` - main project overview
- `BUILDING.md` - current build instructions
- `README_LEGACY.md` - instructions for 1.0.2 and older
- `RELEASING.md` - release preparation and GitHub upload instructions

The full Buildroot source tree is **not** intended to live permanently in this repository.

## Building

See [BUILDING.md](BUILDING.md) for current instructions.

That document covers:

- Debian/Ubuntu prerequisites
- Arch Linux prerequisites
- current Buildroot workflow using `BR2_EXTERNAL`
- `nwipe` update notes
- troubleshooting and cleanup

## Legacy builds

If you are rebuilding **1.0.2 or older**, see [README_LEGACY.md](README_LEGACY.md).

Those older releases were distributed as a full Buildroot source tree and may require additional workarounds on newer host systems.

## Current recommended workflow

1. Download or clone the latest source from this repository.
2. Download the matching Buildroot release.
3. Build using `shredos-lite-external/` with `BR2_EXTERNAL`.
4. Produce `disk.img` from `output/images/`.
5. Publish `disk.img` and a source archive as release assets.

## What to publish on GitHub

### In the repository

Keep source and documentation only:

- `shredos-lite-external/`
- `README.md`
- `BUILDING.md`
- `README_LEGACY.md`
- `RELEASING.md`

### In GitHub Releases

Upload build artifacts such as:

- `disk.img`
- combined source archive for the release, for example `ShredOS-Lite-v1.0.3.tar.gz`

## Why this layout is better

Older ShredOS-Lite releases placed the main source snapshot in the release assets. That works, but it makes the project harder to maintain.

This newer layout separates:

- **maintained source** in the repository
- **packaged source snapshots and images** in GitHub Releases

That makes future Buildroot updates, `nwipe` updates, and release automation much easier.
