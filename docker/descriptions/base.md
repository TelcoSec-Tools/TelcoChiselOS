# TelcoSec TelcoChisel Base Container

[![Docker Pulls](https://img.shields.io/docker/pulls/telcosec/telcochisel-base.svg)](https://hub.docker.com/r/telcosec/telcochisel-base)
[![Docker Image Size](https://img.shields.io/docker/image-size/telcosec/telcochisel-base/latest)](https://hub.docker.com/r/telcosec/telcochisel-base)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Website: telcosec.net](https://img.shields.io/badge/Website-telcosec.net-orange.svg)](https://telcosec.net)

Official headless CLI container image for **TelcoChisel**, the premier telecom security penetration testing and research distribution developed by **TelcoSec** ([telcosec.net](https://telcosec.net)).

Built on **Ubuntu 24.04 LTS (Noble Numbat)**, stripped of desktop/manpage bloat, and enrolled in the official [TelcoSec Metapackage Archive](https://meta.telcosec.net).

---

## 🛠 Included Telecom Tools

- **Core Protocol Analysis & Scanning:** `nmap`, `tshark`, `wireshark-common`, `scapy`, `sctpscan`
- **VoIP & Signaling Assessment:** `sipvicious`, `sipsak`, `sipp` (with PCAP & SCTP enabled), `SigPloit`, `Diafuzzer`
- **Cellular & SIM Investigation:** `pySim-shell`, `pySim-prog`, `pySim-read`, `lpac` (eSIM LPA), `SIMtrace2` host tools, `SIMurai`, `SIMTester`
- **Baseband Diagnostics:** `FirmWire` (emulation framework), `QCSuper` (Qualcomm Diag), `MTKClient` (MediaTek), `SCAT`
- **Radio Access Network (RAN) Simulation & Sniffing:** `UERANSIM` (`nr-gnb`, `nr-ue`, `nr-cli`), `LTESniffer`, `kalibrate-gsm`
- **Network & Perimeter Defense:** `RouterSploit`, `wireguard`, `freeradius-utils`, `vlan`, `macchanger`
- **Wordlists:** Curated TelcoSec telecom wordlists (APN lists, operator IMSI ranges, permutation scripts) in `/usr/share/wordlists/telecom`

---

## 🚀 Quick Start

Run an interactive shell:
```bash
docker run --rm -it telcosec/telcochisel-base:latest
```

Execute a scan or tool directly:
```bash
# Inspect SIM cards with pySim
docker run --rm -it --device /dev/bus/usb telcosec/telcochisel-base:latest pySim-shell

# Run SCTP scanner
docker run --rm -it telcosec/telcochisel-base:latest sctpscan -h

# Run 5G UE simulation
docker run --rm -it telcosec/telcochisel-base:latest nr-ue --help
```

---

## 🎓 Master Telecom Security at TelcoSec Academy

Accelerate your expertise in telecommunications cybersecurity and vulnerability research with official hands-on labs and certifications:
- **Interactive Live Labs:** Signaling attacks (SS7, Diameter, GTP-C), 5G Standalone core penetration testing, and baseband firmware reverse engineering.
- **Real-World Scenarios:** From rogue base stations (IMSI catchers) to eBPF-accelerated 5G UPF auditing.
- 👉 **Access Live Labs & Training:** [app.telcosec.net](https://app.telcosec.net)

---

## 🔒 Security Notice & Legal Disclaimer

TelcoChisel and TelcoSec tools are designed strictly for authorized telecommunications penetration testing, educational research, network defense audits, and vulnerability verification. Unauthorized interception of telecommunication signals or unauthorized testing of public carrier networks without explicit consent is illegal.

---

## 🌐 Resources & Documentation

- **TelcoSec Academy (Live Labs):** [app.telcosec.net](https://app.telcosec.net)
- **Official Website:** [telcosec.net](https://telcosec.net)
- **Documentation & Research:** [telcosec.net/docs](https://telcosec.net)
- **GitHub Repository:** [TelcoSec-Tools/TelcoChiselOS](https://github.com/TelcoSec-Tools/TelcoChiselOS)
- **Official Metapackages:** [meta.telcosec.net](https://meta.telcosec.net)
