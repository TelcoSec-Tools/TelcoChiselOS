#!/bin/bash
set -eo pipefail

# ─── Argument parsing ─────────────────────────────────────────────────────────
RESUME=false
RESUME_FROM=0
PACK_ONLY=false

# ─── Build tuning (override via env) ──────────────────────────────────────────
# SQUASHFS_LEVEL: zstd compression level (1-15). 3=fast/CI, 6=balanced, 15=max.
SQUASHFS_LEVEL="${SQUASHFS_LEVEL:-6}"
# USE_CCACHE=1: bind-mount host ccache into chroot; speeds up repeated C++ builds.
USE_CCACHE="${USE_CCACHE:-0}"
CCACHE_DIR_HOST="${CCACHE_DIR:-/root/.ccache}"
# APT_PROXY: apt-cacher-ng proxy URL, e.g. http://localhost:3142
APT_PROXY="${APT_PROXY:-}"

for arg in "$@"; do
  case "$arg" in
    --resume)
      RESUME=true
      ;;
    --resume-from=*)
      RESUME=true
      RESUME_FROM="${arg#--resume-from=}"
      # Strip leading zeros for numeric comparison, keep at least "0"
      RESUME_FROM=$(( 10#${RESUME_FROM} ))
      ;;
    --pack-only)
      PACK_ONLY=true
      ;;
    --help|-h)
      cat << 'HELP'
Usage: sudo ./build-iso.sh [OPTIONS]

  (no options)           Full clean build — wipes chroot and starts fresh
  --resume               Keep existing chroot; re-run all provisioning phases
  --resume-from=N        Keep existing chroot; skip phases before N
                           e.g. --resume-from=03  resumes from phase 03
                           e.g. --resume-from=7   resumes from phase 07
  --pack-only            Skip provisioning entirely; pack existing chroot into
                           squashfs + ISO (useful for re-signing or re-branding)

Examples:
  sudo ./build-iso.sh                    # fresh full build
  sudo ./build-iso.sh --resume           # re-run everything on existing chroot
  sudo ./build-iso.sh --resume-from=04   # skip 00-03, resume from 04 onward
  sudo ./build-iso.sh --pack-only        # just repack squashfs → ISO

HELP
      exit 0
      ;;
    *)
      echo "ERROR: Unknown option: $arg  (try --help)"
      exit 1
      ;;
  esac
done

# ─── Header ───────────────────────────────────────────────────────────────────
echo "=== TelcoChisel ISO Builder ==="
if $PACK_ONLY; then
  echo "    Mode: pack-only (repack existing chroot)"
elif $RESUME && [ "$RESUME_FROM" -gt 0 ]; then
  echo "    Mode: resume from phase $(printf '%02d' $RESUME_FROM)"
elif $RESUME; then
  echo "    Mode: resume (keep chroot, re-run all phases)"
else
  echo "    Mode: full clean build"
fi
BUILD_START=$(date +%s)

# ─── Root check ───────────────────────────────────────────────────────────────
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Run as root (sudo ./build-iso.sh)"
  exit 1
fi

# ─── Prerequisite check ───────────────────────────────────────────────────────
echo "--> Checking prerequisites..."
MISSING=()
for tool in debootstrap mksquashfs grub-mkrescue xorriso mformat; do
  command -v "$tool" >/dev/null 2>&1 || MISSING+=("$tool")
