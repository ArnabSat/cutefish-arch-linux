# Cutefish Desktop — Arch Linux GitHub Actions build

This directory is a starter packaging project for building Cutefish on an Arch
Linux GitHub Actions runner. It uses a single **monolithic** `cutefish-desktop-git`
PKGBUILD: the selected upstream components are built in dependency order, staged
under one temporary `/usr` tree, then packaged together as one `.pkg.tar.zst`.

It is deliberately a first-pass community build, not an upstream-supported Arch
package set. The first full CI run is the integration test: upstream `main`
branches and Arch's rolling dependencies can change, so a build may need fixes.

## Included components

The PKGBUILD builds these repositories, in the documented order:

1. `cutefish-toolkit` (including its pinned Skia checkout)
2. `cutefish-framework`
3. `icons`
4. `cutefish-core`
5. `filemanager`
6. `terminal`
7. `xdg-desktop-portal-cutefish`
8. `settings`
9. `system-monitor`
10. `text-editor`
11. `video-player`
12. `calendar`
13. `cutefish-compositor`
14. `wallpapers`

The optional `cutefish-dm`, `qt-plugins`, and `cutefish-computer-use` projects are
not included. In particular, this package does not replace or enable a display
manager; keep your existing SDDM, GDM, LightDM, etc. The desktop session is
installed under `/usr` as required by upstream.

## Custom radius patch

`arch/cutefish-desktop/001-set-corner-radius-8.patch` changes the four values in
`cutefish-toolkit/src/ui/theme.h` so all five radii are 8:

```cpp
double smallRadius = 8;
double mediumRadius = 8;
double bigRadius = 8;
double hugeRadius = 8;
double windowRadius = 8;
```

The PKGBUILD applies it in `prepare()` with `patch -p1`. If upstream changes the
surrounding lines, the build stops instead of silently skipping the customization.
The patch checksum is recorded in `sha256sums`; update it whenever you edit the patch:

```bash
sha256sum arch/cutefish-desktop/001-set-corner-radius-8.patch
```

## Run it on GitHub Actions

1. Create a new GitHub repository, or fork `cutefishos/packaging`.
2. Copy the contents of this archive into the repository root, preserving the
   `.github/` directory (enable viewing hidden files when copying locally).
3. Commit and push to the `main` branch.
4. Open **Actions → Build Cutefish for Arch Linux → Run workflow**.
5. Wait for the job, then download the `cutefish-arch-<commit>` artifact.

A push that changes `arch/**` or this workflow also triggers a build. A scheduled
weekly build is configured as well. The workflow runs in `archlinux:base-devel`,
installs dependencies, creates an unprivileged `builder` account, runs `makepkg`,
and uploads the package artifact. `makepkg` itself is not run as root.

The manual workflow input `build_jobs` defaults to `2`. Keep this low if memory is
limited; Skia is the expensive part of the build. The runner needs outbound network
access because the PKGBUILD fetches the upstream Git repositories and the toolkit's
pinned Skia source.

## Build locally on Arch

Install the dependencies listed in the workflow, then:

```bash
cd arch/cutefish-desktop
makepkg --syncdeps --cleanbuild --noconfirm
```

For a lower-parallelism build:

```bash
BUILD_JOBS=2 makepkg --syncdeps --cleanbuild --noconfirm
```

Install the resulting package with:

```bash
sudo pacman -U ./cutefish-desktop-git-*.pkg.tar.zst
```

## Important packaging notes

- The PKGBUILD tracks upstream `main` branches, so it is a moving Git snapshot.
  For reproducible builds, pin each source to a commit and update those pins
  deliberately.
- Git source entries use `SKIP` checksums, as is normal for VCS sources. The local
  patch has a fixed SHA-256 checksum.
- This initial version packages all built files into one package. It is simpler
  for validating the full build, but less granular than separate Arch packages.
  Splitting libraries, shell components, applications, icons and wallpapers into
  independently upgradeable packages is a sensible next step after the first
  successful build.
- The package has not been built or runtime-tested in this archive-generation
  environment. Treat the first Actions run as a build validation and inspect the
  full log if an upstream or dependency issue appears.
- Do not enable or replace your display manager as part of this package build.

## Upstream references

- Build instructions: https://github.com/cutefishos/getting-started
- Existing Debian packaging/CI: https://github.com/cutefishos/packaging
- Toolkit and Arch dependency list: https://github.com/cutefishos/cutefish-toolkit
