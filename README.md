![TelcoChisel OS Cover Banner](assets/repo_cover.png)

<div align="center">
  <br/>
  <a href="https://tschisel.telcosec.net">
    <img src="assets/logo.png" alt="TelcoChisel Logo" width="140" height="140" style="border-radius: 20px; box-shadow: 0px 8px 30px rgba(0, 212, 230, 0.35);">
  </a>
  <br/><br/>

  # TelcoChisel OS

  **Advanced Live Linux Distribution & Build Engine for 4G/5G mobile auditing, SDR transceiver engineering, and cellular baseband research.**

  [![Build ISO](https://github.com/TelcoSec/TelcoChisel/actions/workflows/release.yml/badge.svg)](https://github.com/TelcoSec/TelcoChisel/actions/workflows/release.yml)
  [![Docs](https://github.com/TelcoSec/TelcoChisel/actions/workflows/deploy-docs.yml/badge.svg)](https://tschisel.telcosec.net)
  [![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?logo=ubuntu&logoColor=white)](https://ubuntu.com)
  [![License: MIT](https://img.shields.io/badge/License-MIT-00ffd5.svg)](LICENSE)
  [![Download](https://img.shields.io/sourceforge/dt/telcochisel?logo=sourceforge&label=Downloads)](https://sourceforge.net/projects/telcochisel/)

  [**Official Docs**](https://tschisel.telcosec.net) • [**Download ISO**](https://sourceforge.net/projects/telcochisel/) • [**TelcoSec Academy**](https://app.telcosec.cloud) • [**Community Hub**](https://community.telcosec.cloud) • [**Discord Chat**](https://discord.gg/RykzXTQFXF)

  ---

  🔑 **Live Boot Credentials:** User: `telcosec` | Password: `telcosec`
</div>

---

## ⚡ Overview

**TelcoChisel** is a free, bootable live Linux OS and build engine purpose-built for telecom penetration testers, security researchers, cellular network operators, and baseband engineers. 

Based on **Ubuntu 24.04 LTS (Noble Numbat)** with a hardware-tuned GNOME Shell desktop, TelcoChisel ships with **50+ pre-integrated utility suites** for Software Defined Radio (SDR) transceivers, cellular RAN simulation (4G EPC / 5G SA), baseband firmware fuzzing, SIM/eSIM auditing, signaling network analysis (SS7/Diameter/GTP), and VoIP hacking.

> [!NOTE]
> **No Installation Required:** TelcoChisel is optimized to boot directly from a USB flash drive or virtual machine, allowing immediate lab setup and testing without messing up your host operating system.

---

## 🎓 Elevate Your Career at TelcoSec Academy

TelcoChisel is proudly maintained by **[TelcoSec](https://telco-sec.com)**, a leading force in telecom cybersecurity auditing, research, and training. 

For engineers who want to go beyond the tool commands and deeply understand protocol design, RAN structures, and practical exploitation vectors, we offer professional courses on the **[TelcoSec Academy Portal](https://app.telcosec.cloud)**.

* **Frictionless Lab Environment:** TelcoChisel is the official, pre-configured sandbox used throughout the Academy courses. Start practicing immediately without spending days setting up libraries, compiling software cores, or troubleshooting driver conflicts.
* **Specialized Curriculum:** Get trained in 4G/5G Penetration Testing, SDR Signal Analysis, Baseband Vulnerability Research, SIM/eSIM Exploitation, and SS7/Diameter Core Auditing.
* **Hands-on Labs:** Gain access to real physical SDR hardware labs and private core networks.
* **Professional Certification:** Validate your advanced skillset with industry-recognized telecom security certifications.

💡 **Ready to dive in?** [Create your free Academy account and browse our course catalog today!](https://app.telcosec.cloud)

---

## 🛠️ What's Included (Pre-loaded Toolsets)

Tools are organized by functional domain. The status indicates whether a tool is **Ready** (installed and executable immediately) or requires a **Setup** command (runs a build/installer script on demand to optimize ISO size).

### 📻 Software Defined Radio (SDR)
Radio drivers are isolated in a dedicated Conda environment (`telcosec-sdr`) to prevent Python ABI conflicts.
* **Supported Radios:** USRP B210/X310/N210, HackRF One, BladeRF 2.0 xA4, LimeSDR, RTL-SDR.

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **GNU Radio 3.10** | `Ready` | Graphical DSP signal flow development environment |
| **SoapySDR** | `Ready` | Vendor-neutral SDR hardware abstraction layer |
| **UHD** | `Ready` | Ettus USRP Hardware Driver (compiled from source) |
| **HackRF Host Tools** | `Ready` | HackRF One firmware & command-line transceiver utils |
| **gr-gsm** | `Ready` | GNU Radio blocks to receive and decode GSM/2G air interfaces |
| **Kalibrate-RTL** | `Ready` | Calibrates RTL-SDR local oscillator against live cellular towers |
| **GQRX** | `Ready` | GUI SDR receiver and real-time spectrum visualizer |

---

### 📶 4G/5G RAN & Core Network Simulation

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **srsRAN** | `Setup` (`sudo srsran-install`) | Advanced 4G/5G RAN and UE simulator |
| **Open5GS** | `Setup` (`sudo open5gs-install`) | Complete 4G EPC and 5G Standalone (SA) core network suite |
| **UERANSIM** | `Ready` | 5G SA UE and gNodeB simulator preconfigured for PLMN 001/01 |
| **OAI UE** | `Setup` (`sudo oai-install`) | OpenAirInterface 5G NR User Equipment simulator stack |
| **srsUE** | `Setup` | Software UE for LTE attach and downlink PCAP testing |
| **5Ghoul Fuzzer** | `Setup` (`sudo 5ghoul-install`) | 5G NR baseband fuzzer over OAI rogue base stations |

---

### 🧠 Baseband & UE Firmware Analysis

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **FirmWire** | `Ready` | Samsung Shannon and MediaTek baseband emulator and fuzzing |
| **QCSuper** | `Ready` | Qualcomm DIAG interface packet logger -> PCAP decoder |
| **SCAT** | `Ready` | Diagnostic parser for Samsung/Qualcomm modems (RRC/NAS decoding) |
| **MTKClient** | `Ready` | MediaTek BROM bypass, flasher, and partition manager |
| **Balong-Flash** | `Ready` | Huawei Balong-based LTE modem firmware utility |
| **MobileInsight** | `Ready` | Real-time cellular network protocol trace analyzer |

---

### 💳 SIM & eSIM Smartcard Auditing

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **Osmocom SIMtrace 2** | `Ready` | Passive hardware sniffer between SIM card and phone modem |
| **pySim-shell** | `Ready` | Shell interface for writing, reading, and auditing SIM cards |
| **lpac** | `Ready` | Local Profile Assistant for eSIM download and management |
| **SIMurai** | `Ready` | Software SIM card simulator with virtual PC/SC reader |
| **SIMtester** | `Ready` | Audits SIM cards for weak crypto and hidden features |
| **pcscd** | `Ready` | Smartcard reader interface daemon |

---

### 🛡️ Core Signaling & Protocol Scanners

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **Wireshark / TShark** | `Ready` | Bundled with custom profiles for GSMTAP, GTP, and 5G NAS |
| **SigPloit** | `Ready` | SS7, Diameter, and GTP vulnerability exploitation framework |
| **Diafuzzer** | `Ready` | Orange Security Diameter fuzzer for S6a, Gx, and Gy interfaces |
| **sctpscan** | `Ready` | SCTP port scanner for core network nodes (SIGTRAN/Diameter) |
| **SIPVicious** | `Ready` | VoIP/SIP auditing suite for cracking, scanning, and war-dialing |
| **Scapy** | `Ready` | Custom packet manipulation featuring telecommunication headers |
| **SIPp** | `Ready` | High-load SIP traffic generator and performance tester |

---

### 🔌 Device Flashing & AT Command Suites

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **ADB & Fastboot** | `Ready` | Android debugging bridge and bootloader flashing tools |
| **Heimdall** | `Ready` | Custom ROM flasher for Samsung Galaxy devices |
| **EDL** | `Ready` | Qualcomm Emergency Download mode partition controller |
| **SP Flash Tool** | `Setup` (`sudo spflashtool-install`) | MTK smartphone flashing utility |
| **Gammu / Minicom** | `Ready` | AT command terminal and SMS modem manager |
| **ModMobMap** | `Ready` | Map cellular network infrastructure during war-driving |
| **LTESniffer** | `Ready` | Passive LTE downlink sniffer and message decoder |
| **LTE-Cell-Scanner** | `Ready` | Cell searcher and RTL-SDR frequency offset calibrator |

---

### 📞 Legacy GSM/2G & VoIP Security

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **YateBTS** | `Setup` (`sudo yatebts-install`) | Software-defined GSM base station emulator |
| **OpenBTS** | `Setup` (`sudo openbts-install`) | Original GSM base station stack using SDRs |
| **kalibrate-gsm** | `Ready` | GSM band scanner and local clock calibrator |
| **Twinkle & Linphone** | `Ready` | Graphical SIP softphones for endpoint fuzzing |
| **Baresip** | `Ready` | Modular console-based VoIP terminal |

---

## ⚙️ Kernel & OS Tuning

To prevent frame dropouts, buffer overruns, and RF packet loss during high-speed SDR operations, TelcoChisel applies kernel-level configurations:

* **Real-time Priority Access:** Configured PAM user limits and the `realtime` group, allowing GNU Radio and srsRAN threads to lock memory and run under real-time scheduling policies (`SCHED_RR` priority 99).
* **Low-Latency USB Config:** Customized `udev` rules disable power autosuspend on USRP, BladeRF, HackRF, and RTL-SDR transceivers.
* **Non-Root Hardware Permissions:** USB interfaces for cellular analysis equipment are automatically mapped to the `plugdev` group.
* **Core SCTP Tuning:** Preloaded `sctp` kernel module with fine-tuned socket buffers and retransmission timeouts (RTO) for optimized SIGTRAN scan speeds.
* **Kernel Hardening:** Active Address Space Layout Randomization (ASLR), symlink/hardlink protections, restricted `dmesg` access, and disabled ICMP redirects.
* **Default Security Profile:** Preconfigured UFW firewall blocking all incoming ports by default.

---

## 🔨 Building the Live ISO

The live ISO is built using a modular chroot build system. You can compile the ISO yourself on any Ubuntu/Debian host machine (or Windows WSL2).

### Prerequisites
Make sure you have ~20 GB of free space. A full compilation takes between **30 to 60 minutes**.

```bash
sudo apt-get install -y debootstrap squashfs-tools grub-pc-bin grub-efi-amd64-bin xorriso mtools
```

### Build on Linux
Clone the repository and run the build script as root:
```bash
sudo ./build-iso.sh
```

### Build on Windows (WSL2)
We provide a helper script for WSL2 environments (e.g. Kali Linux or Ubuntu WSL distros):
```bash
# Performs the build inside WSL, outputting the ISO directly to your workspace root
bash build-wsl.sh
```

> [!TIP]
> **Advanced Build Options:**
> * To speed up compression during development (creates a larger ISO size), run:
>   `SQUASHFS_LEVEL=3 bash build-wsl.sh`
> * To resume building from a specific setup script (e.g. script 05 onwards):
>   `bash build-wsl.sh --resume-from=05`

---

## 🔬 5Ghoul — 5G NR Baseband Fuzzer

Due to the length of compilation, **5Ghoul** and its custom rogue gNodeB components are not precompiled inside the ISO image to save space. However, all build dependencies and helper scripts are pre-packaged.

To compile 5Ghoul on first boot:
```bash
# For USRP B210:
sudo 5ghoul-install

# For BladeRF 2.0 xA4:
sudo 5ghoul-install --radio BLADERF
```

Once installed, run fuzzing campaigns:
```bash
sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz
```
For advanced configurations, check the [Online 5Ghoul Guide](https://tschisel.telcosec.net/#fuzzer).

---

## 📂 Repository Architecture

```
build-iso.sh                  # Core build orchestration script
build-wsl.sh                  # Windows WSL2 helper script
builder/
  scripts/
    00-install-all-packages.sh  # Single unified APT transaction
    01-install-base.sh          # GNOME Shell desktop, user config, base shell
    02-install-sdr.sh           # Conda sandbox environment & source SDR drivers
    03-install-core-network.sh  # RAN helper build configurations
    04-install-tools.sh         # Scanners, Wireshark, protocol engines
    05-desktop-customization.sh # GNOME wallpaper, Firefox policies, MOTD
    06-install-ue-analysis.sh   # Baseband emulation, SIM, & flashing tools
    07-install-installer.sh     # Calamares graphical OS installer configuration
    08-system-optimization.sh   # SCTP tuning, udev limits, RT PAM priority
    09-install-5ghoul.sh        # Fuzzing orchestration scripts & wrappers
    10-install-telecom-advanced.sh # Advanced network layers (UERANSIM, YateBTS)
    11-install-device-tools.sh  # Custom hardware wrappers & ADB bridges
  calamares/                    # Installer configuration and custom slide decks
  docs/                         # Offline documentation bundled with the ISO
  menu/                         # Custom desktop application categories
  udev/                         # Hotplug USB permission rules
docs/                           # Online documentation source (Nuxt 3 website)
assets/                         # Branding images, logo, and cover designs
```

---

## 🤝 Community & Support

Get help, discuss vulnerabilities, and share cellular capture files:

| Resource | Link |
| :--- | :--- |
| **Documentation Portal** | [tschisel.telcosec.net](https://tschisel.telcosec.net) |
| **Academy Learning Portal** | [app.telcosec.cloud](https://app.telcosec.cloud) |
| **Research & Advisory Blog** | [blog.telcosec.cloud](https://blog.telcosec.cloud) |
| **Community Discussion Forum** | [community.telcosec.cloud](https://community.telcosec.cloud) |
| **Official Discord Server** | [discord.gg/RykzXTQFXF](https://discord.gg/RykzXTQFXF) |

---

> [!CAUTION]
> **Legal Disclaimer:** TelcoChisel is designed solely for authorized security audits, academic research, and educational experimentation in controlled laboratories. Radio frequencies are heavily regulated. Users are strictly responsible for complying with local regulations, radio licensing requirements, and privacy laws. Intercepting or transmitting over public cellular channels without a license is illegal in most countries.
