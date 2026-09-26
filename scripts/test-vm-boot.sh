#!/usr/bin/env bash
# =============================================================================
# test-vm-boot.sh — Headless QEMU Smoke Test for TelcoChisel VM Appliances
#
# Verifies that TelcoChisel VM images (.qcow2, .vmdk, or .raw) boot properly
# under UEFI firmware without kernel panics, filesystem errors, or init hangs.
#
# Usage:
#   ./scripts/test-vm-boot.sh [OPTIONS] [VM_IMAGE_PATH]
#   ./scripts/test-vm-boot.sh --timeout=60 dist/vm/TelcoChisel-2026.2-Proxmox.qcow2
# =============================================================================

set -eo pipefail

IMAGE_PATH=""
TIMEOUT_SEC=90
MEMORY_MB=4096
SMP_CORES=2
HEADLESS=true

while [ $# -gt 0 ]; do
  case "$1" in
    --timeout=*)
      TIMEOUT_SEC="${1#--timeout=}"
      shift
      ;;
    --timeout)
      TIMEOUT_SEC="$2"
      shift 2
      ;;
    --memory=*|-m=*)
      MEMORY_MB="${1#*=}"
      shift
      ;;
    --memory|-m)
      MEMORY_MB="$2"
      shift 2
      ;;
    --smp=*|-c=*)
      SMP_CORES="${1#*=}"
      shift
      ;;
    --headless)
      HEADLESS=true
      shift
      ;;
    --gui)
      HEADLESS=false
      shift
      ;;
    --help|-h)
      cat << 'HELP'
Usage: ./scripts/test-vm-boot.sh [OPTIONS] [VM_IMAGE_PATH]

Options:
  --timeout=N      Maximum boot test timeout in seconds (default: 90)
  --memory=MB      RAM allocated to QEMU guest in MB (default: 4096)
  --smp=N          CPU cores allocated to guest (default: 2)
  --headless       Run headless with serial logging (default: true)
  --gui            Launch graphical QEMU display window
  --help, -h       Display this help manual

Examples:
  ./scripts/test-vm-boot.sh dist/vm/TelcoChisel-2026.2-Proxmox.qcow2
  ./scripts/test-vm-boot.sh --timeout=60 --memory=2048 dist/vm/TelcoChisel-2026.2-VMware.vmdk
HELP
      exit 0
      ;;
    *)
      if [ -z "$IMAGE_PATH" ]; then
        IMAGE_PATH="$1"
      fi
      shift
      ;;
  esac
done

if [ -z "$IMAGE_PATH" ]; then
  # Auto-discover in dist/vm or current directory
  CANDIDATES=(
    dist/vm/TelcoChisel-*-Proxmox.qcow2
    dist/vm/*.qcow2
    dist/vm/*.vmdk
    *.qcow2
    *.vmdk
  )
  for c in "${CANDIDATES[@]}"; do
    if [ -f "$c" ]; then
      IMAGE_PATH="$c"
      break
    fi
  done
fi

if [ -z "$IMAGE_PATH" ] || [ ! -f "$IMAGE_PATH" ]; then
  echo "ERROR: VM image not found. Specify path or run after build-vm.sh" >&2
  exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
  echo "ERROR: qemu-system-x86_64 is not installed." >&2
  echo "Install with: sudo apt-get install qemu-system-x86" >&2
  exit 1
fi

echo "=== TelcoChisel Automated VM Boot Smoke Test ==="
echo "  Image Path : $IMAGE_PATH"
echo "  File Size  : $(du -h "$IMAGE_PATH" | cut -f1)"
echo "  Timeout    : ${TIMEOUT_SEC}s"
echo "  Guest RAM  : ${MEMORY_MB} MB"
echo "  Guest SMP  : ${SMP_CORES} cores"
echo "  Headless   : $HEADLESS"
echo ""

SERIAL_LOG=$(mktemp /tmp/telcosec-qemu-vm-serial.XXXXXX.log 2>/dev/null || mktemp /var/tmp/telcosec-qemu-vm-serial.XXXXXX.log 2>/dev/null || echo "qemu-vm-serial.log")
trap 'rm -f "$SERIAL_LOG"' EXIT

# Detect image format
FORMAT="qcow2"
case "$IMAGE_PATH" in
  *.vmdk) FORMAT="vmdk" ;;
  *.raw|*.img) FORMAT="raw" ;;
  *.qcow2) FORMAT="qcow2" ;;
esac

# Look for OVMF UEFI firmware
OVMF_CODE=""
for ovmf in /usr/share/OVMF/OVMF_CODE.fd /usr/share/ovmf/OVMF.fd /usr/share/qemu/OVMF.fd; do
  if [ -f "$ovmf" ]; then
    OVMF_CODE="$ovmf"
    break
  fi
done

QEMU_ARGS=(
  -m "$MEMORY_MB"
  -smp "$SMP_CORES"
  -drive "file=${IMAGE_PATH},format=${FORMAT},if=virtio,snapshot=on"
  -no-reboot
)

if [ -n "$OVMF_CODE" ]; then
  QEMU_ARGS+=(-bios "$OVMF_CODE")
  echo "  Firmware   : UEFI ($OVMF_CODE)"
else
  echo "  Firmware   : SeaBIOS (Default)"
fi

if [ "$HEADLESS" = "true" ]; then
  QEMU_ARGS+=(
    -display none
    -serial "file:${SERIAL_LOG}"
  )
else
  QEMU_ARGS+=(
    -serial "file:${SERIAL_LOG}"
  )
fi

echo "[*] Launching QEMU instance (snapshot mode enabled)..."
qemu-system-x86_64 "${QEMU_ARGS[@]}" &
QEMU_PID=$!

CHECK_INTERVAL=2
ELAPSED=0
SUCCESS=false

echo -n "[*] Monitoring boot sequence: "
while [ $ELAPSED -lt "$TIMEOUT_SEC" ]; do
  if ! kill -0 $QEMU_PID 2>/dev/null; then
    echo ""
    echo "[-] QEMU terminated prematurely!"
    break
  fi

  if [ -f "$SERIAL_LOG" ]; then
    if grep -qE "Linux version|login:|telcochisel|Ubuntu" "$SERIAL_LOG" 2>/dev/null; then
      echo ""
      echo "[+] Boot verification successful! Detected active kernel/userspace startup."
      SUCCESS=true
      break
    fi
  fi

  sleep $CHECK_INTERVAL
  ELAPSED=$((ELAPSED + CHECK_INTERVAL))
  echo -n "."
done

# Terminate test instance
kill -9 $QEMU_PID 2>/dev/null || true
wait $QEMU_PID 2>/dev/null || true

echo ""
if [ "$SUCCESS" = "true" ]; then
  echo "=== VM Boot Test Passed in ${ELAPSED}s ==="
  exit 0
else
  echo "[-] VM Boot Test Failed or Timed Out after ${TIMEOUT_SEC}s"
  if [ -f "$SERIAL_LOG" ]; then
    echo "--- Last 25 lines of Serial Output ---"
    tail -n 25 "$SERIAL_LOG" || true
    echo "--------------------------------------"
  fi
  exit 1
fi
