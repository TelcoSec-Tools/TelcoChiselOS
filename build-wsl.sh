#!/usr/bin/env bash
# build-wsl.sh — Build TelcoChisel ISO inside WSL kali-linux
#
# Usage (from Git Bash or any shell on the Windows host):
#   ./build-wsl.sh                       # full clean build
#   ./build-wsl.sh --resume              # keep chroot, re-run all phases
#   ./build-wsl.sh --resume-from=04      # skip phases 00-03, resume from 04
#   ./build-wsl.sh --pack-only           # repack squashfs → ISO only
#
# Environment overrides:
#   SQUASHFS_LEVEL=3 ./build-wsl.sh     # compression level 1-15 (default: 6)
#   USE_CCACHE=1     ./build-wsl.sh     # bind-mount ccache into chroot

set -euo pipefail

# ── Detect whether we are already running inside WSL ──────────────────────────
IN_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null; then
    IN_WSL=true
fi

# ── Resolve paths ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if $IN_WSL; then
    # Already inside WSL — path is already correct
    WSL_PATH="$SCRIPT_DIR"
else
    # Running from Git Bash on Windows: /m/foo → /mnt/m/foo
    WSL_PATH="$(echo "$SCRIPT_DIR" | sed 's|^/\([a-zA-Z]\)/|/mnt/\1/|')"
fi

# ── Forward args straight to build-iso.sh ─────────────────────────────────────
BUILD_ARGS="$*"

# ── Environment variables to forward ──────────────────────────────────────────
ENV_PREFIX="SQUASHFS_LEVEL=${SQUASHFS_LEVEL:-6}"
[ "${USE_CCACHE:-0}" = "1" ] && ENV_PREFIX="$ENV_PREFIX USE_CCACHE=1"

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo "  TelcoChisel ISO Builder — WSL kali-linux"
echo "  Repo   : $SCRIPT_DIR"
echo "  WSL    : $WSL_PATH"
echo "  Args   : ${BUILD_ARGS:-(full clean build)}"
echo "  zstd   : level ${SQUASHFS_LEVEL:-6}"
echo ""

# ── Run the build ─────────────────────────────────────────────────────────────
START=$(date +%s)

if $IN_WSL; then
    # Already inside WSL kali-linux — run directly
    echo "Running build directly (already inside WSL)..."
    echo ""
    cd "$WSL_PATH"
    eval "$ENV_PREFIX sudo bash build-iso.sh $BUILD_ARGS"
else
    # Running from Git Bash — check kali-linux exists then launch it
    # wsl.exe --list outputs UTF-16; probe by trying to run a no-op instead
    if ! wsl.exe -d kali-linux -- echo "" >/dev/null 2>&1; then
        echo "ERROR: WSL distribution 'kali-linux' not found."
        echo "       Install it with:  wsl --install -d kali-linux"
        exit 1
    fi
    echo "Launching WSL kali-linux build..."
    echo ""
    wsl.exe -d kali-linux -u root -- \
        bash -c "cd \"$WSL_PATH\" && $ENV_PREFIX sudo bash build-iso.sh $BUILD_ARGS"
fi

EXIT_CODE=$?
END=$(date +%s)
ELAPSED=$(( END - START ))
MIN=$(( ELAPSED / 60 ))
SEC=$(( ELAPSED % 60 ))

echo ""
if [ "$EXIT_CODE" -eq 0 ]; then
    echo "  Build complete in ${MIN}m ${SEC}s"
    ISO="$SCRIPT_DIR/TelcoChisel-live.iso"
    if [ -f "$ISO" ]; then
        SIZE=$(du -m "$ISO" | cut -f1)
        echo "  ISO: $ISO (${SIZE} MB)"
    fi
else
    echo "  Build FAILED (exit $EXIT_CODE) after ${MIN}m ${SEC}s"
    exit "$EXIT_CODE"
fi
