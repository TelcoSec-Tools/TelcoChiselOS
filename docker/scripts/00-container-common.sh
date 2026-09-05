#!/bin/bash
# =============================================================================
# docker/scripts/00-container-common.sh — shared setup for all TelcoChisel
# container images.
#
# Mirrors the chroot service-suppression trick from
# builder/scripts/00-install-all-packages.sh (policy-rc.d + udevadm/
# invoke-rc.d no-ops) — Docker builds hit the exact same problem the ISO
# chroot build does: hardware-package postinstalls (librtlsdr2, libhackrf0,
# wireshark-common, etc.) call udevadm/invoke-rc.d, which fail when there's
# no udev socket or running init. Unlike the chroot build, this suppression
# is never removed — a container never has a real udev/init to hand back to,
# so leaving the stubs in place permanently is correct here (see CLAUDE.md's
# "Chroot service suppression" note in build-iso.sh for the ISO-side
# equivalent, which DOES restore the real binaries before the image ships).
#
# Also provides filter_pkgs(), which strips ISO/desktop/systemd-only package
# names out of the arrays sourced from lib/packages.sh before any
# `apt-get install` — see docker/README.md "Package reuse boundary" for why
# these specific names are excluded from every container image.
#
# Usage: source this file first from any docker/scripts/*.sh, then call
# suppress_services (once, early) and filter_pkgs "${SOME_ARRAY[@]}".
# =============================================================================
set -e

export DEBIAN_FRONTEND=noninteractive

