# Releasing ShredOS-Lite on GitHub

This document explains how to organize the repository, prepare release assets, and upload everything to GitHub cleanly.

## Recommended GitHub structure

## Repository contents

The repository should contain **source and documentation only**.

Recommended files and folders:

```text
README.md
BUILDING.md
README_LEGACY.md
RELEASING.md
shredos-lite-external/
```

Do **not** commit generated files such as:

- `output/`
- `dl/`
- `.config`
- `*.img`
- build logs
- downloaded source tarballs

## GitHub Releases contents

Use GitHub Releases for packaged artifacts:

- `disk.img`
- source archive, for example `ShredOS-Lite-v1.0.3.tar.gz`

## Why this is better

Older project organization used release assets as the main place where the source lived. That makes it harder for users to discover the maintained source and harder for you to evolve the project.

The modern structure should be:

- **repository** = maintained source + docs
- **release page** = packaged source snapshot + built image artifacts

## Suggested repository cleanup plan

1. Put the modern source layout in the main branch.
2. Keep old releases available, but point users to `README_LEGACY.md`.
3. Make `1.0.3` the first clean modern release.
4. Put a clear note in `README.md` recommending `1.0.3+`.

## Before you package a new release

Assuming your working tree is:

```text
~/src/
  buildroot-2026.02/
  shredos-lite-external/
```

and you already built successfully.

### 1. Save the built image somewhere safe

```bash
mkdir -p ~/src/release-artifacts
cp ~/src/buildroot-2026.02/output/images/disk.img ~/src/release-artifacts/ShredOS-Lite-v1.0.3-disk.img
```

### 2. Clean the Buildroot tree

```bash
cd ~/src/buildroot-2026.02
make BR2_EXTERNAL=../shredos-lite-external clean
rm -rf output dl .config
```

### 3. Create a release staging directory

```bash
cd ~/src
rm -rf ShredOS-Lite-v1.0.3
mkdir -p ShredOS-Lite-v1.0.3
cp -a buildroot-2026.02 ShredOS-Lite-v1.0.3/
cp -a shredos-lite-external ShredOS-Lite-v1.0.3/
```

### 4. Add documentation to the release staging directory

If your final docs live in the repository root, copy them in:

```bash
cp README.md BUILDING.md README_LEGACY.md RELEASING.md ShredOS-Lite-v1.0.3/ 2>/dev/null || true
```

Or, if you are staging from generated docs:

```bash
cp /mnt/data/README.md /mnt/data/BUILDING.md /mnt/data/README_LEGACY.md /mnt/data/RELEASING.md ShredOS-Lite-v1.0.3/
```

### 5. Create the source archive

```bash
cd ~/src
tar -czf ShredOS-Lite-v1.0.3.tar.gz ShredOS-Lite-v1.0.3
ls -lh ShredOS-Lite-v1.0.3.tar.gz ~/src/release-artifacts/ShredOS-Lite-v1.0.3-disk.img
```

## What to upload where

## A. Push source and docs to the repository

From your local repo root:

```bash
git status
git add README.md BUILDING.md README_LEGACY.md RELEASING.md shredos-lite-external
git commit -m "Prepare ShredOS-Lite 1.0.3 source layout"
git push origin main
```

If your repo branch is not `main`, replace it with the correct branch name.

## B. Create the GitHub release

### Using the GitHub web UI

1. Open your repository on GitHub.
2. Click **Releases**.
3. Click **Draft a new release**.
4. Set the tag, for example:
   - `v1.0.3`
5. Set the release title, for example:
   - `ShredOS-Lite v1.0.3`
6. Upload these assets:
   - `ShredOS-Lite-v1.0.3.tar.gz`
   - `ShredOS-Lite-v1.0.3-disk.img`
7. Publish the release.

### Using GitHub CLI

If `gh` is installed and authenticated:

```bash
gh release create v1.0.3 \
  ~/src/ShredOS-Lite-v1.0.3.tar.gz \
  ~/src/release-artifacts/ShredOS-Lite-v1.0.3-disk.img \
  --title "ShredOS-Lite v1.0.3" \
  --notes "Buildroot 2026.02, nwipe v0.40, modernized build workflow."
```

## Suggested `.gitignore`

Create a `.gitignore` in the repository root with at least:

```gitignore
output/
dl/
.config
*.img
*.tar.gz
*.zip
*.log
build.log
```

## Suggested main README wording

Include a note like this in `README.md`:

```md
## Use version 1.0.3 or newer

For the best experience, use **1.0.3 or newer** by downloading the latest source from the repository or the latest packaged release from GitHub Releases.

If you need instructions for **1.0.2 or older**, see [README_LEGACY.md](README_LEGACY.md).
```

## Final pre-release checklist

Before publishing:

```bash
cd <repo-root>
git status
```

Confirm that:

- only source and docs are staged for commit
- no `output/`, `dl/`, or `.config` files are present
- `disk.img` is stored separately as a release asset
- your release archive contains both `buildroot-2026.02/` and `shredos-lite-external/`

## Recommended release naming

- tag: `v1.0.3`
- image asset: `ShredOS-Lite-v1.0.3-disk.img`
- source asset: `ShredOS-Lite-v1.0.3.tar.gz`