done
if [ ${#MISSING[@]} -gt 0 ]; then
  echo "ERROR: Missing required tools: ${MISSING[*]}"
  echo "Install with: apt-get install debootstrap squashfs-tools grub-pc-bin grub-efi-amd64-bin xorriso mtools"
  exit 1
fi

# ─── Work directory ───────────────────────────────────────────────────────────
# 9p/drvfs/NTFS mounts don't support POSIX special files needed by debootstrap.
FS_TYPE=$(df -T . | awk 'NR==2 {print $2}')
if [[ "$FS_TYPE" =~ ^(9p|drvfs|vboxsf|fuse|cifs|nfs|vfat|ntfs|msdos)$ ]]; then
  echo "--> Non-POSIX filesystem ($FS_TYPE) — redirecting build to /var/tmp/live-iso-work"
  WORKDIR="/var/tmp/live-iso-work"
else
  WORKDIR="live-iso-work"
fi

ROOTFS="$WORKDIR/chroot"
IMAGE_NAME="TelcoChisel-live.iso"

# ─── Mount cleanup ────────────────────────────────────────────────────────────
cleanup() {
  rm -f "$ROOTFS/usr/sbin/policy-rc.d" "$ROOTFS/usr/local/sbin/udevadm" 2>/dev/null || true
  if [ -d "$ROOTFS" ] && chroot "$ROOTFS" dpkg-divert --list /usr/bin/udevadm 2>/dev/null | grep -q "diversion of"; then
    rm -f "$ROOTFS/usr/bin/udevadm" 2>/dev/null || true
    chroot "$ROOTFS" dpkg-divert --local --rename --remove /usr/bin/udevadm 2>/dev/null || true
  fi
  umount -lf "$ROOTFS/root/.ccache" 2>/dev/null || true
  umount -lf "$ROOTFS/dev/pts" 2>/dev/null || true
  umount -lf "$ROOTFS/dev"     2>/dev/null || true
  umount -lf "$ROOTFS/sys"     2>/dev/null || true
  umount -lf "$ROOTFS/proc"    2>/dev/null || true
}
trap cleanup EXIT

# ─── Chroot setup ─────────────────────────────────────────────────────────────
if $PACK_ONLY; then
  # ── pack-only: existing chroot must exist ───────────────────────────────────
  if [ ! -d "$ROOTFS" ]; then
    echo "ERROR: --pack-only requires an existing chroot at $ROOTFS"
    echo "       Run without flags to create one first."
    exit 1
  fi
  echo "--> Using existing chroot at $ROOTFS (pack-only mode)"

elif $RESUME; then
  # ── resume: keep existing chroot ────────────────────────────────────────────
  if [ ! -d "$ROOTFS" ]; then
    echo "ERROR: --resume requires an existing chroot at $ROOTFS"
    echo "       Run without flags to create one first."
    exit 1
  fi
  echo "--> Resuming with existing chroot at $ROOTFS"

  # Tear down any lingering mounts from a previous interrupted run
  cleanup

  # ── Re-apply service suppression (removed at end of each run) ───────────────
  echo "--> Re-applying chroot service suppression..."
  cat > "$ROOTFS/usr/sbin/policy-rc.d" << 'POLICY'
#!/bin/sh
exit 101
POLICY
  chmod +x "$ROOTFS/usr/sbin/policy-rc.d"

  chroot "$ROOTFS" dpkg-divert --local --rename --add /usr/bin/udevadm 2>/dev/null || true
  cat > "$ROOTFS/usr/bin/udevadm" << 'UDEVADM'
#!/bin/sh
exit 0
UDEVADM
  chmod +x "$ROOTFS/usr/bin/udevadm"
  mkdir -p "$ROOTFS/usr/local/sbin"
  cp "$ROOTFS/usr/bin/udevadm" "$ROOTFS/usr/local/sbin/udevadm"

  # Re-copy builder assets (scripts may have changed since last run)
  echo "--> Re-syncing builder assets into chroot..."
  rm -rf "$ROOTFS/tmp/scripts" && cp -r builder/scripts "$ROOTFS/tmp/scripts"
  rm -rf "$ROOTFS/tmp/calamares-config" && cp -r builder/calamares "$ROOTFS/tmp/calamares-config"
  rm -rf "$ROOTFS/tmp/docs" && cp -r builder/docs "$ROOTFS/tmp/docs"
  rm -rf "$ROOTFS/tmp/udev" && cp -r builder/udev "$ROOTFS/tmp/udev"
  rm -rf "$ROOTFS/tmp/security" && cp -r builder/security "$ROOTFS/tmp/security"
  rm -rf "$ROOTFS/tmp/menu" && cp -r builder/menu "$ROOTFS/tmp/menu"
  rm -rf "$ROOTFS/tmp/wireshark" && cp -r builder/wireshark "$ROOTFS/tmp/wireshark"
  rm -rf "$ROOTFS/tmp/boot" && cp -r builder/boot "$ROOTFS/tmp/boot"
  rm -rf "$ROOTFS/tmp/wordlists" && cp -r builder/wordlists "$ROOTFS/tmp/wordlists"

  # Re-mount virtual filesystems
  echo "--> Mounting virtual filesystems..."
  mkdir -p "$ROOTFS/proc" "$ROOTFS/sys" "$ROOTFS/dev"
  mount -t proc  /proc "$ROOTFS/proc"
  mount -t sysfs /sys  "$ROOTFS/sys"
  mount --bind   /dev  "$ROOTFS/dev"
  mount --bind   /dev/pts "$ROOTFS/dev/pts"

else
  # ── Full clean build ─────────────────────────────────────────────────────────
  cleanup  # clear any leftover mounts from a previous run

  if [ -d "$ROOTFS" ]; then
    echo "--> Removing old chroot..."
    rm -rf "$ROOTFS"
  fi
  mkdir -p "$ROOTFS"

  # Debootstrap
  echo "--> Bootstrapping Ubuntu 24.04 Noble..."
  debootstrap \
    --arch=amd64 \
    --include=ca-certificates,locales \
    noble "$ROOTFS" http://archive.ubuntu.com/ubuntu/

  # APT sources
  echo "--> Configuring APT sources..."
  cat > "$ROOTFS/etc/apt/sources.list" << 'SOURCES'
deb http://archive.ubuntu.com/ubuntu noble           main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates   main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu noble-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
SOURCES

  # Basic chroot environment
  echo "--> Preparing chroot environment..."
  echo "TelcoChisel" > "$ROOTFS/etc/hostname"
  cat > "$ROOTFS/etc/hosts" << 'HOSTS'
127.0.0.1   localhost
127.0.1.1   TelcoChisel
::1         localhost ip6-localhost ip6-loopback
HOSTS
  cp /etc/resolv.conf "$ROOTFS/etc/resolv.conf" 2>/dev/null || true

  # Locale generation
  # debootstrap includes the locales package but doesn't generate any locale
  # files. Package postinstalls (kismet, etc.) fail with "Cannot set LC_ALL"
  # until at least one locale exists.
  echo "en_US.UTF-8 UTF-8" > "$ROOTFS/etc/locale.gen"
  chroot "$ROOTFS" locale-gen
  chroot "$ROOTFS" update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 LC_CTYPE=en_US.UTF-8

  # Chroot service suppression
  # Hardware package postinstalls call udevadm/invoke-rc.d which fail inside
  # a chroot. Suppress them for the entire provisioning phase.
  cat > "$ROOTFS/usr/sbin/policy-rc.d" << 'POLICY'
#!/bin/sh
exit 101
POLICY
  chmod +x "$ROOTFS/usr/sbin/policy-rc.d"

  # Use dpkg-divert so the no-op at /usr/bin/udevadm survives udev package
  # installation. Hardware postinstalls call udevadm via absolute path.
  mkdir -p "$ROOTFS/usr/bin"
  chroot "$ROOTFS" dpkg-divert --local --rename --add /usr/bin/udevadm 2>/dev/null || true
  cat > "$ROOTFS/usr/bin/udevadm" << 'UDEVADM'
#!/bin/sh
exit 0
UDEVADM
  chmod +x "$ROOTFS/usr/bin/udevadm"
  mkdir -p "$ROOTFS/usr/local/sbin"
  cp "$ROOTFS/usr/bin/udevadm" "$ROOTFS/usr/local/sbin/udevadm"

  # Copy builder assets
  echo "--> Copying builder assets..."
  cp -r builder/scripts   "$ROOTFS/tmp/scripts"
  cp -r builder/calamares "$ROOTFS/tmp/calamares-config"
  cp -r builder/docs      "$ROOTFS/tmp/docs"
  cp -r builder/udev      "$ROOTFS/tmp/udev"
  cp -r builder/security  "$ROOTFS/tmp/security"
  cp -r builder/menu      "$ROOTFS/tmp/menu"
  cp -r builder/wireshark "$ROOTFS/tmp/wireshark"
  cp -r builder/boot      "$ROOTFS/tmp/boot"
  cp -r builder/wordlists "$ROOTFS/tmp/wordlists"

  # Mount virtual filesystems
  echo "--> Mounting virtual filesystems..."
  mkdir -p "$ROOTFS/proc" "$ROOTFS/sys" "$ROOTFS/dev"
  mount -t proc  /proc "$ROOTFS/proc"
  mount -t sysfs /sys  "$ROOTFS/sys"
  mount --bind   /dev  "$ROOTFS/dev"
  mount --bind   /dev/pts "$ROOTFS/dev/pts"
fi

# ─── Provisioning ─────────────────────────────────────────────────────────────
if ! $PACK_ONLY; then
  echo "--> Running provisioning scripts..."

  # ── APT proxy (apt-cacher-ng) ────────────────────────────────────────────────
  if [ -n "$APT_PROXY" ]; then
    echo "Acquire::http::Proxy \"$APT_PROXY\";" > "$ROOTFS/etc/apt/apt.conf.d/00proxy"
    echo "--> APT proxy: $APT_PROXY"
  fi

  # ── ccache: inject via PATH so all gcc/g++ calls go through ccache wrappers ──
  # /usr/lib/ccache/ contains symlinks: gcc→ccache, g++→ccache, clang→ccache, etc.
  # No cmake flag changes needed — any compiler invocation is transparently cached.
  CHROOT_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
  if [ "${USE_CCACHE:-0}" = "1" ]; then
    mkdir -p "$CCACHE_DIR_HOST" "$ROOTFS/root/.ccache"
    mount --bind "$CCACHE_DIR_HOST" "$ROOTFS/root/.ccache"
    CHROOT_PATH="/usr/lib/ccache:$CHROOT_PATH"
    echo "--> ccache enabled (cache dir: $CCACHE_DIR_HOST)"
  fi

  _phase() {
    local num="$1"; local label="$2"; shift 2
    if $RESUME && [ "$num" -lt "$RESUME_FROM" ]; then
      printf '\n┌─ %-50s [skipped]\n' "$label"
      return 0
    fi
    local t0; t0=$(date +%s)
    printf '\n┌─ %-50s\n' "$label"
    "$@"
    printf '└─ done in %dm%02ds\n' \
      $(( ($(date +%s)-t0) / 60 )) $(( ($(date +%s)-t0) % 60 ))
  }

  chroot_run() {
    chroot "$ROOTFS" env \
      PATH="$CHROOT_PATH" \
      CCACHE_DIR=/root/.ccache \
      /bin/bash -e "/tmp/scripts/$1"
  }

  _phase  0 "00 · Consolidated package install"    chroot "$ROOTFS" /bin/bash -e /tmp/scripts/00-install-all-packages.sh
  _phase  1 "01 · Base system + desktop"           chroot_run 01-install-base.sh
  _phase  2 "02 · SDR drivers + conda env"         chroot_run 02-install-sdr.sh
  _phase  3 "03 · Core network (srsRAN/Open5GS)"   chroot_run 03-install-core-network.sh
  _phase  4 "04 · Security tools"                  chroot_run 04-install-tools.sh
  _phase  5 "06 · UE analysis + baseband"          chroot_run 06-install-ue-analysis.sh
  _phase  6 "05 · Desktop customization"           chroot_run 05-desktop-customization.sh
  _phase  7 "07 · Calamares installer"             chroot_run 07-install-installer.sh
  _phase  8 "08 · System optimization"             chroot_run 08-system-optimization.sh
  _phase  9 "09 · 5Ghoul helpers"                  chroot_run 09-install-5ghoul.sh
  _phase 10 "10 · Advanced telecom tools"          chroot_run 10-install-telecom-advanced.sh
  _phase 11 "11 · Device flash tools"              chroot_run 11-install-device-tools.sh

  # Remove chroot service suppression
  rm -f "$ROOTFS/usr/sbin/policy-rc.d" "$ROOTFS/usr/local/sbin/udevadm"
  if chroot "$ROOTFS" dpkg-divert --list /usr/bin/udevadm 2>/dev/null | grep -q "diversion of"; then
    rm -f "$ROOTFS/usr/bin/udevadm"
    chroot "$ROOTFS" dpkg-divert --local --rename --remove /usr/bin/udevadm 2>/dev/null || true
  fi

  # ── Live-boot fixups ───────────────────────────────────────────────────────
  # casper.conf: sourced by casper initramfs hooks — must use 'export' syntax so
  # child processes (lightdm, adduser hooks) inherit the variables.
  cat > "$ROOTFS/etc/casper.conf" << 'CASPER_CONF'
export USERNAME=telcosec
export USERFULLNAME="TelcoSec Researcher"
export HOST=TelcoChisel
export BUILD_SYSTEM=Ubuntu
export FLAVOUR=ubuntu
CASPER_CONF

  # Ensure casper is selected as the initramfs BOOT method.
  # The casper package postinstall normally writes this, but a chroot postinstall
  # failure would silently leave BOOT=local, causing the initramfs to skip all
  # casper premount/bottom scripts and never find filesystem.squashfs.
  mkdir -p "$ROOTFS/etc/initramfs-tools/conf.d"
  echo "BOOT=casper" > "$ROOTFS/etc/initramfs-tools/conf.d/casper-boot"

  # Force essential live-boot kernel modules into the initramfs.
  # overlay is required by casper for the writable tmpfs layer.
  # Use a sentinel to avoid duplicate entries on --resume builds.
  if ! grep -q "^# telcosec-modules" "$ROOTFS/etc/initramfs-tools/modules" 2>/dev/null; then
    cat >> "$ROOTFS/etc/initramfs-tools/modules" << 'MODULES_EOF'
# telcosec-modules
overlay
isofs
squashfs
loop
cdrom
sr_mod
ata_piix
ahci
xhci_pci
ehci_pci
uhci_hcd
usb_storage
uas
vfat
fat
nls_cp437
nls_iso8859_1
nls_utf8
MODULES_EOF
  fi

  # Reinstall casper to ensure initramfs hooks are fully present after all the
  # provisioning apt transactions (some transactions may have left hooks stale).
  echo "--> Reinstalling casper to refresh initramfs hooks..."
  chroot "$ROOTFS" env DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --reinstall casper 2>&1 | tail -3 || true

  # Add blkid to the initramfs explicitly. casper's get_fstype() calls blkid to
  # identify block device filesystems; if blkid is absent the scan silently
  # skips all devices, producing "Unable to find a medium". blkid is in
  # util-linux which may not be pulled into the initramfs by default hooks.
  cat > "$ROOTFS/etc/initramfs-tools/hooks/blkid-for-casper" << 'BLKID_HOOK'
#!/bin/sh
PREREQ=""
prereqs() { echo "$PREREQ"; }
case $1 in prereqs) prereqs; exit 0;; esac
. /usr/share/initramfs-tools/hook-functions
copy_exec /sbin/blkid /sbin
copy_exec /usr/sbin/blkid /sbin 2>/dev/null || true
# util-linux blkid depends on libblkid
for lib in /lib/x86_64-linux-gnu/libblkid.so.* /usr/lib/x86_64-linux-gnu/libblkid.so.*; do
    [ -f "$lib" ] && copy_exec "$lib" || true
done
BLKID_HOOK
  chmod +x "$ROOTFS/etc/initramfs-tools/hooks/blkid-for-casper"

  # Ensure overlay.ko is physically present in the initramfs. casper checks
  # /proc/filesystems for 'overlay' before mounting the CoW layer; if the
  # module isn't loaded at that point it prints "/cow format specified as
  # 'overlay' and no support found" and drops to a shell. manual_add_modules
  # copies the module + all its firmware/deps into the cpio archive.
  cat > "$ROOTFS/etc/initramfs-tools/hooks/overlay-for-casper" << 'OVERLAY_HOOK'
#!/bin/sh
PREREQ=""
prereqs() { echo "$PREREQ"; }
case $1 in prereqs) prereqs; exit 0;; esac
. /usr/share/initramfs-tools/hook-functions
manual_add_modules overlay
OVERLAY_HOOK
  chmod +x "$ROOTFS/etc/initramfs-tools/hooks/overlay-for-casper"

  # casper-premount script: load overlay before casper's main body checks
  # /proc/filesystems. Scripts in casper-premount/ run just before casper
  # attempts to mount the CoW filesystem. Numbered 00- so it runs first.
  mkdir -p "$ROOTFS/etc/initramfs-tools/scripts/casper-premount"
  cat > "$ROOTFS/etc/initramfs-tools/scripts/casper-premount/00-load-overlay" << 'OVERLAY_PREMOUNT'
