#!/bin/bash
# =============================================================================
# docker/scripts/40-device-tools.sh — telcochisel-device-tools image contents
#
# Runs as root during `docker build`, FROM telcochisel-base. Installs USB/
# serial device flashing and diagnostic wrappers — mirrors (not sources)
# builder/scripts/11-install-device-tools.sh, with sudo/systemctl/.desktop
# autostart entries dropped (no init/desktop in a container). These tools are
# inert without --device /dev/bus/usb and/or /dev/ttyUSB* at `docker run`
# time — see docker/README.md.
# =============================================================================
set -e

LIB=/opt/telcosec/lib
TELCOSEC_OPT=/opt/telcosec
# shellcheck source=00-container-common.sh
source "${LIB}/00-container-common.sh"
# shellcheck source=../../builder/scripts/lib/pip-retry.sh
source "${LIB}/pip-retry.sh"
# shellcheck source=../../builder/scripts/lib/record-tool.sh
source "${LIB}/record-tool.sh"
# shellcheck source=../../builder/scripts/lib/packages.sh
source "${LIB}/packages.sh"

suppress_services

# ─── 1. APT packages (PKGS_ADVANCED's device/modem subset, filtered) ───────
echo "=== Installing device-tools APT packages ==="
apt-get update
mapfile -t FILTERED_PKGS < <(filter_pkgs "${PKGS_ADVANCED[@]}")
apt_retry install -y --no-install-recommends "${FILTERED_PKGS[@]}"
rm -rf /var/lib/apt/lists/*

mkdir -p /etc/telcosec

# ─── 2. Samsung tools ────────────────────────────────────────────────────────
cat > /usr/local/bin/samsung-diag << 'SCRIPT'
#!/bin/bash
DEV=${1:-/dev/ttyUSB0}
echo "Sending Samsung diagnostic mode command to ${DEV}..."
echo -e "AT+DEVCONINFO\r" > "$DEV" 2>/dev/null || \
  minicom -D "$DEV" -b 115200 -8 -C /tmp/samsung-diag.log
SCRIPT
chmod +x /usr/local/bin/samsung-diag

cat > /usr/local/bin/samsung-adb << 'SCRIPT'
#!/bin/bash
adb "$@"
SCRIPT
chmod +x /usr/local/bin/samsung-adb

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

# ─── 3. Qualcomm EDL ─────────────────────────────────────────────────────────
pip3 install edl --break-system-packages 2>/dev/null || {
  git_clone_retry --depth 1 https://github.com/bkerler/edl "${TELCOSEC_OPT}/edl" 2>/dev/null || true
  if [ -d "${TELCOSEC_OPT}/edl" ]; then
    pip_retry install -e "${TELCOSEC_OPT}/edl" --break-system-packages
  fi
}
record_tool "EDL (Qualcomm)" "$(command -v edl 2>/dev/null || echo '/usr/local/bin/edl')" "baseband"

cat > /usr/local/bin/qc-diag << 'SCRIPT'
#!/bin/bash
DEV=${1:-/dev/ttyUSB0}
echo "Opening Qualcomm DIAG on ${DEV} (use SCAT for protocol decoding)"
python3 -m scat -t qc -d "$DEV" || minicom -D "$DEV" -b 115200 -8
SCRIPT
chmod +x /usr/local/bin/qc-diag

# ─── 4. MediaTek helper (mtkclient already installed in telcochisel-base) ──
cat > /usr/local/bin/mtk-auth-bypass << 'SCRIPT'
#!/bin/bash
echo "MTKClient — SLA/DAA auth bypass"
echo "Usage: mtk --auth da_auth.bin --payload payload.bin <command>"
echo ""
mtk --help
SCRIPT
chmod +x /usr/local/bin/mtk-auth-bypass

# ─── 5. AT command interface ─────────────────────────────────────────────────
pip_retry install atinout
if ! command -v atinout &>/dev/null; then
  git_clone_retry --depth 1 https://github.com/da-luce/atinout "${TELCOSEC_OPT}/atinout" 2>/dev/null || true
  if [ -d "${TELCOSEC_OPT}/atinout" ]; then
    cd "${TELCOSEC_OPT}/atinout" && make && cp atinout /usr/local/bin/
  fi
fi
record_tool "atinout" "/usr/local/bin/atinout" "baseband"

cat > /usr/local/bin/at-console << 'SCRIPT'
#!/bin/bash
DEV=${1:-$(ls /dev/ttyUSB* /dev/ttyACM* 2>/dev/null | head -1)}
if [ -z "$DEV" ]; then
  echo "No modem device found. Specify: at-console /dev/ttyUSBx"
  exit 1
fi
echo "Opening AT console on ${DEV} (Ctrl+A X to exit minicom)"
minicom -D "$DEV" -b 115200 -8 --noinit
SCRIPT
chmod +x /usr/local/bin/at-console

cat > /etc/telcosec/gammu-smsdrc << 'EOF'
[gammu]
; Edit device to match your modem port
device = /dev/ttyUSB0
connection = at115200
EOF

cat > /usr/local/bin/gammu-at << 'SCRIPT'
#!/bin/bash
DEV=${1:-/dev/ttyUSB0}; shift
gammu --port "$DEV" --connection at115200 "$@"
SCRIPT
chmod +x /usr/local/bin/gammu-at

# ─── 6. USB mode switch config for common dongles ────────────────────────────
mkdir -p /etc/usb_modeswitch.d
cat > /etc/usb_modeswitch.d/12d1:1446 << 'EOF'
# Huawei E171 / E3131 modem
TargetVendor=0x12d1
TargetProduct=0x1446
StandardEject=1
EOF

# ─── 7. Ownership + tool-manifest summary ───────────────────────────────────
install_container_healthcheck
chown -R telcosec:telcosec "${TELCOSEC_OPT}" /etc/telcosec
record_tool_summary

echo "=== telcochisel-device-tools installation complete ==="
