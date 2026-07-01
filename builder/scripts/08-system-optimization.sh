#!/bin/bash
set -e

echo "=== Running TelcoSec Professional System Optimizations ==="

# 1. Hardware Access & Udev Rules
echo "Deploying hardware udev rules..."
sudo mkdir -p /etc/udev/rules.d/
if [ -f /tmp/udev/50-telcosec-hw.rules ]; then
  sudo cp /tmp/udev/50-telcosec-hw.rules /etc/udev/rules.d/
  sudo chmod 644 /etc/udev/rules.d/50-telcosec-hw.rules
fi

# 2. PAM Real-time Scheduling Priority Limits
echo "Deploying real-time limits and configuring groups..."
sudo mkdir -p /etc/security/limits.d/
if [ -f /tmp/security/99-realtime.conf ]; then
  sudo cp /tmp/security/99-realtime.conf /etc/security/limits.d/
  sudo chmod 644 /etc/security/limits.d/99-realtime.conf
fi
# Add the realtime group and add our users to it
sudo groupadd -r realtime || true
sudo usermod -aG realtime telcosec || true

# 3. Custom Desktop Menu & Tool Categories
echo "Deploying custom XFCE tool menus and categories..."
sudo rm -f /etc/xdg/menus/applications-merged/telcosec.menu
# Deploy XFCE applications menu (XFCE's menu system reads $XDG_MENU_PREFIX-applications.menu,
# i.e. xfce-applications.menu, via xfdesktop/xfce4-panel's whiskermenu/applicationsmenu plugins).
if [ -f /tmp/menu/xfce-applications.menu ]; then
  sudo mkdir -p /etc/xdg/menus
  sudo cp /tmp/menu/xfce-applications.menu /etc/xdg/menus/xfce-applications.menu
  sudo chmod 644 /etc/xdg/menus/xfce-applications.menu
fi

sudo mkdir -p /usr/share/desktop-directories/
if [ -d /tmp/menu/directories ]; then
  sudo cp -rf /tmp/menu/directories/. /usr/share/desktop-directories/
fi

