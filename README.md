<div align="center">
  <br/>
  <a href="https://chisel.telcosec.net">
    <img src="assets/logo.png" alt="TelcoChisel Logo" width="140" height="140" style="border-radius: 20px; box-shadow: 0px 8px 30px rgba(232, 146, 30, 0.35);">
  </a>
  <br/><br/>

  # TelcoChisel: Advanced Telecom Security OS by TelcoSec

  **TelcoChisel is a specialized Live Linux distribution developed by TelcoSec for advanced Telecom Security, 4G/5G mobile network auditing, SDR transceiver engineering, and cellular baseband vulnerability research.**

  [![Build Status](https://github.com/TelcoSec-Tools/TelcoChiselOS/actions/workflows/release.yml/badge.svg)](https://github.com/TelcoSec-Tools/TelcoChiselOS/actions/workflows/release.yml)
  [![Docs](https://github.com/TelcoSec-Tools/TelcoChiselOS/actions/workflows/deploy-docs.yml/badge.svg)](https://chisel.telcosec.net)
  [![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)
  [![Kernel](https://img.shields.io/badge/Kernel-Low--Latency_Realtime-00ffd5?logo=linux&logoColor=black)](https://chisel.telcosec.net)
  [![License: Apache 2.0](https://img.shields.io/badge/License-Apache_2.0-00ffd5.svg)](LICENSE)
  [![Download](https://img.shields.io/sourceforge/dt/telcochisel?logo=sourceforge&label=Downloads)](https://sourceforge.net/projects/telcochisel/files/latest/download)

  [**Official Docs**](https://chisel.telcosec.net) • [**Download ISO**](https://sourceforge.net/projects/telcochisel/files/latest/download) • [**TelcoSec Academy**](https://app.telcosec.net) • [**Community Hub**](https://community.telcosec.net) • [**Discord Chat**](https://discord.gg/RykzXTQFXF)

  ---

  **Live Boot Credentials:** User: `telcosec` | Password: `telcosec`
</div>

---

## Overview

**TelcoChisel** is an operational live Linux environment configured for telecommunications security auditing, radio frequency analysis, and baseband research. 

Based on **Ubuntu 24.04 LTS (Noble Numbat)** with a dual-kernel architecture featuring the **low-latency real-time kernel** (`linux-image-lowlatency`) by default, an XFCE desktop environment, and an optional lightweight i3 tiling session, it ships with **78 pre-configured tools** for Software Defined Radio (SDR) operation, cellular RAN simulation (2G, 4G EPC & 5G SA), baseband firmware emulation, SIM/eSIM auditing, core signaling protocol analysis (SS7, Diameter, GTP, HTTP/2 SBI), wireline broadband exploitation, and VoIP telephony testing.

> [!NOTE]
> TelcoChisel boots directly from a USB flash drive or virtual machine, providing an isolated, pre-configured research testbed without modifying the host operating system. It includes support for **LUKS-encrypted persistence** (`casper-rw`), a **Toram mode** (copy-to-RAM for maximum I/O throughput), and can be permanently installed to disk via the bundled **Calamares GUI Installer**.

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
Or use tools like **Rufus** (DD mode) or **Ventoy** on Windows. For persistent live environments, use the built-in `telcosec-create-usb` wizard.

---

## Unified Operator CLI (`telcosec`)

TelcoChisel provides a centralized operator command-line interface, **`telcosec`** (symlinked to `telcochisel`), designed for rapid field diagnostics, hardware enumeration, cellular core management, and security scanning.

```bash
# Run the operator diagnostic overview
telcosec status

# Enumerate connected SDR hardware and SIM readers
telcosec hardware

# Launch or inspect 5G Standalone core & RAN simulation
telcosec 5g status
telcosec 5g start

# Launch guided cellular & signaling discovery scans
telcosec scan

# Interface with the modular metapackage manager
telcosec pkg list

# Access TelcoSec Academy interactive learning funnels
telcosec academy
```

### Command Summary

| Command | Subcommands | Purpose |
| :--- | :--- | :--- |
| `telcosec status` | — | System diagnostic report: kernel version, real-time priority (`SCHED_RR`), USB memory limits, SCTP status, cellular services, and smartcard reader daemons. |
| `telcosec hardware` | — | Automated detection of USRP, HackRF, BladeRF, LimeSDR, RTL-SDR, Airspy, PlutoSDR, and Osmocom SIMtrace / CCID readers. |
| `telcosec sdr` | `status`, `list`, `usb`, `10g`, `firmware` | Delegates to `telcosec-sdr` for comprehensive USB and 10Gbps transceiver management. |
| `telcosec 10g` | `status`, `tune`, `setup`, `probe` | Direct shortcut to optimize 10GbE network interfaces (MTU 9000, 4096 rings, 64MB buffers) and configure USRP X310/N310 IP links. |
| `telcosec 5g` | `status`, `start`, `stop`, `logs` | Orchestration for Open5GS 5G SA Core services and UERANSIM gNB/UE emulation with pre-configured PLMN `001/01`. |
| `telcosec scan` | `gsm`, `lte`, `sctp` | Guided cellular frequency survey and high-speed SCTP signaling endpoint discovery. |
| `telcosec pkg` | `list`, `install`, `remove`, `info`, `check`, `repo` | Delegates to `telcosec-pkg` for modular metapackage management. |
| `telcosec academy` | — | Opens direct terminal funnels and learning links to TelcoSec Academy hands-on browser labs (`app.telcosec.net`). |

---

## SDR Driver & Hardware Manager (`telcosec-sdr`)

TelcoChisel includes **`telcosec-sdr`** (symlinked to `telcochisel-sdr`), a dedicated management utility to inspect, tune, and maintain all installed SDR driver stacks across both **USB-connected transceivers** and **10Gbps high-throughput networked SDRs**.

```bash
# Comprehensive audit of all installed driver stacks (UHD, HackRF, BladeRF, LimeSuite, RTL-SDR, SoapySDR)
telcosec-sdr status

# Matrix of supported transceivers, bus types, and maximum sample rates
telcosec-sdr list

# USB diagnostics: check bus speeds, udev permissions, and power autosuspend
telcosec-sdr usb status

# Optimize USB buffer memory (usbfs_memory_mb=1000) and blacklist conflicting DVB-T drivers
sudo telcosec-sdr usb tune

# Power-cycle or reset an uninitialized/hung USB transceiver
sudo telcosec-sdr usb reset

# 10GbE Network diagnostics: check SFP+ link state, MTU, ring buffers, and socket limits
telcosec-sdr 10g status

# Optimize 10GbE interface for zero-drop streaming (MTU 9000, 4096 rings, 64MB socket buffers)
sudo telcosec-sdr 10g tune enp3s0f0

# One-step USRP network setup (presets: x310-0, x310-1, n310-0, n310-1)
sudo telcosec-sdr 10g setup enp3s0f0 x310-0

# Probe network for attached USRP devices via broadcast or specific IP
telcosec-sdr 10g probe 192.168.30.2

# Inspect local offline FPGA bitstream and firmware caches
telcosec-sdr firmware status
```

---

## Modular Metapackage Manager (`telcosec-pkg`)

TelcoChisel features a **10-tier modular metapackage architecture** hosted via Cloudflare Pages edge CDN (`meta.telcosec.net`). Operators can inspect, install, remove, and verify specialized tool suites on-demand using the dedicated **`telcosec-pkg`** utility.

```bash
# List all 10 official metapackages with installation status
telcosec-pkg list

# Install modular tool suites using intelligent aliases
sudo telcosec-pkg install 5g
sudo telcosec-pkg install sdr sim
sudo telcosec-pkg install wireline

# Inspect package dependencies and installed footprint
telcosec-pkg info 5g

# Audit system dependencies and library linkages
telcosec-pkg check

# Verify official repository connectivity and GPG keyring
telcosec-pkg repo status
```

### Official Metapackages Registry

| Metapackage | Aliases | Target Domain & Scope |
| :--- | :--- | :--- |
| **`telcochisel-base`** | `base` | Core system utilities, udev rules, real-time scheduling limits, and terminal tooling. |
| **`telcochisel-hardware-sdr`** | `sdr-hw`, `hardware` | Kernel drivers, FPGA bitstreams, and host libraries for USRP, HackRF, BladeRF, LimeSDR, RTL-SDR. |
| **`telcochisel-tools-sdr`** | `sdr`, `rf` | DSP frameworks and RF capture suites (GNU Radio 3.10, Gqrx, SoapySDR, Kalibrate). |
| **`telcochisel-tools-2g-3g`** | `2g`, `3g`, `gsm` | Legacy cellular stacks (OsmocomBB, OpenBTS, YateBTS, gr-gsm, OsmoGSM). |
| **`telcochisel-tools-4g`** | `4g`, `lte` | LTE RAN auditing, downlink sniffers, and software UE tools (srsRAN, srsUE, LTE-CellScanner, LTESniffer). |
| **`telcochisel-tools-5g`** | `5g`, `nr` | 5G Standalone core & RAN simulation (UERANSIM, Open5GS, GTP5G, OAI UE, my5G-RANTester, 5Ghoul). |
| **`telcochisel-tools-sim`** | `sim`, `esim` | Smartcard auditing, APDU sniffing, and eSIM LPA profiles (SIMtrace 2, pySim-shell, lpac, SIMurai, SIMtester). |
| **`telcochisel-tools-pstn-adsl`** | `pstn`, `adsl`, `wireline`, `voip` | Wireline broadband, PPPoE, DOCSIS, VLAN, SNMP, and VoIP/SIP assessment suites. |
| **`telcochisel-tools-ue`** | `ue`, `mobile` | Baseband firmware analysis, Qualcomm DIAG, Samsung Shannon, and MediaTek BROM tools. |
| **`telcochisel-meta-full`** | `full`, `all` | Umbrella metapackage installing the entire 78-tool telecommunications security suite. |

---

## Pre-loaded Toolsets (78 Tools)

Tools are organized by functional domain. The status indicates whether a tool is **Ready** (installed and executable immediately) or requires a **Setup** command (runs a setup script on demand to optimize system footprint).

### 1. Software Defined Radio (SDR)
Radio drivers are isolated in a dedicated Conda environment (`telcosec-sdr`) to prevent Python ABI conflicts.
* **Supported Radios:** USRP B200/B210/X310/N210, HackRF One, BladeRF 2.0 micro xA4, LimeSDR, RTL-SDR, Airspy, PlutoSDR.

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
| **Open5GS** | `Setup` | `sudo open5gs-install` | 4G EPC and 5G Standalone (SA) core network containerized suite |
| **srsRAN** | `Setup` | `sudo srsran-install` | 4G/5G software radio access network (RAN) and gNodeB simulator |
| **UERANSIM** | `Ready` | `nr-gnb -c /etc/telcosec/ueransim/gnb.yaml` | 5G SA UE and gNodeB simulator preconfigured for test PLMN (001/01) |
| **my5G-RANTester** | `Ready` | `my5g-rantester --help` | High-concurrency 5G NR RAN stress testing and multi-UE simulation |
| **OAI UE** | `Setup` | `sudo oai-install [--radio BLADERF\|USRP]` | OpenAirInterface 5G NR User Equipment simulation stack |
| **srsUE** | `Setup` | `srsue /etc/srsran/ue.conf` | Software UE for LTE attach procedures and downlink capture |
| **5Ghoul Fuzzer** | `Setup` | `sudo 5ghoul-install` | 5G NR baseband fuzzer utilizing rogue gNB attack vectors |
| **GTP5G Kernel Module** | `Setup` | `sudo gtp5g-load` | 5G user plane acceleration kernel module (free5GC UPF) |
| **LTE-CellScanner** | `Ready` | `CellSearch --help` | OpenCL-accelerated LTE cell identification and synchronization |
| **LTESniffer** | `Ready` | `ltesniffer --help` | Real-time passive LTE downlink sniffer and RRC packet dissector |

---

### 3. 2G / 3G Legacy Cellular & Air Interface

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **OsmocomBB** | `Ready` | `osmocon --help` | Open-source GSM baseband firmware stack for Calypso-based hardware |
| **OpenBTS** | `Setup` | `sudo openbts-install` | GSM base transceiver station software presenting a SIP endpoint |
| **YateBTS** | `Setup` | `sudo yatebts-install` | 2G/GSM software radio access network for BladeRF and HackRF |
| **Osmocom GSM Stack** | `Ready` | `osmo-nitb --help` | Complete GSM Network-in-the-Box and signaling core suite |
| **Kalibrate GSM** | `Ready` | `kal -s GSM900` | Universal GSM beacon scanner for receiver clock drift measurement |

---

### 4. Baseband & Mobile Firmware Analysis

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **FirmWire** | `Ready` | `firmwire --help` | Samsung Shannon and MediaTek baseband firmware emulation and fuzzing |
| **QCSuper** | `Ready` | `qcsuper --help` | Qualcomm DIAG protocol analyzer and PCAP generator |
| **SCAT** | `Ready` | `scat -t qc -d /dev/ttyUSB0` | Samsung and Qualcomm diagnostic parser with NAS/RRC decoding to PCAP |
| **MTKClient** | `Ready` | `mtk --help` | BROM exploit tool, flasher, and partition editor for MediaTek devices |
| **Balong-Flash & Balongtool** | `Ready` | `balong-flash --help` | Firmware flasher and NVRAM tool for Huawei Balong modems |
| **EDL (Qualcomm)** | `Ready` | `edl --help` | Qualcomm Emergency Download (EDL) mode programmer and memory dumper |
| **Heimdall** | `Ready` | `heimdall version` | Cross-platform flasher for Samsung Galaxy boot and modem partitions |
| **AT Command Console** | `Ready` | `at-console` | Interactive Hayes AT command console with preloaded GSM/UMTS/LTE commands |
| **atinout** | `Ready` | `atinout input.at /dev/ttyUSB0 output.txt` | Batch command executor for cellular diagnostic and AT serial ports |
| **Gammu & gammu-at** | `Ready` | `gammu identify` | Cellular modem information extraction and SMS/PDU engine |
| **ModemManager GUI** | `Ready` | `modem-manager-gui` | Graphical interface for monitoring signal quality, bands, and SMS |
| **SP Flash Tool Helper** | `Ready` | `spflashtool-install` | Scatter-based partition flashing helper for MediaTek devices |
| **ADB & Fastboot** | `Ready` | `adb devices` | Android Debug Bridge and bootloader flashing interfaces |

---

### 5. SIM & eSIM Smartcard Auditing

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **Osmocom SIMtrace 2** | `Ready` | `simtrace2-list` | Hardware sniffer and emulator for the ISO 7816 SIM card interface |
| **pySim-shell** | `Ready` | `pySim-shell --help` | Interactive SIM/USIM/ISIM management, file system traversal, and programming |
| **lpac** | `Ready` | `lpac profile list` | Command-line Local Profile Assistant (LPA) for eSIM (SGP.22) profiles |
| **SIMurai** | `Ready` | `simurai --help` | Software SIM and ICC-PCSC virtual smartcard simulator daemon |
| **SIMtester** | `Ready` | `simtester` | Utility to assess SIM card security configurations, keys, and crypto limits |
| **pcscd** | `Ready` | `systemctl status pcscd` | PC/SC smartcard reader subsystem daemon with CCID arbitration |

---

### 6. Core Signaling, Protocol Scanners & VoIP

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **Wireshark / TShark** | `Ready` | `wireshark` | Configured with custom profiles and color filters for GSMTAP, GTP, and 5G NAS |
| **SigPloit** | `Ready` | `sudo sigploit` | Exploitation framework for SS7, Diameter, and GTP signalling protocols |
| **Diafuzzer** | `Ready` | `diafuzzer --help` | Diameter protocol fuzzer for S6a, Gx, and Gy core interfaces |
| **sctpscan** | `Ready` | `sctpscan --help` | High-speed SCTP port scanner for SIGTRAN and Diameter interface endpoints |
| **SIPVicious** | `Ready` | `svmap --help` | Security testing toolkit for SIP and VoIP PBX endpoints |
| **Scapy (Telecom Modules)** | `Ready` | `scapy` | Packet crafting utility with MAP, TCAP, Diameter, and GTP protocol support |
| **SIPp** | `Ready` | `sipp -h` | SIP traffic generator and performance testing tool |
| **Twinkle & Linphone** | `Ready` | `twinkle` / `linphone` | SIP softphone clients for VoIP protocol security assessment |
| **Baresip** | `Ready` | `baresip` | Modular command-line VoIP terminal client |
| **Zoiper5** | `Ready` | `zoiper5` | Professional VoIP/SIP softphone client |
| **TelcoSec Profile Switcher** | `Ready` | `telcosec-profile` | Automated Wireshark dissector profile and colorfilter switcher |
| **Kismet & tcpdump** | `Ready` | `kismet` / `tcpdump` | Wireless sniffer and core packet capture utilities |

---

### 7. Broadband, ADSL, DOCSIS & Wireline Security

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **RouterSploit** | `Ready` | `routersploit` | Exploitation framework for embedded devices (CPE routers/modems) |
| **RDNSx** | `Ready` | `rdnsx` | Rapid DNS Reverse Resolver for fast telecommunications network enumeration |
| **asleap** | `Ready` | `asleap -h` | PPPoE MS-CHAPv2 dictionary attack and offline cracking tool |
| **snmp-check** | `Ready` | `snmp-check -h` | SNMP enumerator for mapping routing tables via weak community strings |
| **docsis** | `Ready` | `docsis` | Compile and decompile DOCSIS binary configuration files |
| **tftpd-hpa / isc-dhcp-server** | `Ready` | `systemctl status tftpd-hpa` | Rogue DHCP and TFTP servers for provisioning attacks |
| **yersinia / ettercap** | `Ready` | `yersinia` / `ettercap` | Layer 2 shared medium attacks (DHCP, STP, ARP spoofing) |
| **PPPoE Tools** | `Ready` | `pppoe-discovery` | PPPoE session discovery and broadband concentration testing |
| **VLAN & Macchanger** | `Ready` | `vconfig` / `macchanger` | 802.1Q tagged VLAN injection and MAC address spoofing |
| **FreeRADIUS Utils** | `Ready` | `radclient -h` | RADIUS authentication and accounting testing utility |
| **Hashcat & John** | `Ready` | `hashcat` / `john` | High-performance password and handshake recovery tools |
| **Nikto & Gobuster** | `Ready` | `nikto` / `gobuster` | Web management interface scanners for telecom equipment |

---

### 8. Microwave, OSS & Platform Utilities

| Tool | Status | Command / Usage | Purpose |
| :--- | :---: | :--- | :--- |
| **Nokia NetAct CLI** | `Ready` | `nokia-netact-cli <host>` | Nokia NetAct OSS CLI connector wrapper |
| **Ericsson ENM CLI** | `Ready` | `ericsson-enm-cli <host>` | Ericsson ENM CLI management connector wrapper |
| **Huawei U2000 CLI** | `Ready` | `huawei-u2000-cli <host>` | Huawei iMaster U2000 NMS CLI connector wrapper |
| **GPU Info & OpenCL** | `Ready` | `gpu-info` | GPU hardware detection, OpenCL, Vulkan, and driver diagnostics |
| **Docker & Docker Compose** | `Ready` | `docker --version` | Container runtime engine for isolated core network testbeds |
| **Telecom Wordlists** | `Ready` | `/usr/share/wordlists/telecom` | Curated wordlists for APNs, IMSIs, GTP TEIDs, SIP extensions, and SS7 point codes |

---

## Kernel, Live Boot Architecture & Air-Gapped Operations

To ensure stable, high-throughput SDR operations and prevent RF sample drops, the OS is pre-configured with:

* **Dual-Kernel Architecture:** Boots by default into the **Ubuntu low-latency kernel** (`linux-image-lowlatency`), tuned for deterministic process wakeups and sub-millisecond timer resolution.
* **Real-time Scheduling:** Configured PAM limits and the `realtime` group enable SDR applications (such as GNU Radio and srsRAN) to run threads at `SCHED_RR` priority 99 with memory-locking (`RLIMIT_MEMLOCK=unlimited`) capabilities.
* **Low-Latency USB:** Customized `udev` rules (`50-telcosec-hw.rules`) disable USB autosuspend for USRP, BladeRF, HackRF, and RTL-SDR devices, with `usbcore.usbfs_memory_mb=1000` set on kernel cmdline.
* **Non-Root Hardware Access:** `udev` rules map USB interfaces for cellular transceivers and hardware programmers to the `plugdev` group.
* **SCTP Optimization:** Preloaded `sctp` kernel module with adjusted socket buffers (64 MB max) and retransmission timeout (RTO) values suited for SIGTRAN and Diameter scanning.
* **Four GRUB Boot Profiles:**
  1. **Standard Live Mode:** Full XFCE desktop environment with real-time audio and RF streaming.
  2. **Encrypted Persistent Live Mode:** Mounts an encrypted LUKS partition (`casper-rw`) for secure, persistent evidence and tool storage.
  3. **Lightweight i3 Tiling Mode:** High-performance, keyboard-driven i3 window manager session minimizing RAM footprint on low-spec field laptops.
  4. **Toram Mode:** Copies the squashfs filesystem entirely into RAM, unlocking maximum read/write speeds and allowing the boot USB to be removed.

### Air-Gapped & Field Operations Utilities

* **`telcosec-create-usb`**: Guided command-line utility to format any attached USB drive with dual partitions: a FAT32 EFI boot partition and an optional LUKS-encrypted `casper-rw` persistence partition.
* **`telcosec-download-openapi`**: Offline synchronizer that pulls official 3GPP Service Based Architecture (SBA) OpenAPI specifications (Rel-15 through Rel-18) for offline 5G Core API fuzzing and schema validation.
* **Wireshark Telecom Colorfilters**: Production color profiles pre-configured for 5G NAS, NGAP, S1AP, PFCP, GTPv1/v2-U, Diameter, and SS7/SIGTRAN. Switch profiles instantly using `telcosec-profile`.

---

## Telecom Red Team Attack Scenarios

TelcoChisel serves as the standardized operating environment for real-world telecommunications penetration testing workflows:

### Scenario 1: 5G Standalone (SA) Rogue gNB & Downgrade Attacks
* **Objective:** Emulate a rogue 5G gNodeB to test User Equipment (UE) handling of unauthenticated `Registration Reject` cause codes (#11, #12) and force fallback to legacy 2G/4G tracking.
* **Tools:** UERANSIM, srsRAN, 5Ghoul, Wireshark (NGAP/NAS-5GS profile).
* **Academy Lab:** [5G Standalone Security & Rogue Base Station Lab →](https://app.telcosec.net/?utm_source=telcochisel_readme&utm_campaign=scenario_5g)

### Scenario 2: Core Signaling Interconnect Infiltration (SS7 / Diameter)
* **Objective:** Assess international roaming STP and DRA edge proxies against location tracking (`SendRoutingInfoForSM`), subscriber eavesdropping (`ProvideSubscriberInfo`), and fraud attacks.
* **Tools:** SigPloit, Diafuzzer, sctpscan, Scapy MAP/TCAP modules.
* **Academy Lab:** [SS7/Diameter Interconnect Security Lab →](https://app.telcosec.net/?utm_source=telcochisel_readme&utm_campaign=scenario_sigtran)

### Scenario 3: Baseband Reverse Engineering & Shannon/MediaTek Fuzzing
* **Objective:** Extract, emulate, and fuzz cellular modem firmware in virtualized environments without bricking physical handsets.
* **Tools:** FirmWire, QCSuper, SCAT, MTKClient, Balong-Flash, EDL.
* **Academy Lab:** [Cellular Baseband Reverse Engineering Lab →](https://app.telcosec.net/?utm_source=telcochisel_readme&utm_campaign=scenario_baseband)

### Scenario 4: SIM / eSIM Smartcard & OTA Toolkit Auditing
* **Objective:** Intercept ISO 7816 APDUs during network attach, audit SIM card cryptographic parameters (COMP128/Milenage), and analyze eSIM SGP.22 remote provisioning protocols.
* **Tools:** Osmocom SIMtrace 2, pySim-shell, lpac, SIMurai, SIMtester.
* **Academy Lab:** [SIM/eSIM Smartcard Security Lab →](https://app.telcosec.net/?utm_source=telcochisel_readme&utm_campaign=scenario_sim)

### Scenario 5: VoIP Telephony & SIP PBX Penetration Testing
* **Objective:** Map VoIP PBX extensions, perform SIP Digest authentication cracking, and test IP-PBX systems against RTP session hijacking.
* **Tools:** SIPVicious, SIPp, Twinkle, Baresip, Linphone, Scapy.
* **Academy Lab:** [Telecom VoIP & SIP Protocol Lab →](https://app.telcosec.net/?utm_source=telcochisel_readme&utm_campaign=scenario_voip)

### Scenario 6: Wireline Broadband & DOCSIS Provisioning Auditing
* **Objective:** Audit broadband access concentrators, extract PPPoE credentials, analyze DOCSIS configuration files, and exploit weak SNMP management interfaces on CPE modems.
* **Tools:** RouterSploit, docsis, asleap, snmp-check, pppoe-discovery, yersinia.
* **Academy Lab:** [Wireline Broadband & CPE Exploitation Lab →](https://app.telcosec.net/?utm_source=telcochisel_readme&utm_campaign=scenario_adsl)

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
# Verify bash syntax across all 33 provisioning and helper scripts
wsl bash scripts/test_syntax.sh

# Normalize line endings to Unix LF
python scripts/fix_crlf.py
```

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
TelcoChisel is an advanced Live Linux OS tailored specifically for Telecom Security. It comes pre-loaded with 78 tools for SDR engineering, cellular network auditing, baseband research, and core network simulation.

**Who created TelcoChisel?**  
TelcoChisel was developed by TelcoSec, a leading consulting and training firm specializing in Telecom Security.

**Why is Telecom Security important?**  
Telecom Security is critical to protecting mobile network infrastructures (like 4G, 5G, and beyond) against signaling attacks, rogue base stations, and baseband vulnerabilities. Tools like TelcoChisel help researchers and engineers identify and mitigate these risks.

**How does TelcoChisel handle SDR latency and sample drops?**  
TelcoChisel defaults to the Linux low-latency kernel, grants unconstrained memory locking (`RLIMIT_MEMLOCK=unlimited`), enables `SCHED_RR` priority 99 to the `realtime` group, allocates 1000MB of USB buffer memory, and disables USB autosuspend across all supported SDR transceivers.

---

## Community & Support

| Resource | Link |
| :--- | :--- |
| **Documentation Portal** | [chisel.telcosec.net](https://chisel.telcosec.net) |
| **Academy Learning Portal** | [app.telcosec.net](https://app.telcosec.net) |
| **Research & Advisory Blog** | [blog.telcosec.net](https://blog.telcosec.net) |
| **Community Discussion Forum** | [community.telcosec.net](https://community.telcosec.net) |
| **Official Discord Server** | [discord.gg/RykzXTQFXF](https://discord.gg/RykzXTQFXF) |

---

> [!CAUTION]
> **Legal Disclaimer:** TelcoChisel is designed solely for authorized security audits, academic research, and educational experimentation in controlled laboratories. Radio frequencies are heavily regulated. Users are strictly responsible for complying with local regulations, radio licensing requirements, and privacy laws. Intercepting or transmitting over public cellular channels without a license is illegal in most countries.
