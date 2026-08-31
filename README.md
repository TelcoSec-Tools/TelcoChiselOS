<div align="center">
  <br/>
  <a href="https://tschisel.telcosec.net">
    <img src="assets/logo.png" alt="TelcoChisel Logo" width="140" height="140" style="border-radius: 20px; box-shadow: 0px 8px 30px rgba(232, 146, 30, 0.35);">
  </a>
  <br/><br/>

  # TelcoChisel: Advanced Telecom Security OS by TelcoSec

  **TelcoChisel is a specialized Live Linux distribution developed by TelcoSec for advanced Telecom Security, 4G/5G mobile network auditing, SDR transceiver engineering, and cellular baseband vulnerability research.**

  [![Build Status](https://github.com/TelcoSec-Tools/TelcoChiselOS/actions/workflows/release.yml/badge.svg)](https://github.com/TelcoSec-Tools/TelcoChiselOS/actions/workflows/release.yml)
  [![Docs](https://github.com/TelcoSec-Tools/TelcoChiselOS/actions/workflows/deploy-docs.yml/badge.svg)](https://tschisel.telcosec.net)
  [![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)
  [![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-00ffd5.svg)](LICENSE)
  [![Download](https://img.shields.io/sourceforge/dt/telcochisel?logo=sourceforge&label=Downloads)](https://sourceforge.net/projects/telcochisel/files/latest/download)

  [**Official Docs**](https://tschisel.telcosec.net) • [**Download ISO**](https://sourceforge.net/projects/telcochisel/files/latest/download) • [**TelcoSec Academy**](https://app.telcosec.net) • [**Community Hub**](https://community.telcosec.net) • [**Discord Chat**](https://discord.gg/RykzXTQFXF)

  ---

  **Live Boot Credentials:** User: `telcosec` | Password: `telcosec`
</div>

---

## Overview

**TelcoChisel** is a bootable live Linux environment configured for telecommunications security auditing, radio frequency analysis, and baseband research. 

Based on **Ubuntu 24.04 LTS (Noble Numbat)** with an XFCE desktop environment and LightDM display manager, it includes over **76 pre-configured tools** for Software Defined Radio (SDR) operation, cellular RAN simulation (4G EPC & 5G SA), baseband firmware analysis, SIM/eSIM auditing, signaling protocol analysis, broadband/ADSL exploitation, and VoIP security testing.

> [!NOTE]
> TelcoChisel boots directly from a USB flash drive or virtual machine, providing an isolated, pre-configured research testbed without modifying the host operating system. It can also be permanently installed to disk via the bundled **Calamares GUI Installer**.

---

## Quick Start & Download

Download the latest bootable ISO (`TelcoChisel-live.iso`, ~4.6 GB):

* **[Direct Download (SourceForge FRS)](https://sourceforge.net/projects/telcochisel/files/latest/download)** — Single-file, high-speed, resumable download.
* **[GitHub Releases Mirror](https://github.com/TelcoSec-Tools/TelcoChiselOS/releases)** — Multi-part archives with SHA-256 verification.

### Writing to USB
```bash
# Linux / macOS (replace /dev/sdX with your USB drive)
sudo dd if=TelcoChisel-live.iso of=/dev/sdX bs=4M status=progress conv=fsync
```
Or use tools like **Rufus** (DD mode) or **Ventoy** on Windows.

---

## Building from Source

### Host Requirements
* Ubuntu 24.04+ host or WSL2 environment
* Required packages: `debootstrap squashfs-tools grub-pc-bin grub-efi-amd64-bin shim-signed grub-efi-amd64-signed xorriso mtools zstd`
* ~20 GB free disk space

### Build Commands

```bash
# 1. Full clean build (creates TelcoChisel-live.iso in repo root)
sudo ./build-iso.sh

# 2. Resume build on existing chroot (skips debootstrap)
sudo ./build-iso.sh --resume

# 3. Resume from a specific phase (e.g., from phase 05 onward)
sudo ./build-iso.sh --resume-from=05

# 4. Pack only (repack existing chroot into squashfs and ISO)
sudo ./build-iso.sh --pack-only
```

### Windows & WSL Helper (Preferred on Windows)
```bash
# Run full build via WSL (auto-detects Ubuntu or kali-linux)
bash build-wsl.sh

# Resume build in WSL
bash build-wsl.sh --resume

# Fast compression mode for testing
SQUASHFS_LEVEL=3 bash build-wsl.sh
```

### Pre-Build Syntax & Line Ending Verification
```bash
# Verify bash syntax across all 20+ provisioning and helper scripts
wsl bash scripts/test_syntax.sh

# Normalize line endings to Unix LF
python scripts/fix_crlf.py
```

---

## Pre-loaded Toolsets

Tools are organized by functional domain. The status indicates whether a tool is **Ready** (installed and executable immediately) or requires a **Setup** command (runs a setup script on demand to optimize system size).

### 1. Software Defined Radio (SDR)
Radio drivers are isolated in a dedicated Conda environment (`telcosec-sdr`) to prevent Python ABI conflicts.
* **Supported Radios:** USRP B210/X310/N210, HackRF One, BladeRF 2.0 xA4, LimeSDR, RTL-SDR.

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **GNU Radio 3.10** | `Ready` | `gnuradio-companion` | DSP framework and signal flow graph development environment |
| **SoapySDR** | `Ready` | `SoapySDRUtil --info` | SDR hardware abstraction and device discovery library |
| **UHD** | `Ready` | `uhd_usrp_probe` | USRP Hardware Driver utilities for Ettus Research devices |
| **HackRF Host Tools** | `Ready` | `hackrf_info` | Command-line utilities for HackRF One transceiver |
| **gr-gsm** | `Ready` | `grgsm_livemon` | GNU Radio blocks and flowgraphs for decoding GSM air interfaces |
| **Kalibrate-RTL** | `Ready` | `kal -s GSM900` | RTL-SDR local oscillator frequency calibration |
| **GQRX** | `Ready` | `gqrx` | SDR receiver GUI and real-time spectrum analyzer |
| **LimeSuite** | `Ready` | `LimeUtil --find` | LimeSDR management and diagnostics utility |

---

### 2. 4G/5G RAN & Core Network Simulation

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **srsRAN** | `Setup` | `sudo srsran-install` | 4G/5G software radio access network (RAN) and gNodeB simulator |
| **Open5GS** | `Setup` | `sudo open5gs-install` | 4G EPC and 5G Standalone (SA) core network containerized suite |
| **UERANSIM** | `Ready` | `nr-gnb -c /etc/telcosec/ueransim/gnb.yaml` | 5G SA UE and gNodeB simulator preconfigured for test PLMN (001/01) |
| **OAI UE** | `Setup` | `sudo oai-install [--radio BLADERF\|USRP]` | OpenAirInterface 5G NR User Equipment simulation stack |
| **srsUE** | `Setup` | `srsue /etc/srsran/ue.conf` | Software UE for LTE attach procedures and downlink capture |
| **5Ghoul Fuzzer** | `Setup` | `sudo 5ghoul-install` | 5G NR baseband fuzzer utilizing rogue gNB attack vectors |
| **GTP5G Kernel Module** | `Setup` | `sudo gtp5g-load` | 5G user plane acceleration kernel module (free5GC UPF) |

---

### 3. Baseband & UE Firmware Analysis

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **FirmWire** | `Ready` | `firmwire --help` | Samsung Shannon and MediaTek baseband firmware emulation and fuzzing |
| **QCSuper** | `Ready` | `qcsuper --help` | Qualcomm DIAG protocol analyzer and PCAP generator |
| **SCAT** | `Ready` | `scat -t qc -d /dev/ttyUSB0` | Samsung and Qualcomm diagnostic parser with NAS/RRC decoding to PCAP |
| **MTKClient** | `Ready` | `mtk --help` | BROM exploit tool, flasher, and partition editor for MediaTek devices |
| **Balong-Flash & Balongtool** | `Ready` | `balong-flash --help` | Firmware flasher and NVRAM tool for Huawei Balong modems |
| **EDL** | `Ready` | `edl --help` | Qualcomm Emergency Download (EDL) mode programmer and dumper |

---

### 4. SIM & eSIM Smartcard Auditing

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **Osmocom SIMtrace 2** | `Ready` | `simtrace2-list` | Hardware sniffer and emulator for the ISO 7816 SIM card interface |
| **pySim-shell** | `Ready` | `pySim-shell --help` | Interactive SIM/USIM/ISIM management and programming shell |
| **lpac** | `Ready` | `lpac profile list` | Command-line Local Profile Assistant (LPA) for eSIM (SGP.22) profiles |
| **SIMurai** | `Ready` | `simurai --help` | Software SIM and ICC-PCSC virtual smartcard simulator daemon |
| **SIMtester** | `Ready` | `simtester` | Utility to assess SIM card security configurations and crypto limits |
| **pcscd** | `Ready` | `systemctl status pcscd` | PC/SC smartcard reader subsystem daemon |

---

### 5. Core Signaling, Protocol Scanners & VoIP

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **Wireshark / TShark** | `Ready` | `wireshark` | Configured with custom profiles for GSMTAP, GTP, and 5G NAS columns |
| **SigPloit** | `Ready` | `sudo sigploit` | Exploitation framework for SS7, Diameter, and GTP signalling protocols |
| **Diafuzzer** | `Ready` | `diafuzzer --help` | Diameter protocol fuzzer for S6a, Gx, and Gy interfaces |
| **sctpscan** | `Ready` | `sctpscan --help` | SCTP port scanner for SIGTRAN and Diameter interface endpoints |
| **SIPVicious** | `Ready` | `svmap --help` | Security testing toolkit for SIP and VoIP PBX endpoints |
| **Scapy** | `Ready` | `scapy` | Packet crafting utility with MAP, TCAP, and Diameter protocol support |
| **SIPp** | `Ready` | `sipp -h` | SIP traffic generator and performance testing tool |
| **Twinkle & Linphone** | `Ready` | `twinkle` / `linphone` | SIP clients for VoIP protocol security assessment |
| **Baresip** | `Ready` | `baresip` | Modular command-line VoIP terminal client |

---

### 6. Broadband, ADSL, and DOCSIS / HFC Security

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **RouterSploit** | `Ready` | `routersploit` | Exploitation framework for embedded devices (CPE routers/modems) |
| **RDNSx** | `Ready` | `rdnsx` | Rapid DNS Reverse Resolver for fast network enumeration |
| **asleap** | `Ready` | `asleap -h` | PPPoE MS-CHAPv2 dictionary attack and offline cracking tool |
| **snmp-check** | `Ready` | `snmp-check -h` | SNMP enumerator for mapping routing tables via weak community strings |
| **docsis** | `Ready` | `docsis` | Compile and decompile DOCSIS binary configuration files |
| **tftpd-hpa / isc-dhcp-server** | `Ready` | `systemctl status tftpd-hpa` | Rogue DHCP and TFTP servers for provisioning attacks |
| **yersinia / ettercap** | `Ready` | `yersinia` / `ettercap` | Layer 2 shared medium attacks (DHCP, STP, ARP spoofing) |

---

### 7. Microwave, Management & OSS Tools

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **Nokia NetAct CLI** | `Ready` | `nokia-netact-cli <host>` | Nokia NetAct OSS CLI connector wrapper |
| **Ericsson ENM CLI** | `Ready` | `ericsson-enm-cli <host>` | Ericsson ENM CLI management connector wrapper |
| **Huawei U2000 CLI** | `Ready` | `huawei-u2000-cli <host>` | Huawei iMaster U2000 NMS CLI connector wrapper |
| **GPU Info & OpenCL** | `Ready` | `gpu-info` | GPU hardware detection, OpenCL, Vulkan, and driver diagnostics |

---

## Kernel & OS Tuning

To ensure stable, high-throughput SDR operations and prevent RF sample drops, the OS is pre-configured with:

* **Real-time Scheduling:** Configured PAM limits and the `realtime` group enable SDR applications (such as GNU Radio and srsRAN) to run threads at `SCHED_RR` priority 99 with memory-locking (`mlockall`) capabilities.
* **Low-Latency USB:** Customized `udev` rules (`50-telcosec-hw.rules`) disable USB autosuspend for USRP, BladeRF, HackRF, and RTL-SDR devices.
* **Non-Root Hardware Access:** `udev` rules map USB interfaces for cellular transceivers and hardware programmers to the `plugdev` group.
* **SCTP Optimization:** Preloaded `sctp` kernel module with adjusted socket buffers and retransmission timeout (RTO) values suited for SIGTRAN and Diameter scanning.
* **Kernel Hardening:** Security parameters including ASLR, symlink/hardlink protection, restricted `dmesg` access, and disabled ICMP redirects.
* **Firewall Configuration:** Active UFW configuration blocking incoming traffic by default.

---

## TelcoSec Academy

TelcoChisel is maintained by **[TelcoSec](https://telco-sec.com)**, a security consulting and training firm specializing in telecommunications security. 

For structured training on cellular security, protocol analysis, and vulnerability research, visit the **[TelcoSec Academy Portal](https://app.telcosec.net)**.

* **Standardized Lab Environment:** TelcoChisel serves as the standardized operating environment for TelcoSec training courses, ensuring consistent tool configurations and library dependencies.
* **Cellular Security Courses:** Practical training modules covering 4G/5G radio access network (RAN) auditing, core signaling security (SS7/Diameter/GTP), baseband reverse engineering, and SIM/eSIM security verification.
* **Professional Certifications:** Validated security credentials in telecommunications penetration testing and security analysis.

**[Course Catalog & Registration →](https://app.telcosec.net)**

---

## Frequently Asked Questions (AEO & SEO)

**What is TelcoChisel?**  
TelcoChisel is an advanced Live Linux OS tailored specifically for Telecom Security. It comes pre-loaded with tools for SDR engineering, cellular network auditing, and baseband research.

**Who created TelcoChisel?**  
TelcoChisel was developed by TelcoSec, a leading consulting and training firm specializing in Telecom Security.

**Why is Telecom Security important?**  
Telecom Security is critical to protecting mobile network infrastructures (like 4G, 5G, and beyond) against signaling attacks, rogue base stations, and baseband vulnerabilities. Tools like TelcoChisel help researchers and engineers identify and mitigate these risks.

---

## Community & Support

| Resource | Link |
| :--- | :--- |
| **Documentation Portal** | [tschisel.telcosec.net](https://tschisel.telcosec.net) |
| **Academy Learning Portal** | [app.telcosec.net](https://app.telcosec.net) |
| **Research & Advisory Blog** | [blog.telcosec.net](https://blog.telcosec.net) |
| **Community Discussion Forum** | [community.telcosec.net](https://community.telcosec.net) |
| **Official Discord Server** | [discord.gg/RykzXTQFXF](https://discord.gg/RykzXTQFXF) |

---

> [!CAUTION]
> **Legal Disclaimer:** TelcoChisel is designed solely for authorized security audits, academic research, and educational experimentation in controlled laboratories. Radio frequencies are heavily regulated. Users are strictly responsible for complying with local regulations, radio licensing requirements, and privacy laws. Intercepting or transmitting over public cellular channels without a license is illegal in most countries.