sudo mkdir -p /usr/share/applications/
if [ -d /tmp/menu/applications ]; then
  sudo cp -rf /tmp/menu/applications/. /usr/share/applications/
  sudo chmod 644 /usr/share/applications/*.desktop || true
  sudo chmod +x /usr/share/applications/*.desktop || true
fi

# 4. Wireshark Dissector Profile & Plugins
echo "Configuring default Wireshark telecom profile, custom Lua plugins, and OpenAPI schemas..."
sudo mkdir -p /etc/skel/.config/wireshark/
if [ -f /tmp/wireshark/preferences ]; then
  # For future users created via Calamares
  sudo cp /tmp/wireshark/preferences /etc/skel/.config/wireshark/preferences
  # For the pre-created live user
  sudo mkdir -p /home/telcosec/.config/wireshark/
  sudo cp /tmp/wireshark/preferences /home/telcosec/.config/wireshark/preferences
  sudo chown -R telcosec:telcosec /home/telcosec/.config
fi

# Deploy custom Lua plugins system-wide
sudo mkdir -p /usr/share/wireshark/plugins/
if [ -d /tmp/wireshark/plugins ]; then
  sudo cp -rf /tmp/wireshark/plugins/. /usr/share/wireshark/plugins/
  sudo chmod 644 /usr/share/wireshark/plugins/*.lua || true
fi

# Create directory for 5G SBI OpenAPI YAML definitions
sudo mkdir -p /etc/wireshark/openapi/
sudo chmod 755 /etc/wireshark/openapi/

# 5. Boot Theme (GRUB & Plymouth Customization)
echo "Deploying custom boot styling (GRUB & Plymouth)..."
sudo mkdir -p /etc/default/grub.d/
if [ -f /tmp/boot/grub-theme.conf ]; then
  sudo cp /tmp/boot/grub-theme.conf /etc/default/grub.d/99-telcosec.cfg
  sudo chmod 644 /etc/default/grub.d/99-telcosec.cfg
fi

# Deploy the logo and wallpaper backgrounds
sudo mkdir -p /usr/share/backgrounds/telcosec/
if [ -f /tmp/calamares-config/branding/telcosec/logo.png ]; then
  sudo cp /tmp/calamares-config/branding/telcosec/logo.png /usr/share/backgrounds/telcosec/logo.png
fi
if [ -f /tmp/boot/wallpaper.jpg ]; then
  sudo cp /tmp/boot/wallpaper.jpg /usr/share/backgrounds/telcosec/wallpaper.jpg
elif [ -f /tmp/calamares-config/branding/telcosec/logo.png ]; then
  sudo cp /tmp/calamares-config/branding/telcosec/logo.png /usr/share/backgrounds/telcosec/wallpaper.jpg
fi
sudo chmod 644 /usr/share/backgrounds/telcosec/*

# Refresh GRUB configurations inside the chroot
if command -v update-grub &> /dev/null; then
  sudo update-grub || true
fi

# Deploy custom Plymouth boot theme
echo "Deploying custom Plymouth boot animation..."
sudo mkdir -p /usr/share/plymouth/themes/telcosec/
# Copy the password prompt assets from emerald theme (pre-installed in chroot)
if [ -d /usr/share/plymouth/themes/emerald ]; then
  sudo cp /usr/share/plymouth/themes/emerald/password_*.png /usr/share/plymouth/themes/telcosec/ 2>/dev/null || true
fi
# Copy our custom Plymouth files
if [ -d /tmp/boot/plymouth ]; then
  sudo cp -rf /tmp/boot/plymouth/. /usr/share/plymouth/themes/telcosec/
fi
# Set the official TelcoSec logo for the boot splash logo
if [ -f /usr/share/backgrounds/telcosec/logo.png ]; then
  sudo cp /usr/share/backgrounds/telcosec/logo.png /usr/share/plymouth/themes/telcosec/logo.png
fi
# Set telcosec as the default theme
sudo mkdir -p /etc/plymouth/
cat << 'EOF' | sudo tee /etc/plymouth/plymouthd.conf
[Daemon]
Theme=telcosec
ShowDelay=0
DeviceTimeout=8
EOF

# Register and set the theme via update-alternatives
if [ -f /usr/share/plymouth/themes/telcosec/telcosec.plymouth ]; then
  sudo update-alternatives --install /usr/share/plymouth/themes/default.plymouth default.plymouth /usr/share/plymouth/themes/telcosec/telcosec.plymouth 100
  sudo update-alternatives --set default.plymouth /usr/share/plymouth/themes/telcosec/telcosec.plymouth
fi

# 6. SCTP Stack Optimizations
echo "Deploying SCTP module loading and sysctl tuning..."
# Enable auto-loading of the sctp kernel module at boot
if [ -f /etc/modules ]; then
  if ! grep -q "^sctp$" /etc/modules 2>/dev/null; then
    echo "sctp" | sudo tee -a /etc/modules
  fi
else
  echo "sctp" | sudo tee /etc/modules
fi

# Deploy kernel sysctl settings
sudo mkdir -p /etc/sysctl.d/
if [ -f /tmp/security/99-sctp-tuning.conf ]; then
  sudo cp /tmp/security/99-sctp-tuning.conf /etc/sysctl.d/
  sudo chmod 644 /etc/sysctl.d/99-sctp-tuning.conf
fi
if [ -f /tmp/security/99-security-hardening.conf ]; then
  sudo cp /tmp/security/99-security-hardening.conf /etc/sysctl.d/
  sudo chmod 644 /etc/sysctl.d/99-security-hardening.conf
fi

# Attempt to load module and apply sysctl settings (ignores failures in chroot)
sudo modprobe sctp || true
if command -v sysctl &> /dev/null; then
  sudo sysctl --system || true
fi

# 7. Real-time & Low-latency Tuning for 5G NR / 5Ghoul
# OAI requires tight timing budgets (~1 ms TTI). We use 'tuned' to manage
# CPU governors, IRQ affinity, hugepages, and USB latency in one profile.
echo "Deploying real-time and low-latency tuned profile..."

sudo mkdir -p /etc/tuned/telcosec-sdr

cat << 'EOF' | sudo tee /etc/tuned/telcosec-sdr/tuned.conf
[main]
summary=Optimize for SDR and 5G Fuzzing (Low Latency, High Performance)
include=network-latency

[cpu]
governor=performance
energy_perf_bias=performance
min_perf_pct=100

[sysctl]
vm.swappiness=10
kernel.sched_min_granularity_ns=10000000
kernel.sched_wakeup_granularity_ns=15000000
vm.nr_hugepages=512
vm.hugetlb_shm_group=0

[bootloader]
cmdline=mitigations=off clocksource=tsc tsc=reliable intel_idle.max_cstate=1 processor.max_cstate=1

[script]
script=tuned-sdr.sh
EOF

cat << 'EOF' | sudo tee /etc/tuned/telcosec-sdr/tuned-sdr.sh
#!/bin/bash

# USB latency: reduce polling interval for SDR hardware
if [ "$1" = "start" ]; then
    # Disable autosuspend for generic USB hubs to prevent SDR disconnects
    for dev in /sys/bus/usb/devices/*/power/autosuspend_delay_ms; do
        echo 0 > "$dev" 2>/dev/null || true
    done
    for control in /sys/bus/usb/devices/*/power/control; do
        echo on > "$control" 2>/dev/null || true
    done
fi
EOF
sudo chmod +x /etc/tuned/telcosec-sdr/tuned-sdr.sh

# Enable the profile in the chroot. It will apply on boot.
if command -v tuned-adm &> /dev/null; then
  sudo tuned-adm profile telcosec-sdr 2>/dev/null || true
fi

# 8. Firewall Hardening
echo "Configuring default firewall policies..."
if command -v ufw &> /dev/null; then
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh || true
  sudo ufw enable || true
  echo "  UFW firewall enabled with secure defaults (deny incoming, allow outgoing)"
fi

# 8.5. NetworkManager Cellular Interfaces Override
echo "Configuring NetworkManager to ignore virtual cellular interfaces..."
sudo mkdir -p /etc/NetworkManager/conf.d/
cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/99-telcosec-unmanaged.conf
[keyfile]
# Ignore cellular network virtual interfaces to prevent DHCP/MTU hijacking
unmanaged-devices=interface-name:ogstun*;interface-name:srs*;interface-name:uesimtun*;interface-name:oaitun*;interface-name:tun_srsue

[device]
# Disable MAC randomization during Wi-Fi scans to prevent testbed connectivity issues
wifi.scan-rand-mac-address=no
EOF


# 9. Bluetooth: Off by Default
echo "Disabling Bluetooth by default..."
rfkill block bluetooth 2>/dev/null || true

# 10. Restrictive Default Umask
echo "Setting restrictive default umask (027)..."
echo 'umask 027' | sudo tee /etc/profile.d/telcosec_umask.sh > /dev/null
sudo chmod 644 /etc/profile.d/telcosec_umask.sh

# 11. Disable Unnecessary GNOME Background Daemons
echo "Disabling unnecessary GNOME and network daemons..."
# Disable GNOME color profile daemon — only needed for monitor calibration
sudo systemctl disable colord 2>/dev/null || true
# Disable GNOME remote login
sudo systemctl disable gnome-remote-desktop 2>/dev/null || true
# Disable Avahi mDNS — unwanted network advertisement on a research host
sudo systemctl disable avahi-daemon 2>/dev/null || true
sudo systemctl mask avahi-daemon 2>/dev/null || true

# 11b. Systemd-resolved DNS privacy configuration
echo "Harden systemd-resolved (disable LLMNR and mDNS)..."
sudo mkdir -p /etc/systemd/resolved.conf.d
cat << 'EOF' | sudo tee /etc/systemd/resolved.conf.d/telcosec-privacy.conf
[Resolve]
LLMNR=no
MulticastDNS=no
EOF

# 12. Custom Domain Certificates Trust
# If a custom Root/Intermediate CA cert exists, install it to system CA trust store
if [ -f /tmp/security/telcosec-ca.crt ]; then
  echo "Installing TelcoSec domain CA certificate..."
  sudo cp /tmp/security/telcosec-ca.crt /usr/local/share/ca-certificates/
  sudo chmod 644 /usr/local/share/ca-certificates/telcosec-ca.crt
fi

# Install Cloudflare Origin CA root certificates (needed for domains using
# Cloudflare Origin Certificates). These are vendored in the repo at
# builder/security/cloudflare/ with pinned sha256 checksums (SHA256SUMS),
# rather than fetched over the network at build time — a network fetch here
# meant the build's TLS trust store depended on reaching
# developers.cloudflare.com with no integrity check on what came back
# (trust-on-build), and a network hiccup silently produced an image that
# rejects Cloudflare-origin certs. Vendoring removes both problems: no
# network dependency, and a checksum mismatch is caught instead of installed.
echo "Installing Cloudflare Origin CA certificates..."
_CF_SRC_DIR=/tmp/security/cloudflare
_CF_FAIL=0

if [ -d "$_CF_SRC_DIR" ] && [ -f "$_CF_SRC_DIR/SHA256SUMS" ]; then
  sudo mkdir -p /usr/local/share/ca-certificates
  if (cd "$_CF_SRC_DIR" && sha256sum -c SHA256SUMS --quiet); then
    for crt in cloudflare_origin_ecc.crt cloudflare_origin_rsa.crt; do
      sudo cp "$_CF_SRC_DIR/$crt" "/usr/local/share/ca-certificates/$crt"
      sudo chmod 644 "/usr/local/share/ca-certificates/$crt"
      echo "  ${crt}: OK (checksum verified)"
    done
  else
    echo "  WARNING: Cloudflare CA checksum verification FAILED — refusing to install (possible tampering or stale vendored file)"
    _CF_FAIL=1
  fi
else
  echo "  WARNING: vendored Cloudflare CA certs not found at $_CF_SRC_DIR — Cloudflare-origin certs will not be trusted"
  _CF_FAIL=1
fi

sudo update-ca-certificates || true
if [ "$_CF_FAIL" = "1" ]; then
  echo "  !! BUILD WARNING: Cloudflare CA install failed — live image may reject Cloudflare-origin TLS certs" >&2
fi

# 12.5. Terminal Aliases & Tool Shortcuts
echo "Deploying global terminal aliases..."
cat << 'EOF' | sudo tee /etc/profile.d/telcosec-aliases.sh
#!/bin/sh
# TelcoSec Professional Terminal Aliases

# Open5GS
alias open5gs-start="sudo systemctl start open5gs-*"
alias open5gs-stop="sudo systemctl stop open5gs-*"
alias open5gs-logs="sudo journalctl -u open5gs-* -f"

# YateBTS
alias yate-logs="tail -f /var/log/yate.log"

# SDR & Firmware
alias update-sdr="sudo uhd_images_downloader && sudo limeUtil --update"

# Networking & Utils
alias ports="sudo netstat -tulpn"
EOF
sudo chmod 644 /etc/profile.d/telcosec-aliases.sh

echo "Deploying global tool PATH environment..."
cat << 'EOF' | sudo tee /etc/profile.d/telcosec-env.sh
#!/bin/sh
# TelcoSec Professional Tool Paths
# This ensures that tools installed in /opt/telcosec are executable globally.

if [ -d "/opt/telcosec" ]; then
    for tool_dir in /opt/telcosec/*; do
        if [ -d "$tool_dir" ]; then
            # If the tool directory itself contains executables, add it to PATH
            PATH="$PATH:$tool_dir"
            
            # If the tool directory has a bin folder, add it to PATH
            if [ -d "$tool_dir/bin" ]; then
                PATH="$PATH:$tool_dir/bin"
            fi
        fi
    done
    export PATH
fi
EOF
sudo chmod 644 /etc/profile.d/telcosec-env.sh


# 13. SSH Host Keys Cleanup
# Deletes any build-time SSH keys to ensure that OpenSSH regenerates unique,
# fresh host keys upon the first boot of the live ISO or installed system.
if [ -d /etc/ssh ]; then
  echo "Cleaning up build-time SSH host keys to trigger regeneration on first boot..."
  sudo rm -f /etc/ssh/ssh_host_*_key*
fi

echo "=== System Optimizations Applied Successfully ==="

