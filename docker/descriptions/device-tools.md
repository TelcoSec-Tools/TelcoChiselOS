# TelcoSec TelcoChisel Device Tools Container

[![Docker Pulls](https://img.shields.io/docker/pulls/telcosec/telcochisel-device-tools.svg)](https://hub.docker.com/r/telcosec/telcochisel-device-tools)
[![License: GPL-3.0](https://img.shields.io/badge/License-GPL%203.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Website: telcosec.net](https://img.shields.io/badge/Website-telcosec.net-orange.svg)](https://telcosec.net)

Official Mobile Device, Modem, and Baseband diagnostic and forensic flashing container image for **TelcoChisel**, developed by **TelcoSec** ([telcosec.net](https://telcosec.net)).

Extends `telcochisel-base` with low-level USB/Serial forensic tooling, modem AT command terminals, and proprietary baseband firmware extraction utilities.

---

## 📱 Flashing & Baseband Diagnostics Suite

- **Android & Mobile Hardware:** `adb`, `fastboot`, `heimdall` (Samsung Odin protocol flasher)
- **MediaTek (MTK) Baseband:** `mtkclient` (`mtk`), SP Flash Tool helper (`spflashtool-install`)
- **Qualcomm Baseband:**
  - `edl` (Qualcomm Emergency Download Mode loader)
  - `qcsuper` (Qualcomm Diag protocol diagnostic frames capture)
  - Samsung diagnostic mode launcher (`samsung-diag`)
- **Modem AT Terminals & Scripting:** `at-term`, `modem-info` (automated AT probe of revision, IMEI, IMSI, signal parameters)

---

## 🚀 Quick Start

Run with USB and serial modem passthrough:
```bash
docker run --rm -it \
  --device /dev/bus/usb \
  --device /dev/ttyUSB0 \
  telcosec/telcochisel-device-tools:latest
```

Query modem status or run diagnostic tools:
```bash
# Query attached cellular modem on /dev/ttyUSB0
modem-info /dev/ttyUSB0

# Open interactive AT command console
at-term /dev/ttyUSB0

# Inspect Android device via ADB
adb devices

# Run MediaTek bootrom exploit
mtk printgpt
```

---

## 🎓 Master Telecom Security at TelcoSec Academy

Deepen your knowledge of baseband reverse engineering, modem firmware extraction, and hardware diagnostics:
- **Baseband Forensic Labs:** Qualcomm Diag protocol decoding with QCSuper, MediaTek bootrom vulnerability exploitation, and Emergency Download (EDL) extraction.
- **SIM / eSIM Security:** Java Card applet auditing, SIM filesystem navigation, and GSMA eSIM profile provisioning forensics.
- 👉 **Access Live Labs & Training:** [app.telcosec.net](https://app.telcosec.net)

---

## 🌐 Resources & Documentation

- **TelcoSec Academy (Live Labs):** [app.telcosec.net](https://app.telcosec.net)
- **Official Website:** [telcosec.net](https://telcosec.net)
- **GitHub Repository:** [TelcoSec-Tools/TelcoChiselOS](https://github.com/TelcoSec-Tools/TelcoChiselOS)
