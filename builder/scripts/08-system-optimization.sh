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
echo "Deploying custom GNOME tool menus and categories..."
sudo rm -f /etc/xdg/menus/applications-merged/telcosec.menu
# Deploy GNOME applications menu (read by apps-menu GNOME Shell extension)
if [ -f /tmp/menu/gnome-applications.menu ]; then
  sudo mkdir -p /etc/xdg/menus
  sudo cp /tmp/menu/gnome-applications.menu /etc/xdg/menus/gnome-applications.menu
  sudo chmod 644 /etc/xdg/menus/gnome-applications.menu
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
# OAI requires tight timing budgets (~1 ms TTI); stock kernel + USB latency
# settings are the two biggest sources of timing jitter on bare metal.
echo "Deploying real-time and low-latency kernel tuning..."

# GRUB: disable CPU mitigations (Spectre/Meltdown retpoline adds ~5-10% overhead)
# and set clocksource to tsc for consistent timestamps.
# CPU isolation (isolcpus) is left as a comment; the exact core range depends on
# the target hardware. Users should add e.g. isolcpus=2-5,nohz_full=2-5,rcu_nocbs=2-5
# to /etc/default/grub GRUB_CMDLINE_LINUX_DEFAULT for dedicated OAI cores.
cat << 'EOF' | sudo tee /etc/default/grub.d/99-telcosec-rt.cfg
# TelcoSec real-time tuning for 5G NR signal processing
# Add isolcpus=<cores> nohz_full=<cores> rcu_nocbs=<cores> manually for your CPU topology
GRUB_CMDLINE_LINUX_DEFAULT="$GRUB_CMDLINE_LINUX_DEFAULT mitigations=off clocksource=tsc tsc=reliable intel_idle.max_cstate=1 processor.max_cstate=1"
EOF

# USB latency: reduce polling interval for USRP B210 (default 5 ms → 1 ms)
# Affects all USB devices on boot; safe for desktop use
cat << 'EOF' | sudo tee /etc/udev/rules.d/51-usb-latency.rules
# Reduce USB autosuspend latency for SDR devices (USRP B210 requires low-latency USB)
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2514", ATTR{power/autosuspend_delay_ms}="0"
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="2514", ATTR{power/control}="on"
# HackRF
ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1d50", ATTR{power/control}="on"
EOF

# Hugepages for DPDK-based OAI fronthaul (2 MB pages, 512 = 1 GB reserved)
cat << 'EOF' | sudo tee /etc/sysctl.d/99-hugepages.conf
vm.nr_hugepages=512
vm.hugetlb_shm_group=0
EOF

# IRQ affinity script: pins all IRQs away from isolated CPUs at boot.
# Users call this after setting isolcpus in GRUB; harmless if no cores are isolated.
cat << 'IRQSCRIPT' | sudo tee /usr/local/bin/set-irq-affinity
#!/bin/bash
# Pin all IRQs to CPU 0-1, freeing other cores for OAI real-time threads.
# Adjust HOUSEKEEPING_CPUS to match your isolcpus setting.
HOUSEKEEPING_CPUS="0,1"
MASK=$(python3 -c "
cpus='$HOUSEKEEPING_CPUS'.split(',')
m=0
for c in cpus:
    if '-' in c:
        a,b=map(int,c.split('-'))
        for i in range(a,b+1): m|=(1<<i)
    else:
        m|=(1<<int(c))
print(hex(m)[2:])")
for irq in /proc/irq/*/smp_affinity; do
  echo "$MASK" > "$irq" 2>/dev/null || true
done
echo "IRQ affinity set to CPUs $HOUSEKEEPING_CPUS (mask 0x$MASK)"
IRQSCRIPT
sudo chmod +x /usr/local/bin/set-irq-affinity

# 8. Firewall Hardening
echo "Configuring default firewall policies..."
if command -v ufw &> /dev/null; then
  sudo ufw default deny incoming
  sudo ufw default allow outgoing
  sudo ufw allow ssh || true
  sudo ufw enable || true
  echo "  UFW firewall enabled with secure defaults (deny incoming, allow outgoing)"
fi

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

# Download and install Cloudflare Origin CA root certificates (needed for domains using Cloudflare Origin Certificates)
echo "Downloading and installing Cloudflare Origin CA certificates..."
sudo wget -qO /usr/local/share/ca-certificates/cloudflare_origin_ecc.crt https://developers.cloudflare.com/ssl/static/origin_ca_ecc_root.pem || true
sudo wget -qO /usr/local/share/ca-certificates/cloudflare_origin_rsa.crt https://developers.cloudflare.com/ssl/static/origin_ca_rsa_root.pem || true

if [ -f /usr/local/share/ca-certificates/cloudflare_origin_ecc.crt ]; then
  sudo chmod 644 /usr/local/share/ca-certificates/cloudflare_origin_ecc.crt
fi
if [ -f /usr/local/share/ca-certificates/cloudflare_origin_rsa.crt ]; then
  sudo chmod 644 /usr/local/share/ca-certificates/cloudflare_origin_rsa.crt
fi

sudo update-ca-certificates || true

# 13. SSH Host Keys Cleanup
# Deletes any build-time SSH keys to ensure that OpenSSH regenerates unique,
# fresh host keys upon the first boot of the live ISO or installed system.
if [ -d /etc/ssh ]; then
  echo "Cleaning up build-time SSH host keys to trigger regeneration on first boot..."
  sudo rm -f /etc/ssh/ssh_host_*_key*
fi

echo "=== System Optimizations Applied Successfully ==="

