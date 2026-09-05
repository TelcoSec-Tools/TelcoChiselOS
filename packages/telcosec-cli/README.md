# TelcoSec Operator CLI (`telcosec`)

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![Go Report Card](https://goreportcard.com/badge/github.com/TelcoSec-Tools/telcosec-cli)](https://goreportcard.com/report/github.com/TelcoSec-Tools/telcosec-cli)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux%20(x86__64%20%7C%20arm64)-informational.svg)](https://chisel.telcosec.net)

The official standalone operator CLI and telemetry suite for telecom security engineers, cellular penetration testers, and SDR researchers. 

`telcosec` is designed to run natively on **TelcoChiselOS** or any Debian/Ubuntu-derived Linux distribution (Ubuntu 24.04/22.04, Debian 12, Kali Linux, DragonOS).

---

## Key Capabilities

- **Zero-Dependency Architecture**: Statically compiled binary requiring no external runtime dependencies; directly reads Linux kernel subsystems (`/proc`, `/sys`, PAM limits).
- **SDR & Radio Hardware Diagnostics**: Automated discovery and health audits for Ettus USRP (UHD), Great Scott Gadgets HackRF, Nuand BladeRF, LimeSDR, RTL-SDR, and ADALM-PLUTO.
- **10GbE Network Transceiver Optimization**: One-click Jumbo Frame configuration (MTU 9000), 4096 RX/TX ring buffer descriptors, and 64 MB socket buffers for high-bandwidth SDRs (USRP X310, N310).
- **5G Standalone Lifecycle Management**: Controls Open5GS core network services and provisions subscriber credentials (`IMSI`, `K`, `OPc`) via `open5gs-dbctl`.
- **Tool Catalog Keyword Search**: Instantly searches installed desktop tools and applications by protocol keyword (`sctp`, `diameter`, `ss7`, `nas`, `ran`).
- **Operational Profile Switching**: Toggles between Lab Mode (`rp_filter=0`, unrestricted packet crafting) and Field Mode (hardened reverse path filtering).

---

## Installation & Compilation

### Requirements
- Linux kernel 5.15+ (low-latency or PREEMPT_RT recommended for high-MSPS SDRs)
- Go 1.22+ (for building from source)

### Building from Source
```bash
git clone https://github.com/TelcoSec-Tools/telcosec-cli.git
cd telcosec-cli
make build
sudo make install
```

---

## Command Reference

| Command | Subcommands / Flags | Description |
| :--- | :--- | :--- |
| `telcosec check` | `status` | Comprehensive audit of kernel architecture, PAM realtime limits, hugepages, USBFS buffers, and core services. |
| `telcosec hardware` | `hw`, `devices` | Enumerate and probe connected SDR transceivers, serial AT modems, and PC/SC smartcard readers. |
| `telcosec sdr` | `status`, `usb`, `10g`, `firmware` | SDR driver stack check, USB buffer tuning, 10GbE optimization, and FPGA bitstream inspection. |
| `telcosec 10g` | `status`, `tune <iface>`, `setup <iface> [preset]`, `probe [ip]` | 10Gbps SFP+ interface optimization for Ettus USRP X310/N310 transceivers. |
| `telcosec firmware` | | Inspect local offline FPGA bitstream caches for BladeRF (`.rbf`) and USRP (`.bin`). |
| `telcosec profile` | `lab`, `field`, `status` | Switch operational profiles (Lab Mode vs Field Mode). |
| `telcosec 5g-sa` | `start`, `stop`, `status`, `add-sub` | Manage local Open5GS 5G Standalone core network and provision test SIMs. |
| `telcosec scan` | `sctp`, `sip`, `asleap` | Launch telecom signaling assessment wizards and scanners. |
| `telcosec search` | `<query>` | Search the 88 installed telecom tools and desktop entries by keyword. |
| `telcosec docs` | | Open local offline documentation (`/usr/share/doc/telcosec/index.html`) or online docs portal. |
| `telcosec academy`| | Launch TelcoSec Academy interactive field labs bridge (`app.telcosec.net`). |
| `telcosec feedback`| `review` | Open SourceForge user reviews and community support channels. |
| `telcosec version` | `-v`, `--version` | Display version, build commit, and kernel environment. |

---

## Package Structure

```text
telcosec-cli/
├── cmd/
│   └── telcosec/                     # CLI entrypoint and subcommand routing
│       └── main.go
├── pkg/
│   ├── cellular/                     # Open5GS 5G SA core lifecycle & subscriber provisioning
│   ├── docs/                         # Interactive offline/online documentation launcher
│   ├── network/                      # 10GbE MTU 9000, ring buffer & socket buffer tuning
│   ├── sdr/                          # USB & Network SDR discovery, FPGA bitstream management
│   ├── search/                       # Desktop launcher catalog parser and keyword search
│   └── telemetry/                    # Kernel latency, PAM limits, USBFS memory, hugepages
├── Makefile
├── LICENSE
└── README.md
```

---

## License

`telcosec-cli` is licensed under the [Apache License, Version 2.0](LICENSE).
