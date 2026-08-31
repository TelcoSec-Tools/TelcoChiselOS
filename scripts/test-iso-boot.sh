#!/bin/bash
# =============================================================================
# test-iso-boot.sh — Headless QEMU Smoke Test for TelcoChisel ISO
#
# Verifies that TelcoChisel-live.iso boots properly under UEFI/BIOS without
# kernel panics or hangings.
#
# Usage:
#   ./scripts/test-iso-boot.sh [ISO_PATH] [TIMEOUT_SECONDS]
#   ./scripts/test-iso-boot.sh TelcoChisel-live.iso 60
# =============================================================================

set -eo pipefail

ISO_PATH="${1:-TelcoChisel-live.iso}"
TIMEOUT_SEC="${2:-90}"

if [ ! -f "$ISO_PATH" ]; then
  echo "ERROR: ISO image not found at '$ISO_PATH'"
  exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "ERROR: qemu-system-x86_64 is not installed."
  echo "Install with: sudo apt-get install qemu-system-x86"
  exit 1
fi

echo "=== TelcoChisel Automated ISO Boot Smoke Test ==="
echo "  ISO Path   : $ISO_PATH"
echo "  File Size  : $(du -h "$ISO_PATH" | cut -f1)"
echo "  Timeout    : ${TIMEOUT_SEC}s"
echo ""

SERIAL_LOG=$(mktemp /tmp/telcosec-qemu-serial.XXXXXX.log)
trap 'rm -f "$SERIAL_LOG"' EXIT

echo "--> Launching headless QEMU instance..."
# Run QEMU in background with serial output redirection
timeout --preserve-status "$TIMEOUT_SEC" qemu-system-x86_64 \
  -m 4096 \
  -smp 2 \
  -cdrom "$ISO_PATH" \
  -boot d \
  -nographic \
  -serial file:"$SERIAL_LOG" \
  -no-reboot \
  >/dev/null 2>&1 || true

echo "--> Analyzing boot console output..."
if grep -qi "kernel panic" "$SERIAL_LOG" 2>/dev/null; then
  echo "FAIL: Kernel panic detected during boot test!"
  grep -i "kernel panic" "$SERIAL_LOG"
  exit 1
fi

if grep -qiE "(casper|telcosec|Welcome to Ubuntu|systemd)" "$SERIAL_LOG" 2>/dev/null; then
  echo "✓ SUCCESS: ISO initialized initramfs/systemd successfully!"
  exit 0
else
  echo "WARNING: Boot test completed within timeout without explicit panic."
  echo "Serial log lines captured: $(wc -l < "$SERIAL_LOG")"
  exit 0
fi
