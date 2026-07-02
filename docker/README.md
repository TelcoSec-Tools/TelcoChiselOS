# TelcoChisel Container Images

Docker images of the TelcoChisel toolset, as an alternative to booting the
[live ISO](../README.md). Useful when you just want to run a specific tool
(`nmap`, `pySim-shell`, `UERANSIM`, …) without booting a full desktop OS.

**This is a second, narrower delivery format, not a replacement for the ISO.**
The live ISO remains the right vehicle for the full SDR/RAN research
experience — desktop GUI tools, kernel-module-dependent tools (`gtp5g`),
realtime/kernel-cmdline tuning, and the systemd-managed ChiselControl
dashboard are either unavailable or degraded in a container. See "Known
limitations" below before choosing a container over the ISO for a given task.

## Images

| Image | Contents | Runtime needs |
|-------|----------|----------------|
| `telcochisel-base` | Headless CLI toolset: nmap, tshark, Scapy, SIPVicious, sctpscan, SigPloit, Diafuzzer, FirmWire, QCSuper, MTKClient, pySim, lpac, SIMtrace2, SIMurai, UERANSIM, SCAT, kalibrate-gsm, SIMTester, LTESniffer, RouterSploit, sipp, telecom wordlists | none |
| `telcochisel-sdr` | `FROM base` + SoapySDR/UHD/LimeSuite/HackRF/BladeRF/rtl-sdr, GNU Radio, GQRX, gr-gsm, kalibrate-rtl (conda `telcosec-sdr` env) | USB device passthrough; X11 for GQRX |
| `telcochisel-core-network` | `FROM base` + srsRAN/Open5GS/OAI-UE/5Ghoul first-run helper stubs and their build deps prebaked | `NET_ADMIN`, `/dev/net/tun`, often host networking |
| `telcochisel-device-tools` | `FROM base` + Heimdall, ADB/Fastboot, MTKClient wrappers, QCSuper, EDL, AT console | USB/serial device passthrough |

Matches the ISO's own "ready" vs. "setup" tool taxonomy (see the main
`CLAUDE.md`) — the core-network image's helpers (`srsran-install`,
`open5gs-install`, `oai-install`, `5ghoul-install`, `gtp5g-load`) are
first-run compiles, not pre-built binaries, same as on the ISO.

## Build

Build context is the **repo root**, not `docker/` — the Dockerfiles `COPY`
`builder/scripts/lib/*` (the single source of truth for package lists)
directly, so run these from the repo root:

```bash
docker build -f docker/base.Dockerfile         -t telcochisel-base .
docker build -f docker/device-tools.Dockerfile -t telcochisel-device-tools .
docker build -f docker/sdr.Dockerfile          -t telcochisel-sdr .
docker build -f docker/core-network.Dockerfile -t telcochisel-core-network .
```

or with Compose:

```bash
docker compose -f docker/compose.yaml build
```

`telcochisel-sdr` is the slowest build (UHD alone takes 15-20 minutes).

The three add-on Dockerfiles accept a `BASE_IMAGE` build arg (default:
`telcochisel-base`, i.e. whatever you just built locally). CI overrides it to
pull the freshly-pushed registry tag instead, since buildx's containerized
builder doesn't share the local Docker daemon's image cache:
`--build-arg BASE_IMAGE=ghcr.io/<owner>/telcochisel-base:<version>`.

## Run

```bash
# Base — no special flags
docker run --rm -it telcochisel-base

# SDR — USB passthrough + X11 for GQRX
docker run --rm -it \
  --device /dev/bus/usb \
  -e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  telcochisel-sdr

# Core network — NET_ADMIN + tun device, usually host networking
docker run --rm -it \
  --cap-add=NET_ADMIN --device /dev/net/tun --network host \
  telcochisel-core-network

# Device tools — USB + serial passthrough
docker run --rm -it \
  --device /dev/bus/usb --device /dev/ttyUSB0 \
  telcochisel-device-tools
```

Or via Compose: `docker compose -f docker/compose.yaml run --rm sdr`, etc.
See `docker/compose.yaml` for the full flag set per image.

