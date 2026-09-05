# Changelog

All notable changes to the **TelcoChisel Live Linux Distribution** are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [3.0.0] - 2026-09-05 (Noble Numbat)

### Added
- **Dual-Tier ISO Release Architecture**:
  - **Flagship Field Edition (Full)** (`TelcoChisel-3.0.0-amd64.iso`, ~5.0 GB): 100% offline air-gapped readiness with all 88 pre-installed telecom tools, UHD FPGA firmware images (`/usr/share/uhd/images/`), GNU Radio 3.10 Conda environment, Open5GS, srsRAN, and FirmWire baseband emulation.
  - **Modular Lite Edition (Lite)** (`TelcoChisel-3.0.0-lite-amd64.iso`, ~1.8 GB): Clean base XFCE desktop, 1000Hz Low-Latency kernel, Wireshark/TShark, Python runtime, and the `telcosec-pkg` CLI client for pulling modular suites on demand.
- **Base Distribution & Kernel**:
  - Upgraded to **Ubuntu 24.04 LTS (Noble Numbat)** base with real-time `linux-image-lowlatency` (1000Hz timer, preemptible) as the default boot kernel.
  - Dual-kernel fallback architecture (`linux-image-generic` alongside low-latency kernel).
  - SCTP kernel tuning, unlimited `RLIMIT_MEMLOCK`, and `SCHED_RR` real-time scheduling for drop-free SDR streaming.
- **Debian Metapackages (`meta.telcosec.net`)**:
  - Introduced 8 modular domain packages in `debian/control`: `telcochisel-base`, `telcochisel-sdr`, `telcochisel-5g-sa`, `telcochisel-4g-lte`, `telcochisel-sim`, `telcochisel-baseband`, `telcochisel-wireline`, and `telcochisel-all`.
  - Built custom CLI package manager `telcosec-pkg` with interactive curses menu, search, installation, and dependency management.
- **Hardware & Driver Stacks**:
  - Out-of-the-box hardware drivers compiled from source: Ettus USRP (UHD 4.6.0), Great Scott Gadgets HackRF (`libhackrf` 2024.02.1), Nuand BladeRF 2.0 micro (`libbladeRF` 2.5.0), LimeSDR (`LimeSuite` 23.11.0), and RTL-SDR v3/v4.
  - Smart card audit suite: Sysmocom SIMtrace 2, Osmocom SIMtrace, and Omnikey/Identiv/ACS PCSC readers.
  - Baseband reverse engineering interfaces: Qualcomm EDL / QCSuper, MediaTek `mtkclient`, and Samsung Shannon FirmWire emulator.
- **Automated CI/CD Pipelines**:
  - `.github/workflows/ci.yml`: Sub-45s automated pre-merge CI validating `bash -n` across all 35 provisioning scripts, three-way tool catalog parity, YAML schemas, and Unix LF line endings.
  - `.github/workflows/docker.yml`: Unified container pipeline building 4 multi-platform images (`base`, `sdr`, `core-network`, `device-tools`) with GHA caching, simultaneously publishing to GHCR and Docker Hub.
  - `.github/workflows/deploy-docs.yml`: Optimized Nuxt 3 documentation build with pnpm store caching and automated deployment to both GitHub Pages and SourceForge Project Web.
- **SourceForge Integration & UX**:
  - Automated REST API default download pinning with custom label `Download TelcoChisel Flagship Field Edition (${VERSION})`.
  - Enriched `docs/SOURCEFORGE_FILES_README.md` with hardware compatibility matrix, operator first 60 seconds cheatsheet, and direct review call-to-action.
  - Live desktop application launcher `Rate TelcoChisel on SourceForge` (`builder/menu/applications/telcosec-feedback.desktop`).
  - Synced offline documentation (`builder/docs/index.html`) with online portal, featuring v3.0.0 dual-edition modal and community cards.
- **Installation & Persistence**:
  - Calamares GUI live-to-disk installer with customized TelcoChisel dark theme and automated user creation.
  - Dedicated LUKS-encrypted persistence utility (`telcosec-create-usb`) creating AES-XTS encrypted `casper-rw` partitions.
  - Copy-to-RAM (`toram`) boot mode for maximum I/O performance on systems with 16GB+ RAM.

### Changed
- Refactored `build-iso.sh` with `--flavor=full|lite` dynamic build phasing, package filtering, and automatic compiler cache purging.
- Optimized `release.yml` to generate ISO split chunks once into the workspace, eliminating redundant 5GB multi-part splitting.
- Upgraded tool catalog to 88 tools with unified metadata synchronized across JSON, Vue 3, and static offline HTML.

### Removed
- Standalone 500 KB `yaru-theme-gtk_25.10.3-3_all.deb` (installed via standard APT repository).
- Compiled Python bytecode accidentally tracked in git (`generate-assets.cpython-312.pyc`).
- Redundant `.github/workflows/docker-hub.yml` workflow (merged into `docker.yml`).
- Obsolete one-off maintenance scripts (`update_desktop.py`, redundant `docs/CNAME`).

---

## [1.1.0] - 2026-08-15

### Added
- Expanded tool suite to 75 tools covering 2G/3G/4G cellular protocols.
- Integrated Conda environment `telcosec-sdr` for isolated GNU Radio 3.10 and PySDR dependencies.
- Added Open5GS 5G Standalone core network pre-configuration with MongoDB persistence.
- Added 5Ghoul 5G NR over-the-air fuzzing framework.
- Preliminary SourceForge File Release System distribution.

### Changed
- Migrated default shell configuration to Zsh with Powerline prompt and telecom command completions.
- Improved udev rules coverage for Nuand BladeRF 2.0 micro and RTL-SDR v4.

---

## [1.0.0] - 2026-07-01

### Added
- Initial proof-of-concept Live Linux ISO release based on Ubuntu 22.04 LTS.
- XFCE4 desktop environment with dark telecom styling.
- Core SDR drivers: UHD, HackRF, and RTL-SDR.
- Wireshark with preliminary GSMTAP dissector configuration.
- Basic live boot with credentials `telcosec` / `telcosec`.