suppress_services() {
  cat > /usr/sbin/policy-rc.d << 'POLICY'
#!/bin/sh
exit 101
POLICY
  chmod +x /usr/sbin/policy-rc.d

  dpkg-divert --local --rename --add /usr/bin/udevadm 2>/dev/null || true
  dpkg-divert --local --rename --add /sbin/udevadm 2>/dev/null || true
  dpkg-divert --local --rename --add /bin/udevadm 2>/dev/null || true
  cat > /usr/bin/udevadm << 'UDEVADM'
#!/bin/sh
exit 0
UDEVADM
  chmod +x /usr/bin/udevadm
  cp /usr/bin/udevadm /sbin/udevadm 2>/dev/null || true
  cp /usr/bin/udevadm /bin/udevadm 2>/dev/null || true
  mkdir -p /usr/local/sbin
  cp /usr/bin/udevadm /usr/local/sbin/udevadm
  export PATH="/usr/local/sbin:$PATH"

  # Exclude docs, manpages, and info files to keep the container minimal
  mkdir -p /etc/dpkg/dpkg.cfg.d
  cat > /etc/dpkg/dpkg.cfg.d/01_nodoc << 'NODOC'
path-exclude /usr/share/doc/*
path-include /usr/share/doc/*/copyright
path-exclude /usr/share/man/*
path-exclude /usr/share/groff/*
path-exclude /usr/share/info/*
path-exclude /usr/share/lintian/*
path-exclude /usr/share/linda/*
NODOC
}

# Package names that only make sense for the live ISO / a desktop / a real
# kernel and init system. Stripped out of every PKGS_* array sourced from
# builder/scripts/lib/packages.sh before apt-get ever sees them. GUI tools
# that work under the optional X11-passthrough model (wireshark, gqrx,
# twinkle, baresip) are deliberately KEPT — see docker/README.md.
CONTAINER_PKG_BLOCKLIST=(
  casper initramfs-tools linux-image-generic
  grub-pc-bin grub-efi-amd64-bin shim-signed grub-efi-amd64-signed
  xfce4 xfce4-goodies lightdm thunar gnome-terminal xfce4-taskmanager
  xserver-xorg xserver-xorg-input-all network-manager-gnome terminator
  firefox open-vm-tools open-vm-tools-desktop
  yaru-theme-gtk yaru-theme-icon papirus-icon-theme
  ufw tuned
  calamares
  qml-module-qtquick-controls qml-module-qtquick-controls2
  qml-module-qtquick-dialogs qml-module-qtquick-layouts qml-module-qtquick-window2
  upower os-prober
  linphone-desktop
  docker.io docker-compose-v2
  network-manager-openvpn network-manager-openvpn-gnome
)

# filter_pkgs <pkg...> — prints every arg NOT in CONTAINER_PKG_BLOCKLIST,
# one per line. Intended use: mapfile -t FILTERED < <(filter_pkgs "${ARR[@]}")
filter_pkgs() {
  local pkg blocked
  for pkg in "$@"; do
    blocked=0
    for b in "${CONTAINER_PKG_BLOCKLIST[@]}"; do
      [ "$pkg" = "$b" ] && { blocked=1; break; }
    done
    [ "$blocked" -eq 0 ] && printf '%s\n' "$pkg"
  done
}

# git_clone_retry <git clone args...> — retries a clone up to 3 times.
# Container builds hit transient GitHub/network failures (DNS blips, a
# momentary 401/403 that git misreads as "needs auth" and tries to prompt
# via GIT_ASKPASS — fatal since GIT_ASKPASS=/bin/false is set repo-wide to
# avoid hangs, see the GIT_ASKPASS export near the top of each script that
# clones many repos). Fatal after 3 attempts, matching apt_retry — a tool
# whose source can't be fetched should fail the build loudly, not silently.
git_clone_retry() {
  local attempt
  for attempt in 1 2 3; do
    git clone "$@" && return 0
    echo "  git clone attempt ${attempt}/3 failed — retrying in 10s..." >&2
    sleep 10
  done
  echo "  ERROR: git clone failed after 3 attempts: git clone $*" >&2
  return 1
}

# apt_retry <apt-get args...> — retries a single apt-get invocation up to 3
# times, running `apt-get update` between attempts. Mirrors the philosophy of
# builder/scripts/lib/pip-retry.sh (transient Ubuntu-mirror failures —
# timeouts, "Hash Sum mismatch" on a stale mirror cache — are common on large
# combined `apt-get install` transactions and usually clear on a fresh
# `apt-get update`). UNLIKE pip_retry, this is fatal after 3 attempts: a
# missing base package should actually fail the container build, not be
# silently skipped.
apt_retry() {
  local attempt
  for attempt in 1 2 3; do
    apt-get "$@" && return 0
    echo "  apt-get attempt ${attempt}/3 failed — retrying after apt-get update..." >&2
    apt-get update -qq || true
    sleep 5
  done
  echo "  ERROR: apt-get failed after 3 attempts: apt-get $*" >&2
  return 1
}

# install_container_healthcheck — creates /usr/local/bin/container-healthcheck.sh
# for Docker and Kubernetes liveness/readiness probes.
install_container_healthcheck() {
  cat > /usr/local/bin/container-healthcheck.sh << 'HEALTHCHECK_EOF'
#!/bin/bash
# =============================================================================
# container-healthcheck.sh — runtime health probe for TelcoChisel containers
# =============================================================================
set -e

# 1. Essential environment & directories
[ -d "/opt/telcosec" ] || { echo "CRITICAL: /opt/telcosec missing" >&2; exit 1; }
[ -d "/tmp" ] || { echo "CRITICAL: /tmp missing" >&2; exit 1; }

# 2. Core binaries availability
command -v bash >/dev/null 2>&1 || { echo "CRITICAL: bash not found" >&2; exit 1; }

# 3. Dynamic tier-specific sanity check
# Base tools check
if command -v nmap >/dev/null 2>&1; then
  nmap --version >/dev/null 2>&1 || exit 1
fi
if command -v tshark >/dev/null 2>&1; then
  tshark --version >/dev/null 2>&1 || exit 1
fi

# SDR tier check
if command -v SoapySDRUtil >/dev/null 2>&1; then
  SoapySDRUtil --info >/dev/null 2>&1 || exit 1
fi

# Device-tools tier check
if command -v adb >/dev/null 2>&1; then
  adb version >/dev/null 2>&1 || exit 1
fi

# Core-network tier check
if [ -f /etc/telcosec/plmn.conf ]; then
  [ -s /etc/telcosec/plmn.conf ] || exit 1
fi

exit 0
HEALTHCHECK_EOF
  chmod 755 /usr/local/bin/container-healthcheck.sh
}

