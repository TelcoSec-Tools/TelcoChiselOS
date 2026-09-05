# TelcoChisel Live Linux OS

**Official SourceForge File Release Repository**  
*Advanced 5G/4G Cellular Security & Telecom Auditing Live Operating System by TelcoSec*

---

### Latest Release: TelcoChisel v3.0.0

TelcoChisel is distributed in two official editions:
- **Flagship Field Edition (Full):** `TelcoChisel-3.0.0-amd64.iso` (~5.0 GB, symlinked as `TelcoChisel-live.iso`)
  - All 88 pre-installed SDR, cellular RAN, 5G SA, SIM, baseband, and wireline telecom security tools.
  - Complete air-gapped readiness with offline UHD FPGA images, GNU Radio 3.10, and Open5GS.
- **Modular Lite Edition (Lite):** `TelcoChisel-3.0.0-lite-amd64.iso` (~1.8 GB)
  - Minimal footprint: XFCE desktop, Low-Latency kernel, Wireshark, Python runtime, and `telcosec-pkg` CLI client to pull modular domain suites on-demand from `meta.telcosec.net`.

- **Base OS:** Ubuntu 24.04 LTS (Noble Numbat)
- **Kernel:** Linux Low-Latency Real-Time (`linux-image-lowlatency`, 1000Hz)
- **Desktop:** XFCE4 + i3 Tiling Window Manager (LightDM, GPU Accelerated)
- **Default Credentials:**
  - **Username:** `telcosec`
  - **Password:** `telcosec`

---

### SHA-256 Checksum Verification

Always verify the integrity of your downloaded ISO before writing to USB:

```bash
# Linux / macOS
sha256sum -c TelcoChisel-live.iso.sha256

# Or manual verification:
sha256sum TelcoChisel-live.iso
```

```powershell
# Windows PowerShell
Get-FileHash .\TelcoChisel-live.iso -Algorithm SHA256
```

---

### Creating Bootable Live Media

#### Option A: Using `dd` (Linux / macOS)
```bash
# Identify your target USB drive (e.g., /dev/sdX)
lsblk

# Write ISO directly to block device (NOT a partition like /dev/sdX1)
sudo dd if=TelcoChisel-live.iso of=/dev/sdX bs=4M status=progress conv=fsync
```

#### Option B: Using GUI Flashers (Windows / Linux / macOS)
1. **BalenaEtcher:** Select `TelcoChisel-live.iso`, choose target USB drive, click **Flash!**.
2. **Rufus (Windows):** Select USB device, browse to `TelcoChisel-live.iso`, partition scheme `MBR` or `GPT`, write mode **DD Image Mode** (recommended).

#### Option C: Native LUKS-Encrypted Persistence
Boot into TelcoChisel Live Mode and run our dedicated USB creator:
```bash
sudo telcosec-create-usb /dev/sdX
```
This partitions the drive, deploys the ISO, and creates an AES-XTS LUKS-encrypted `casper-rw` partition for secure field persistence.

---

### Joining Split Files (If downloaded in parts)
If you downloaded the split release parts (`.part-aa`, `.part-ab`, `.part-ac`):

```bash
# Linux / macOS
cat TelcoChisel-live.iso.part-* > TelcoChisel-live.iso

# Windows Command Prompt (CMD)
copy /b TelcoChisel-live.iso.part-aa + TelcoChisel-live.iso.part-ab + TelcoChisel-live.iso.part-ac TelcoChisel-live.iso
```

---

### Quick Links & Official Portals
- **Documentation & Tool Guides:** [chisel.telcosec.net](https://chisel.telcosec.net)
- **TelcoSec Academy (Interactive Labs):** [app.telcosec.net](https://app.telcosec.net)
- **Official GitHub Codebase:** [github.com/TelcoSec-Tools/TelcoChiselOS](https://github.com/TelcoSec-Tools/TelcoChiselOS)
- **Community Forum:** [community.telcosec.net](https://community.telcosec.net)
- **Discord Community:** [discord.gg/RykzXTQFXF](https://discord.gg/RykzXTQFXF)
