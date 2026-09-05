# TelcoSec TelcoChisel Core Network Container

[![Docker Pulls](https://img.shields.io/docker/pulls/telcosec/telcochisel-core-network.svg)](https://hub.docker.com/r/telcosec/telcochisel-core-network)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Website: telcosec.net](https://img.shields.io/badge/Website-telcosec.net-orange.svg)](https://telcosec.net)

Official 4G/5G Core and Radio Access Network (RAN) emulation and security evaluation container image for **TelcoChisel**, developed by **TelcoSec** ([telcosec.net](https://telcosec.net)).

Extends `telcochisel-base` with build-dependency toolchains and automated first-run installers for full cellular stacks.

---

## 📡 Cellular Core & RAN Tools

- **srsRAN Project:** Next-generation 5G CU/DU gNB software stack (`srsran-install`).
- **Open5GS:** Complete 5G Standalone (5G SA) & 4G EPC Core Network stack (`open5gs-install`).
- **OpenAirInterface (OAI) UE:** 4G/5G User Equipment software stack (`oai-install --radio USRP|BLADERF|LMSSDR`).
- **5Ghoul:** Automated 5G/4G firmware exploit and fuzzing framework (`5ghoul-install`).
- **gtp5g:** 5G SA UPF Kernel Acceleration loader stub (`gtp5g-load`).
- **PLMN Presets:** Pre-configured ITU-T standard test network PLMN (MCC `001`, MNC `01`, TAC `0x0001`) in `/etc/telcosec/plmn.conf`.

---

## 🚀 Quick Start

Run with network administration capability and TUN interface support:
```bash
docker run --rm -it \
  --cap-add=NET_ADMIN \
  --device /dev/net/tun \
  --network host \
  telcosec/telcochisel-core-network:latest
```

Compile and initialize stacks on first run:
```bash
# Build and install srsRAN Project
srsran-install

# Setup Open5GS Core Network
open5gs-install

# Setup 5Ghoul fuzzing testbed
5ghoul-install
```

---

## 🎓 Master Telecom Security at TelcoSec Academy

Master cellular core architecture, 5G Standalone protocols, and gNB exploitation:
- **5G Core Labs:** Open5GS deployment, 5G SA SBA (Service-Based Architecture) penetration testing, and HTTP/2 REST signaling attacks.
- **RAN & UPF Exploits:** 5Ghoul fuzzing, SCTP multi-homing attacks, and GTP-U tunnel decapsulation.
- 👉 **Access Live Labs & Training:** [app.telcosec.net](https://app.telcosec.net)

---

## 🌐 Resources & Documentation

- **TelcoSec Academy (Live Labs):** [app.telcosec.net](https://app.telcosec.net)
- **Official Website:** [telcosec.net](https://telcosec.net)
- **GitHub Repository:** [TelcoSec-Tools/TelcoChiselOS](https://github.com/TelcoSec-Tools/TelcoChiselOS)