#!/bin/sh
PREREQ=""
prereqs() { echo "$PREREQ"; }
case $1 in prereqs) prereqs; exit 0;; esac
modprobe overlay 2>/dev/null || true
OVERLAY_PREMOUNT
  chmod +x "$ROOTFS/etc/initramfs-tools/scripts/casper-premount/00-load-overlay"

  echo "--> Regenerating initrd (BOOT=casper, all hooks)..."
  chroot "$ROOTFS" update-initramfs -u -k all 2>&1
  echo "--> initrd regeneration complete."

  # Cleanup inside chroot to reduce squashfs size
  echo ""
  echo "--> Cleaning up chroot..."
  chroot "$ROOTFS" /bin/bash -e << 'CLEANUP'
export DEBIAN_FRONTEND=noninteractive
apt-get autoremove -y
apt-get clean
rm -rf /var/lib/apt/lists/*
rm -rf /root/.cache/pip /home/telcosec/.cache/pip

# ── Conda cleanup ──────────────────────────────────────────────────────────
if [ -x /opt/telcosec/miniconda/bin/conda ]; then
  /opt/telcosec/miniconda/bin/conda clean -afy || true
fi
# Remove conda package cache and tarballs (pkgs/ is the biggest hidden cost)
rm -rf /opt/telcosec/miniconda/pkgs/ 2>/dev/null || true

# ── Git history (no runtime value) ────────────────────────────────────────
find /opt/telcosec     -name '.git'       -type d -exec rm -rf {} + 2>/dev/null || true

# ── CMake / Meson build directories ────────────────────────────────────────
# build/ dirs under /opt/telcosec can be 500-700 MB of object files + CMakeFiles
find /opt/telcosec -type d -name 'build'      -exec rm -rf {} + 2>/dev/null || true
find /opt/telcosec -type d -name '_build'     -exec rm -rf {} + 2>/dev/null || true
find /opt/telcosec -type d -name 'CMakeFiles' -exec rm -rf {} + 2>/dev/null || true
find /opt/telcosec -type f -name 'CMakeCache.txt' -delete 2>/dev/null || true
find /opt/telcosec -type f -name '*.o'        -delete 2>/dev/null || true
find /opt/telcosec -type f -name '*.a'        -delete 2>/dev/null || true

# ── Python caches and build artifacts ─────────────────────────────────────
find /opt/telcosec /usr/local/lib /root /home -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true
find /opt/telcosec /usr/local/lib /root /home -type d -name '*.egg-info'  -exec rm -rf {} + 2>/dev/null || true
find /opt/telcosec /usr/local/lib /root /home -type d -name '*.dist-info' -prune -o -type f \( -name '*.pyc' -o -name '*.pyo' \) -print -delete 2>/dev/null || true

# ── Java/Maven local repository (~250 MB) ─────────────────────────────────
rm -rf /root/.m2 /home/telcosec/.m2 2>/dev/null || true

# ── Cross-compiler sysroots and debug libraries ────────────────────────────
# arm-none-eabi and mipsel headers/specs not needed at runtime (~200 MB)
find /usr/lib/gcc-cross -name '*.o' -delete 2>/dev/null || true
rm -rf /usr/arm-none-eabi/lib/*.a /usr/mipsel-linux-gnu/lib/*.a 2>/dev/null || true

# ── Locale trimming (~80 MB) ──────────────────────────────────────────────
find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en' ! -name 'en_US' ! -name 'locale.alias' -exec rm -rf {} + 2>/dev/null || true
find /usr/share/i18n/locales -mindepth 1 ! -name 'en_US' ! -name 'en_GB' -delete 2>/dev/null || true

# ── Man pages and docs (except telcosec) ─────────────────────────────────
find /usr/share/doc -mindepth 1 -maxdepth 1 ! -name 'telcosec' -exec rm -rf {} +
rm -rf /usr/share/man/*
rm -rf /usr/share/groff /usr/share/info 2>/dev/null || true

# ── Logs and temp ─────────────────────────────────────────────────────────
find /var/log -type f \( -name '*.log' -o -name '*.gz' \) -delete 2>/dev/null || true
rm -rf /tmp/scripts /tmp/calamares-config /tmp/docs
rm -rf /tmp/udev /tmp/security /tmp/menu /tmp/wireshark /tmp/boot
rm -rf /tmp/wordlists
rm -f  /tmp/.packages-installed
rm -rf /tmp/*
CLEANUP
fi

# ─── Unmount before packing ───────────────────────────────────────────────────
cleanup
trap - EXIT

# ─── Squashfs ─────────────────────────────────────────────────────────────────
mkdir -p "$WORKDIR/image/casper"
echo "--> Packing filesystem into squashfs (zstd-${SQUASHFS_LEVEL})..."
mksquashfs "$ROOTFS" "$WORKDIR/image/casper/filesystem.squashfs" \
  -comp zstd -Xcompression-level "${SQUASHFS_LEVEL}" \
  -b 1M \
  -processors 4 -mem 4G \
  -no-exports \
  -noappend

# filesystem.size — casper/live-boot uses this for install size estimation
printf '%s' "$(du -sx --block-size=1 "$ROOTFS" | cut -f1)" \
  > "$WORKDIR/image/casper/filesystem.size"

# filesystem.manifest — package list used by casper to validate the medium
# and by the installer to compute what to remove from the installed system.
chroot "$ROOTFS" dpkg-query -W --showformat='${Package}\t${Version}\n' \
  > "$WORKDIR/image/casper/filesystem.manifest" 2>/dev/null || true

# ─── Create .disk/info required by Ubuntu casper ─────────────
mkdir -p "$WORKDIR/image/.disk"
echo "TelcoChisel Live CD" > "$WORKDIR/image/.disk/info"
touch "$WORKDIR/image/.disk/base_installable"

# ─── Kernel + initrd ──────────────────────────────────────────────────────────
echo "--> Copying kernel and initrd..."
vmlinuz=$(find "$ROOTFS/boot/" -name "vmlinuz-*"   -type f | sort -V | tail -1)
initrd=$(find  "$ROOTFS/boot/" -name "initrd.img-*" -type f | sort -V | tail -1)
if [ -z "$vmlinuz" ] || [ -z "$initrd" ]; then
  echo "ERROR: kernel or initrd not found in $ROOTFS/boot/"
  exit 1
fi
cp "$vmlinuz" "$WORKDIR/image/casper/vmlinuz"
cp "$initrd"  "$WORKDIR/image/casper/initrd"

# ─── GRUB config ──────────────────────────────────────────────────────────────
echo "--> Generating GRUB boot menu..."
mkdir -p "$WORKDIR/image/boot/grub"
# Copy branding logo for GRUB background
if [ -f "builder/boot/grub_background.png" ]; then
  cp "builder/boot/grub_background.png" "$WORKDIR/image/boot/grub/logo.png"
elif [ -f "$ROOTFS/usr/share/backgrounds/telcosec/logo.png" ]; then
  cp "$ROOTFS/usr/share/backgrounds/telcosec/logo.png" "$WORKDIR/image/boot/grub/logo.png"
fi
cat > "$WORKDIR/image/boot/grub/grub.cfg" << 'GRUB'
set default=0
set timeout=15

insmod all_video
insmod font
if loadfont /boot/grub/fonts/unicode.pf2 ; then
  set gfxmode=auto
  insmod gfxterm
  insmod png
  terminal_output gfxterm
  if background_image /boot/grub/logo.png ; then
    set color_normal=light-gray/black
    set color_highlight=cyan/black
  fi
fi

# Ubuntu 24.04 casper: boot=casper activates the live-boot scripts.
# username/hostname are set here so casper's 10adduser hook picks them up.
# noeject/noprompt: suppress casper's "remove disc and press enter" prompts.
# Do NOT include: live-media-path (default /casper is correct),
#   cdrom-detect/try-usb (debian-installer only), user-fullname (space issues).

menuentry "TelcoChisel Live (Try without installing)" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper noeject noprompt username=telcosec hostname=TelcoChisel live-media=/dev/sr0 live-media-path=/casper quiet splash ---
    initrd /casper/initrd
}

menuentry "TelcoChisel Live (Install)" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper noeject noprompt username=telcosec hostname=TelcoChisel live-media=/dev/sr0 live-media-path=/casper only-ubiquity quiet splash ---
    initrd /casper/initrd
}

menuentry "TelcoChisel Live (Safe Graphics)" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper noeject noprompt username=telcosec hostname=TelcoChisel live-media=/dev/sr0 live-media-path=/casper nomodeset ---
    initrd /casper/initrd
}

menuentry "TelcoChisel Live (Debug — verbose boot)" {
    set gfxpayload=keep
    linux /casper/vmlinuz boot=casper noeject noprompt username=telcosec hostname=TelcoChisel live-media=/dev/sr0 live-media-path=/casper debug systemd.log_level=debug
    initrd /casper/initrd
}
GRUB

# ─── Build ISO ────────────────────────────────────────────────────────────────
echo "--> Building ISO with grub-mkrescue..."
# grub-mkrescue pipes args to xorriso via its own "--" (interpreter/stdin mode).
# In that context "-iso-level 3" is not a recognized interpreter command, only a
# command-line flag. Intercept xorriso via PATH and inject the flag right after
# "-as mkisofs" before xorriso sees any content args.
mkdir -p /tmp/xorriso-wrap
cat > /tmp/xorriso-wrap/xorriso << 'XWRAP'
#!/bin/bash
args=("$@")
for i in "${!args[@]}"; do
  if [ "${args[$i]}" = "mkisofs" ] && [ "${args[$((i-1))]:-}" = "-as" ]; then
    args=("${args[@]:0:$((i+1))}" "-iso-level" "3" "${args[@]:$((i+1))}")
    break
  fi
done
exec /usr/bin/xorriso "${args[@]}"
XWRAP
chmod +x /tmp/xorriso-wrap/xorriso
PATH="/tmp/xorriso-wrap:$PATH" grub-mkrescue -o "$IMAGE_NAME" "$WORKDIR/image/"

# ─── ISO integrity check ──────────────────────────────────────────────────────
# Verify that filesystem.squashfs is accessible inside the ISO (not just present
# in the source tree). If the ISO was built without Level 3 support, the
# squashfs directory entry would be truncated and casper would fail at boot.
echo "--> Verifying ISO integrity (squashfs accessible inside ISO)..."
ISO_CHECK_DIR=$(mktemp -d)
if mount -o loop,ro "$IMAGE_NAME" "$ISO_CHECK_DIR" 2>/dev/null; then
  SQUASHFS_SIZE=$(stat -c '%s' "$ISO_CHECK_DIR/casper/filesystem.squashfs" 2>/dev/null || echo 0)
  if [ "$SQUASHFS_SIZE" -gt 0 ]; then
    printf '    filesystem.squashfs visible inside ISO: %s bytes ✓\n' "$SQUASHFS_SIZE"
  else
    echo "    ERROR: filesystem.squashfs NOT accessible inside ISO — Level 3 may have failed!"
  fi
  # Verify casper init scripts are in the initrd
  INITRD_FILE="$ISO_CHECK_DIR/casper/initrd"
  if file "$INITRD_FILE" 2>/dev/null | grep -q "gzip\|cpio\|Zstandard"; then
    echo "    initrd present and appears valid ✓"
  fi
  umount "$ISO_CHECK_DIR" 2>/dev/null || true
else
  echo "    WARNING: Could not loop-mount ISO to verify (non-fatal)"
fi
rmdir "$ISO_CHECK_DIR" 2>/dev/null || true

# ─── Summary ──────────────────────────────────────────────────────────────────
ELAPSED=$(( $(date +%s) - BUILD_START ))
ISO_SIZE=$(du -sh "$IMAGE_NAME" | cut -f1)
printf '\n╔══════════════════════════════════════════════════════╗\n'
printf '║  %-52s║\n' "Build complete: $IMAGE_NAME"
printf '║  %-52s║\n' "ISO size:       $ISO_SIZE"
printf '║  %-52s║\n' "Total time:     $(( ELAPSED/60 ))m$(( ELAPSED%60 ))s"
printf '╚══════════════════════════════════════════════════════╝\n'
