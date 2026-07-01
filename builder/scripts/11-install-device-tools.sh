#!/bin/bash
set -e

echo "=== Installing Device & Driver Tools ==="

export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/false
git config --global credential.helper ''

TELCOSEC_OPT=/opt/telcosec
mkdir -p "$TELCOSEC_OPT"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/record-tool.sh
source "${SCRIPT_DIR}/lib/record-tool.sh"
# shellcheck source=lib/pip-retry.sh
source "${SCRIPT_DIR}/lib/pip-retry.sh"

# ─── A. Samsung tools ────────────────────────────────────────────────────────
echo "  Samsung tools (heimdall already installed via apt)..."
# heimdall-flash installed in 00-install-all-packages.sh

# Samsung diagnostic mode udev (already in 50-telcosec-hw.rules)
# Create a friendly wrapper
cat > /usr/local/bin/samsung-diag << 'SCRIPT'
#!/bin/bash
# Enable Samsung diagnostic mode via AT command
DEV=${1:-/dev/ttyUSB0}
echo "Sending Samsung diagnostic mode command to ${DEV}..."
echo -e "AT+DEVCONINFO\r" > "$DEV" 2>/dev/null || \
  minicom -D "$DEV" -b 115200 -8 -C /tmp/samsung-diag.log
SCRIPT
chmod +x /usr/local/bin/samsung-diag

# ADB convenience wrappers (adb/fastboot installed via apt)
cat > /usr/local/bin/samsung-adb << 'SCRIPT'
#!/bin/bash
# Samsung ADB with common flags
adb "$@"
SCRIPT
chmod +x /usr/local/bin/samsung-adb

# SP Flash Tool download helper (MTK proprietary — no Linux .deb)
cat > /usr/local/bin/spflashtool-install << 'SCRIPT'
#!/bin/bash
echo "==================================================="
echo "  SP Flash Tool (MediaTek)"
echo "==================================================="
echo "  Download from: https://spflashtool.com/"
echo "  Or: https://github.com/lenovo-prow/sp-flash-tool"
echo ""
echo "  After downloading:"
echo "    tar -xzf flash_tool_*.tar.gz"
echo "    chmod +x FlashToolLinux flash_tool"
echo "    sudo ./FlashToolLinux"
echo ""
echo "  MTKClient (already installed) covers most use cases:"
echo "    mtk --help"
echo "==================================================="
SCRIPT
chmod +x /usr/local/bin/spflashtool-install

# ─── B. Qualcomm tools ───────────────────────────────────────────────────────
echo "  Installing Qualcomm EDL tools..."
# Try pip install first, fall back to source
# NOTE: intentionally NOT using pip_retry here — pip_retry always returns 0
# (it's designed for simple non-fatal installs), which would silently defeat
# the `|| { fallback }` below. This line needs the real pip3 exit code so a
# failed PyPI install actually triggers the source-build fallback.
pip3 install edl --break-system-packages 2>/dev/null || {
  git clone --depth 1 https://github.com/bkerler/edl "${TELCOSEC_OPT}/edl" 2>/dev/null || true
  if [ -d "${TELCOSEC_OPT}/edl" ]; then
    pip_retry install -e "${TELCOSEC_OPT}/edl" --break-system-packages
  fi
}
record_tool "EDL (Qualcomm)" "$(command -v edl 2>/dev/null || echo '/usr/local/bin/edl')" "baseband"

# Qualcomm DIAG/AT helper
cat > /usr/local/bin/qc-diag << 'SCRIPT'
#!/bin/bash
# Connect to Qualcomm diagnostic interface
DEV=${1:-/dev/ttyUSB0}
echo "Opening Qualcomm DIAG on ${DEV} (use SCAT for protocol decoding)"
python3 -c "
from scat.parsers.qualcomm import QualcommParser
" 2>/dev/null && \
  python3 -m scat -t qc -d "$DEV" || \
  minicom -D "$DEV" -b 115200 -8
SCRIPT
chmod +x /usr/local/bin/qc-diag

