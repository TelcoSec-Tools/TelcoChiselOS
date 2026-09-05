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
#   SQUASHFS_LEVEL=3 ./build-wsl.sh     # zstd compression level 1-19 (default: 6 here; CI uses 3; release uses 19)
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
if [ -z "${ISO_VERSION:-}" ]; then
    ISO_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || git describe --tags --always 2>/dev/null || echo "3.0.0")
    ISO_VERSION="${ISO_VERSION#v}"
fi
ENV_PREFIX="ISO_VERSION=${ISO_VERSION} SQUASHFS_LEVEL=${SQUASHFS_LEVEL:-6}"
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
    if [ "$(id -u)" -eq 0 ]; then
        eval "$ENV_PREFIX bash build-iso.sh $BUILD_ARGS"
    else
        eval "$ENV_PREFIX sudo -E bash build-iso.sh $BUILD_ARGS"
    fi
else
    # Running from Git Bash — probe for Ubuntu-24.04 / Ubuntu first for native GRUB alignment
    WSL_DISTRO="${WSL_DISTRO:-}"
    if [ -z "$WSL_DISTRO" ]; then
        if wsl.exe -d Ubuntu-24.04 -- echo "" >/dev/null 2>&1; then
            WSL_DISTRO="Ubuntu-24.04"
        elif wsl.exe -d Ubuntu -- echo "" >/dev/null 2>&1; then
            WSL_DISTRO="Ubuntu"
        elif wsl.exe -d kali-linux -- echo "" >/dev/null 2>&1; then
            WSL_DISTRO="kali-linux"
        else
            echo "ERROR: No compatible WSL distribution found (Ubuntu-24.04, Ubuntu, or kali-linux)."
            echo "       Install one with: wsl --install -d Ubuntu-24.04"
            exit 1
        fi
    fi
    echo "Launching WSL ($WSL_DISTRO) build..."
    echo ""
    wsl.exe -d "$WSL_DISTRO" -u root -- \
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
    ISO_NAME="TelcoChisel-${ISO_VERSION}-amd64.iso"
    ISO="$SCRIPT_DIR/$ISO_NAME"
    if [ ! -f "$ISO" ]; then
        ISO="$SCRIPT_DIR/TelcoChisel-live.iso"
    fi
    if [ -f "$ISO" ]; then
        SIZE=$(du -mL "$ISO" 2>/dev/null | cut -f1 || du -m "$ISO" 2>/dev/null | cut -f1 || echo 0)
        echo "  ISO: $ISO (${SIZE} MB)"
    fi
else
    echo "  Build FAILED (exit $EXIT_CODE) after ${MIN}m ${SEC}s"
    exit "$EXIT_CODE"
fi
