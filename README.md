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

Based on **Ubuntu 24.04 LTS (Noble Numbat)** with an XFCE desktop environment, it includes over **76 pre-configured tools** for Software Defined Radio (SDR) operation, cellular RAN simulation (4G EPC & 5G SA), baseband firmware analysis, SIM/eSIM auditing, signaling protocol analysis, and VoIP security testing.

> [!NOTE]
> TelcoChisel boots directly from a USB flash drive or virtual machine, providing a pre-configured workspace without modifying the host operating system.

---

## TelcoSec Academy

TelcoChisel is maintained by **[TelcoSec](https://telco-sec.com)**, a security consulting and training firm specializing in telecommunications security. 

For structured training on cellular security, protocol analysis, and vulnerability research, visit the **[TelcoSec Academy Portal](https://app.telcosec.net)**.

* **Standardized Lab Environment:** TelcoChisel serves as the standardized operating environment for TelcoSec training courses, ensuring consistent tool configurations and library dependencies.
* **Cellular Security Courses:** Practical training modules covering 4G/5G radio access network (RAN) auditing, core signaling security (SS7/Diameter/GTP), baseband reverse engineering, and SIM/eSIM security verification.
* **Professional Certifications:** Validated security credentials in telecommunications penetration testing and security analysis.

**[Course Catalog & Registration →](https://app.telcosec.net)**

---

## Pre-loaded Toolsets

Tools are organized by functional domain. The status indicates whether a tool is **Ready** (installed and executable immediately) or requires a **Setup** command (runs a setup script on demand to optimize system size).

### Software Defined Radio (SDR)
Radio drivers are isolated in a dedicated Conda environment (`telcosec-sdr`) to prevent Python ABI conflicts.
* **Supported Radios:** USRP B210/X310/N210, HackRF One, BladeRF 2.0 xA4, LimeSDR, RTL-SDR.

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **GNU Radio 3.10** | `Ready` | DSP framework and signal flow graph development environment |
| **SoapySDR** | `Ready` | SDR hardware abstraction library |
| **UHD** | `Ready` | USRP Hardware Driver (UHD), compiled from source |
| **HackRF Host Tools** | `Ready` | Command-line utilities for the HackRF One transceiver |
| **gr-gsm** | `Ready` | GNU Radio blocks for decoding GSM air interfaces |
| **Kalibrate-RTL** | `Ready` | RTL-SDR frequency offset calibration utility |
| **GQRX** | `Ready` | SDR receiver GUI and spectrum analyzer |

---

### 4G/5G RAN & Core Network Simulation

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **srsRAN** | `Setup` (`sudo srsran-install`) | 4G/5G software radio access network (RAN) and UE simulator |
| **Open5GS** | `Setup` (`sudo open5gs-install`) | 4G EPC and 5G Standalone (SA) core network simulation suite |
| **UERANSIM** | `Ready` | 5G SA UE and gNodeB simulator preconfigured for test PLMN (001/01) |
| **OAI UE** | `Setup` (`sudo oai-install`) | OpenAirInterface 5G NR User Equipment simulation stack |
| **srsUE** | `Setup` | Software UE for LTE attach procedures and downlink capture testing |
| **5Ghoul Fuzzer** | `Setup` (`sudo 5ghoul-install`) | 5G NR baseband fuzzer utilizing modified OpenAirInterface base stations |

---

### Baseband & UE Firmware Analysis

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **FirmWire** | `Ready` | Samsung Shannon and MediaTek baseband firmware emulation and fuzzing framework |
| **QCSuper** | `Ready` | Qualcomm DIAG protocol analyzer and PCAP generator |
| **SCAT** | `Ready` | Samsung and Qualcomm diagnostic parser with NAS/RRC decoding to PCAP |
| **MTKClient** | `Ready` | BROM exploit tool, flasher, and partition editor for MediaTek devices |
| **Balong-Flash** | `Ready` | Firmware writing and flashing utility for Huawei Balong modems |

---

### SIM & eSIM Smartcard Auditing

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **Osmocom SIMtrace 2** | `Ready` | Hardware sniffer for the ISO 7816 smart card interface |
| **pySim-shell** | `Ready` | Interactive SIM/USIM/ISIM management and programming shell |
| **lpac** | `Ready` | Command-line Local Profile Assistant (LPA) for eSIM (SGP.22) profile management |
| **SIMurai** | `Ready` | Software SIM and ICC-PCSC virtual smartcard simulator |
| **SIMtester** | `Ready` | Utility to assess SIM card security configurations and cryptographic limits |
| **pcscd** | `Ready` | PC/SC smartcard reader daemon |

---

### Core Signaling & Protocol Scanners

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **Wireshark / TShark** | `Ready` | Configured with custom profiles for GSMTAP, GTP, and 5G NAS protocol columns |
| **SigPloit** | `Ready` | Exploitation framework for SS7, Diameter, and GTP signalling protocols |
| **Diafuzzer** | `Ready` | Diameter protocol fuzzer for S6a, Gx, and Gy interfaces |
| **sctpscan** | `Ready` | SCTP port scanner for SIGTRAN and Diameter interface endpoints |
| **SIPVicious** | `Ready` | Security testing toolkit for SIP and VoIP endpoints |
| **Scapy** | `Ready` | Packet crafting utility with MAP, TCAP, and Diameter protocol support |
| **SIPp** | `Ready` | SIP traffic generator and performance testing tool |

---

### Device Flashing & AT Command Suites

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **ADB & Fastboot** | `Ready` | Android Debug Bridge (ADB) and fastboot recovery utility |
| **Heimdall** | `Ready` | Flashing software for Samsung Galaxy devices |
| **EDL** | `Ready` | Emergency Download (EDL) mode flasher for Qualcomm devices |
| **SP Flash Tool** | `Setup` (`sudo spflashtool-install`) | Smart Phone Flash Tool for MediaTek devices |
| **Gammu / Minicom** | `Ready` | AT command terminal and cellular modem management utilities |
| **ModMobMap** | `Ready` | Cellular network mapping and logging tool |
| **LTESniffer** | `Ready` | Passive LTE downlink sniffer and PCAP decoder |
| **LTE-Cell-Scanner** | `Ready` | LTE frequency band scanner and local oscillator calibrator |

---

### Broadband, ADSL, and DOCSIS / HFC Security

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **RouterSploit** | `Ready` | Exploitation framework for embedded devices (CPE routers/modems) |
| **RDNSx** | `Ready` | Rapid DNS Reverse Resolver for fast network enumeration |
| **asleap** | `Ready` | PPPoE MS-CHAPv2 dictionary attack and offline cracking tool |
| **snmp-check** | `Ready` | SNMP enumerator for mapping routing tables via weak community strings |
| **docsis** | `Ready` | Compile and decompile DOCSIS binary configuration files |
| **tftpd-hpa / isc-dhcp-server** | `Ready` | Rogue DHCP and TFTP servers for provisioning attacks |
| **yersinia / ettercap** | `Ready` | Layer 2 shared medium attacks (DHCP, STP, ARP spoofing) |

*For complete methodologies and attack guides, see the [Tools Directory](https://tschisel.telcosec.net) on the documentation portal.*

---

### Legacy GSM/2G & VoIP Security

| Tool | Status | Purpose |
| :--- | :---: | :--- |
| **YateBTS** | `Setup` (`sudo yatebts-install`) | GSM base station emulator based on the Yate engine |
| **OpenBTS** | `Setup` (`sudo openbts-install`) | Software-defined GSM base station access point |
| **kalibrate-gsm** | `Ready` | GSM band scanner and oscillator calibration tool |
| **Twinkle & Linphone** | `Ready` | SIP clients for VoIP protocol security assessment |
| **Baresip** | `Ready` | Command-line based modular VoIP terminal client |

---

## Kernel & OS Tuning

To ensure stable, high-throughput SDR operations and prevent RF sample drops, the OS is pre-configured with the following kernel-level optimizations:

* **Real-time Scheduling:** Configured PAM limits and the `realtime` group enable SDR applications (such as GNU Radio and srsRAN) to run threads at `SCHED_RR` priority 99 with memory-locking capabilities.
* **Low-Latency USB:** Customized `udev` rules disable USB autosuspend for USRP, BladeRF, HackRF, and RTL-SDR devices.
* **Non-Root Hardware Access:** `udev` rules map USB interfaces for cellular transceivers and hardware programmers to the `plugdev` group.
* **SCTP Optimization:** Preloaded `sctp` kernel module with adjusted socket buffers and retransmission timeout (RTO) values suited for SIGTRAN and Diameter scanning.
* **Kernel Hardening:** Configured security parameters including ASLR, symlink/hardlink protection, restricted `dmesg` access, and disabled ICMP redirects.
* **Firewall Configuration:** Active UFW configuration blocking incoming traffic by default.

---

## 5Ghoul — 5G NR Baseband Fuzzer

**5Ghoul** requires compilation prior to first use. Dependencies and build helper scripts are included in the environment.

Compile 5Ghoul using the appropriate command:
```bash
# For USRP B210:
sudo 5ghoul-install

# For BladeRF 2.0 xA4:
sudo 5ghoul-install --radio BLADERF
```

Once compiled, execute fuzzing runs:
```bash
sudo 5ghoul-run --Attack.Name=NAS_5GS_Fuzz
```
For advanced configurations, see the [Online 5Ghoul Guide](https://tschisel.telcosec.net/#fuzzer).

## Frequently Asked Questions (AEO & SEO)

**What is TelcoChisel?**
TelcoChisel is an advanced Live Linux OS tailored specifically for Telecom Security. It comes pre-loaded with tools for SDR engineering, cellular network auditing, and baseband research.

**Who created TelcoChisel?**
TelcoChisel was developed by TelcoSec, a leading consulting and training firm specializing in Telecom Security.

**Why is Telecom Security important?**
Telecom Security is critical to protecting mobile network infrastructures (like 4G, 5G, and beyond) against signaling attacks, rogue base stations, and baseband vulnerabilities. Tools like TelcoChisel help researchers and engineers identify and mitigate these risks.

---

## TelcoSec Ecosystem

The TelcoSec platform is integrated across three primary domains:

* **[telco-sec.com](https://telco-sec.com):** Corporate presence, consulting services, corporate training, and partnerships.
* **[telcosec.net](https://telcosec.net):** Public community projects focusing on telecommunications security, including the **[TelcoSec Academy](https://app.telcosec.net)**.
* **[telcosec.net](https://telcosec.net):** TelcoSec Labs infrastructure supporting virtualized environments and research.

---

## Community & Support

Resources for documentation, training, and community discussion:

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