# ─── C. MediaTek udev helpers ────────────────────────────────────────────────
echo "  MediaTek tools (mtkclient already installed)..."
# mtkclient already installed in 06-install-ue-analysis.sh
# Create convenience wrapper for MTK auth bypass
cat > /usr/local/bin/mtk-auth-bypass << 'SCRIPT'
#!/bin/bash
echo "MTKClient — SLA/DAA auth bypass"
echo "Usage: mtk --auth da_auth.bin --payload payload.bin <command>"
echo ""
mtk --help
SCRIPT
chmod +x /usr/local/bin/mtk-auth-bypass

# ─── D. AT command interface ─────────────────────────────────────────────────
echo "  Configuring AT command tools..."

# Quick AT command sender (atinout)
pip_retry install atinout
# If not available via pip, install from source
if ! command -v atinout &>/dev/null; then
  git clone --depth 1 https://github.com/da-luce/atinout "${TELCOSEC_OPT}/atinout" \
    2>/dev/null || true
  if [ -d "${TELCOSEC_OPT}/atinout" ]; then
    cd "${TELCOSEC_OPT}/atinout" && make && cp atinout /usr/local/bin/ && cd /
  fi
fi
record_tool "atinout" "/usr/local/bin/atinout" "baseband"

# Interactive AT console launcher
cat > /usr/local/bin/at-console << 'SCRIPT'
#!/bin/bash
# Interactive AT command console
DEV=${1:-$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -1)}
if [ -z "$DEV" ]; then
  echo "No modem device found. Specify: at-console /dev/ttyUSBx"
  exit 1
fi
echo "Opening AT console on ${DEV} (Ctrl+A X to exit minicom)"
minicom -D "$DEV" -b 115200 -8 --noinit
SCRIPT
chmod +x /usr/local/bin/at-console

# Gammu modem config helper
cat > /etc/telcosec/gammu-smsdrc << 'EOF'
[gammu]
; Edit device to match your modem port
device = /dev/ttyUSB0
connection = at115200
EOF

cat > /usr/local/bin/gammu-at << 'SCRIPT'
#!/bin/bash
# Gammu AT command wrapper
DEV=${1:-/dev/ttyUSB0}; shift
gammu --port "$DEV" --connection at115200 "$@"
SCRIPT
chmod +x /usr/local/bin/gammu-at

# ─── E. Zoiper5 softphone ────────────────────────────────────────────────────
echo "  Installing Zoiper5 softphone..."
# Try downloading Zoiper5 .deb from official site
ZOIPER_URL="https://www.zoiper.com/en/voip-softphone/download/zoiper5/for/linux-deb"
wget --timeout=30 -q -O /tmp/zoiper5.deb "$ZOIPER_URL" 2>/dev/null && {
  dpkg -i /tmp/zoiper5.deb 2>/dev/null || apt-get install -f -y 2>/dev/null || true
  rm -f /tmp/zoiper5.deb
} || {
  echo "  Zoiper5 download failed — installing Linphone as alternative"
  apt-get install -y linphone 2>/dev/null || true
}

# ─── F. Modem manager GUI config ─────────────────────────────────────────────
echo "  Configuring ModemManager GUI..."
# modem-manager-gui installed via apt in 00
# Ensure ModemManager is enabled
systemctl enable ModemManager 2>/dev/null || true

# USB mode switch configuration for common dongles
cat > /etc/usb_modeswitch.d/12d1:1446 << 'EOF'
# Huawei E171 / E3131 modem
TargetVendor=0x12d1
TargetProduct=0x1446
StandardEject=1
EOF

# ─── G. Android platform tools (ADB/Fastboot) ────────────────────────────────
echo "  Configuring ADB/Fastboot..."
# adb + fastboot installed via apt
# Enable ADB server autostart on login
mkdir -p /etc/xdg/autostart
cat > /etc/xdg/autostart/adb-server.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=ADB Server
Comment=Start Android Debug Bridge server
Exec=adb start-server
Terminal=false
Categories=System;
X-GNOME-Autostart-enabled=true
EOF

echo "=== Device Tools installation complete ==="