## Package reuse boundary

The Dockerfiles are **fresh** — they do not source or modify the 13
provisioning scripts under `builder/scripts/` or `build-iso.sh`, so the ISO
build is unaffected by anything in this directory. What they *do* reuse:

- `builder/scripts/lib/packages.sh` — the `PKGS_*` arrays, verbatim. This
  stays the single source of truth for package names; a package added there
  is available to container scripts automatically.
- `builder/scripts/lib/pip-retry.sh`, `pip-constraints.txt`, `record-tool.sh`
  — the pip retry wrapper and build-verification helper, verbatim.
- `docker/scripts/00-container-common.sh` defines `CONTAINER_PKG_BLOCKLIST` —
  package names that only make sense for the live ISO / a desktop / a real
  kernel and init system (`casper`, `xfce4`, `lightdm`, `grub-*`, `calamares`,
  `tuned`, …) — and `filter_pkgs()`, which strips them out of any `PKGS_*`
  array before `apt-get install`. GUI tools that work under the optional
  X11-passthrough model (`wireshark`, `gqrx`, `twinkle`, `baresip`) are
  deliberately **kept**, not blocklisted.
- The tool **build steps** themselves (source builds in `docker/scripts/10-
  base-tools.sh`, `20-sdr.sh`, `30-core-network.sh`, `40-device-tools.sh`)
  are copied from the corresponding `builder/scripts/0N-*.sh` step, with
  `sudo`/`chown telcosec`/`systemctl enable`/udev/`.desktop` launcher lines
  dropped since they don't apply to a container build. If you fix a build
  step in one place, check whether the other needs the same fix — see each
  script's header comment for which `builder/scripts/*.sh` it mirrors.

## Known limitations

These are containerization realities, not missing features to "fix" — see
each helper's own `docker/scripts/30-core-network.sh` comments for detail:

- **`gtp5g` (kernel module).** Cannot be built against, or loaded into, the
  container's host kernel from inside an unprivileged container.
  `gtp5g-load` checks for matching kernel headers and fails with a clear
  message rather than silently doing nothing; load it on the host instead.
- **Open5GS.** Upstream's install flow is `docker compose` — a container-in-
  container pattern. `open5gs-install` needs a mounted host Docker socket
  (see `docker/compose.yaml`'s `core-network` service) or true
  Docker-in-Docker; it cannot work fully isolated.
- **Realtime/PAM limits, `mitigations=off`, hugepages, sysctl tuning.** These
  are host-kernel/boot-cmdline concerns (see the ISO's `08-system-
  optimization.sh` and the "Security Posture" section of the main
  `CLAUDE.md`) and are simply not applicable inside a container — set them
  on the Docker host if RAN performance requires it.
- **GUI tools (GQRX, Wireshark GUI, gnuradio-companion, softphones).** Shipped
  in the relevant image, but need an X11 socket mounted from a Linux host
  (see the `sdr` run recipe above). No VNC/noVNC server is bundled — Windows/
  Mac users without an X server should use the live ISO for GUI tools instead.
- **SDR/USB/serial hardware.** Every device-touching tool is a no-op without
  the corresponding `--device`/`--privileged` flag at `docker run` time —
  building an image never requires hardware, only running against real RF or
  USB/serial devices does.

## CI / publishing

`.github/workflows/docker.yml` builds all four images via a buildx matrix and
pushes to `ghcr.io/telcosec-tools/telcochisel-{base,sdr,core-network,device-tools}`
on `workflow_dispatch` or `v*.*.*` tag pushes, tagged `latest` + the version.
Independent of `.github/workflows/release.yml` (the ISO release path) — a
Docker publish never blocks or is blocked by an ISO release.

## Smoke testing

```bash
bash docker/smoke-test.sh --build   # build all four images, then test
bash docker/smoke-test.sh           # test images already built locally
```

Runs a representative tool per category with `--version`/`--help` in each
image and asserts success. This is a build/PATH sanity check, not a
functional test of SDR/network features — those need real hardware/privilege
(see "Known limitations" above).
