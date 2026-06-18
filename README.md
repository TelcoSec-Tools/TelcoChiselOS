<div align="center">

# TelcoChisel

**Bootable Linux distribution for 5G/4G telecom security research, SDR analysis, and baseband auditing**

[![Build ISO](https://github.com/TelcoSec/TelcoChisel/actions/workflows/release.yml/badge.svg)](https://github.com/TelcoSec/TelcoChisel/actions/workflows/release.yml)
[![Docs](https://github.com/TelcoSec/TelcoChisel/actions/workflows/deploy-docs.yml/badge.svg)](https://tschisel.telcosec.net)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-00ffd5.svg)](LICENSE)
[![Download](https://img.shields.io/sourceforge/dt/telcochisel?logo=sourceforge&label=Downloads)](https://sourceforge.net/projects/telcochisel/)

[**Documentation →**](https://tschisel.telcosec.net) · [**Download ISO**](https://sourceforge.net/projects/telcochisel/) · [**Community**](https://community.telcosec.cloud) · [**Academy**](https://app.telcosec.cloud)

</div>

---

TelcoChisel is a free, bootable live Linux OS purpose-built for cellular security researchers, SDR engineers, and hardware pentesters. Based on **Ubuntu 24.04 LTS (Noble Numbat)** with a GNOME Shell desktop, it ships with 50+ pre-configured tools for SDR transceiver operation, 5G/4G core network simulation, baseband firmware emulation, SIM/eSIM auditing, GSM/2G base station emulation, VoIP analysis, and telecom protocol exploitation — ready to use without installation.

**Live boot credentials:** `telcosec` / `telcosec`

---

## What's Included

### Software Defined Radio (SDR)

Radio drivers are sandboxed in a dedicated Conda environment (`telcosec-sdr`) to isolate them from system Python and prevent ABI conflicts between hardware library versions.

| Tool | Purpose |
|------|---------|
| **GNU Radio 3.10** | Primary DSP framework and flowchart design suite |
| **SoapySDR** | Vendor-neutral SDR hardware abstraction layer |
| **UHD (USRP Hardware Driver)** | Ettus Research USRP B210/X310 driver, compiled from source |
| **HackRF Host Tools** | HackRF One firmware, configuration, and RX/TX utilities |
| **gr-gsm** | GNU Radio blocks for receiving and decoding GSM air interfaces |
| **Kalibrate-RTL** | RTL-SDR local oscillator calibration against live GSM cells |
| **GQRX** | Spectrum analyzer and SDR receiver GUI |

**Supported hardware:** USRP B210, HackRF One, BladeRF 2.0 xA4, LimeSDR, RTL-SDR

### 5G / 4G RAN Simulation

| Tool | Purpose |
|------|---------|
| **srsRAN** | Open-source 4G eNB/5G gNB and UE RAN simulator |
| **Open5GS** | Complete 5G SA core (AMF, SMF, UPF, UDM, HSS) + 4G EPC |
| **UERANSIM** | 5G SA UE and gNB simulator; pre-configured for test PLMN 001/01 |
| **OAI UE** | OpenAirInterface 5G NR UE with full PHY/MAC/RLC stack |
| **srsUE** | Software UE for LTE attach procedure and downlink capture testing |
| **5Ghoul Fuzzer** | 5G NR baseband fuzzer over OAI rogue gNodeB (deferred compile) |

### Baseband & UE Analysis

| Tool | Purpose |
|------|---------|
| **FirmWire** | Samsung Shannon and MediaTek baseband emulation and fuzzing |
| **QCSuper** | Qualcomm DIAG USB protocol logger → PCAP (OTA messages) |
| **SCAT** | Qualcomm/Samsung modem diagnostic parser → PCAP with NAS/RRC |
| **MTKClient** | BROM bypass, partition editor, and flasher for MediaTek devices |
| **Balong-Flash** | Huawei Balong LTE modem firmware tool |
| **MobileInsight** | Android diagnostic log parser and analyzer |

### SIM & eSIM Auditing

| Tool | Purpose |
|------|---------|
| **Osmocom SIMtrace 2** | ISO 7816 sniffer between modem and SIM card |
| **pySim-shell** | Interactive SIM/USIM management and scripting shell |
| **lpac** | eSIM Local Profile Assistant (GSMA SGP.22 LPA) |
| **pcscd** | PC/SC smartcard interface daemon |

### Signaling & Protocol Tools

| Tool | Purpose |
|------|---------|
| **Wireshark / TShark** | Custom profiles: GSMTAP, 5G NAS, Diameter, GTP column views |
| **SigPloit** | SS7, Diameter, and GTP exploitation framework |
| **Diafuzzer** | Orange Security Diameter fuzzer (S6a, Gx, Gy interfaces) |
| **sctpscan** | SCTP port scanner for SIGTRAN/S1AP/NGAP/Diameter endpoints |
| **SIPVicious** | SIP/VoIP auditing toolkit (svmap, svwar, svcrack) |
| **Scapy** | Packet crafting with M3UA, TCAP, MAP, and Diameter modules |
| **SIPp** | SIP load tester and traffic generator |

### Device Flashing & AT Tools

ADB, Fastboot, Heimdall (Samsung), EDL (Qualcomm 9008), Gammu, Minicom, AT Command Console, ModMobMap, LTESniffer, LTE-CellScanner

### GSM/2G & VoIP

YateBTS and OpenBTS for rogue GSM base station emulation, kalibrate-gsm for channel scanning, and SIPVicious/SIPp/Twinkle/Linphone/Baresip for VoIP/SIP auditing.

---

## OS Optimizations

TelcoChisel applies kernel-level tuning required by telecom tools out of the box:

- **Real-time scheduling** — PAM limits and `realtime` group allow GNU Radio and srsRAN threads to lock memory and run at SCHED_RR priority 99 (prevents RF sample drops)
- **SCTP stack tuning** — Pre-loaded `sctp` module; socket buffer sizes and RTO limits tuned for SIGTRAN/Diameter scanning
- **Low-latency USB** — udev rules disable autosuspend on USRP, HackRF, and BladeRF devices
- **Kernel security hardening** — ASLR, protected hardlinks/symlinks, dmesg restrictions, disabled ICMP redirects
- **Non-root hardware access** — `/etc/udev/rules.d/50-telcosec-hw.rules` maps USB IDs for HackRF, USRP, LimeSDR, BladeRF, and SIMtrace 2 to the `plugdev` group
- **UFW firewall** — Enabled by default; blocks incoming, allows outgoing

---

## Building the ISO

The build requires an Ubuntu or Debian host (or WSL2). Allow **30–60 minutes** and **~20 GB** free disk space.

### Prerequisites

```bash
sudo apt-get install -y debootstrap squashfs-tools grub-pc-bin grub-efi-amd64-bin xorriso mtools
```

### Build

```bash
sudo ./build-iso.sh
```

Output: `TelcoChisel-live.iso`

### Build on Windows (WSL2)

```bash
wsl -d kali-linux -u root -- bash -c "cd //mnt//m//TelcoChisel && ./build-iso.sh"
```

### CI/CD

Every push to `main` triggers an automated build via GitHub Actions (`.github/workflows/release.yml`). Tagged releases (`v*.*.*`) produce a GitHub Release with the ISO attached as a downloadable artifact.

---

## 5Ghoul — 5G NR Baseband Fuzzer

5Ghoul is not compiled during ISO build (OAI compilation takes 30+ minutes and would inflate the image). All build dependencies are pre-installed. On first use:

```bash
# USRP B210
sudo 5ghoul-install

# BladeRF 2.0 xA4
sudo 5ghoul-install --radio BLADERF
```

Then run a fuzzing attack:

```bash
sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz
```

See the [5Ghoul setup guide](https://tschisel.telcosec.net/#fuzzer) for full configuration.

---

## Documentation

Full documentation at **[tschisel.telcosec.net](https://tschisel.telcosec.net)** — tool catalog, OS tuning details, hardware setup, and the ISO build pipeline reference.

Offline documentation is bundled in the live ISO at `/usr/share/doc/telcosec/index.html` (accessible from the Firefox home page without network).

---

## Architecture

```
build-iso.sh                  # Orchestrates the entire build
builder/
  scripts/
    00-install-all-packages.sh  # Single consolidated apt transaction
    01-install-base.sh          # GNOME desktop, GDM3, users, SSH
    02-install-sdr.sh           # Conda env + SDR drivers from source
    03-install-core-network.sh  # srsRAN + Open5GS
    04-install-tools.sh         # Wireshark, SigPloit, Diafuzzer, Scapy
    05-desktop-customization.sh # Wallpaper, MOTD, Firefox policies
    06-install-ue-analysis.sh   # FirmWire, QCSuper, pySim, SIMtrace 2
    07-install-installer.sh     # Calamares live-to-disk installer
    08-system-optimization.sh   # udev rules, PAM limits, SCTP tuning
    09-install-5ghoul.sh        # 5Ghoul build deps + helper scripts
    10-install-telecom-advanced.sh # UERANSIM, YateBTS, OpenBTS, srsGUI, etc.
    11-install-device-tools.sh  # Samsung/Qualcomm/MediaTek device wrappers
  calamares/                    # Installer branding and module config
  docs/                         # Offline docs bundled in the ISO
  menu/                         # GNOME application menu + .desktop files
  udev/                         # USB hardware access rules
docs/                           # GitHub Pages documentation portal (Nuxt 3)
```

---

## Community

| | |
|---|---|
| **Documentation** | [tschisel.telcosec.net](https://tschisel.telcosec.net) |
| **Academy** | [app.telcosec.cloud](https://app.telcosec.cloud) |
| **Community Hub** | [community.telcosec.cloud](https://community.telcosec.cloud) |
| **Research Blog** | [blog.telcosec.cloud](https://blog.telcosec.cloud) |
| **Discord** | [discord.gg/RykzXTQFXF](https://discord.gg/RykzXTQFXF) |

---

> **Legal notice:** TelcoChisel is intended for authorized security research, penetration testing engagements, and educational use in controlled lab environments. Users are responsible for ensuring their use complies with applicable laws and regulations. Unauthorized interception of cellular communications is illegal in most jurisdictions.
