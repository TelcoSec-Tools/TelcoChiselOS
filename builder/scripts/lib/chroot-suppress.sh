# shellcheck shell=bash
# =============================================================================
# chroot-suppress.sh — shared chroot service/udevadm suppression
#
# Hardware package postinstalls call udevadm/invoke-rc.d, which fail inside a
# chroot (no udev socket, no running init). Suppress them for the duration of
# the package-install phase so dpkg doesn't abort on packages like librtlsdr2,
# libhackrf0, etc.
#
# Two call sites, two variants:
#   suppress_chroot_services <rootfs>      — host side (build-iso.sh), writes
#                                            into the chroot tree directly
#   suppress_chroot_services_inplace       — inside the chroot (00-install-
#                                            all-packages.sh), also diverts
#                                            the /sbin and /bin udevadm paths
#   restore_chroot_services_inplace        — inside the chroot (00), removes
#                                            the suppression before the ISO
#                                            is packed
# =============================================================================

suppress_chroot_services() {
  local rootfs="$1"
  mkdir -p "$rootfs/usr/sbin" "$rootfs/usr/bin" "$rootfs/usr/local/sbin"
  cat > "$rootfs/usr/sbin/policy-rc.d" << 'POLICY'
#!/bin/sh
exit 101
POLICY
  chmod +x "$rootfs/usr/sbin/policy-rc.d"

  # Use dpkg-divert so the no-op at /usr/bin/udevadm survives udev package
  # installation. Hardware postinstalls call udevadm via absolute path.
  chroot "$rootfs" dpkg-divert --local --rename --add /usr/bin/udevadm 2>/dev/null || true
  cat > "$rootfs/usr/bin/udevadm" << 'UDEVADM'
#!/bin/sh
exit 0
UDEVADM
  chmod +x "$rootfs/usr/bin/udevadm"
  cp "$rootfs/usr/bin/udevadm" "$rootfs/usr/local/sbin/udevadm"
}

restore_chroot_services() {
  local rootfs="$1"
  rm -f "$rootfs/usr/sbin/policy-rc.d" "$rootfs/usr/local/sbin/udevadm" 2>/dev/null || true
  if [ -d "$rootfs" ] && chroot "$rootfs" dpkg-divert --list /usr/bin/udevadm 2>/dev/null | grep -q "diversion of"; then
    rm -f "$rootfs/usr/bin/udevadm" 2>/dev/null || true
    chroot "$rootfs" dpkg-divert --local --rename --remove /usr/bin/udevadm 2>/dev/null || true
  fi
}

suppress_chroot_services_inplace() {
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
}

restore_chroot_services_inplace() {
  rm -f /usr/sbin/policy-rc.d /usr/local/sbin/udevadm \
        /usr/bin/udevadm /sbin/udevadm /bin/udevadm
  local p
  for p in /usr/bin/udevadm /sbin/udevadm /bin/udevadm; do
    if dpkg-divert --list "$p" 2>/dev/null | grep -q "diversion of"; then
      dpkg-divert --local --rename --remove "$p" 2>/dev/null || true
    fi
  done
}
