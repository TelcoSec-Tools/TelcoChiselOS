#!/bin/bash
set -e

echo "=== Installing & Fully Optimizing Calamares Installer ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
      calamares \
      qml-module-qtquick-controls qml-module-qtquick-controls2 \
      qml-module-qtquick-dialogs qml-module-qtquick-layouts \
      qml-module-qtquick-window2 \
      upower os-prober python3-jsonschema
fi

# 1. Deploy pre-built Calamares config from our builder directory
echo "Deploying Calamares config and branding..."
mkdir -p /etc/calamares/modules
mkdir -p /etc/calamares/branding/telcosec
mkdir -p /usr/share/calamares/branding/telcosec

cp -f /tmp/calamares-config/settings.conf /etc/calamares/settings.conf
cp -rf /tmp/calamares-config/modules/. /etc/calamares/modules/
cp -rf /tmp/calamares-config/branding/telcosec/. /usr/share/calamares/branding/telcosec/
cp -rf /tmp/calamares-config/branding/telcosec/. /etc/calamares/branding/telcosec/

# 2. Create CLI Installer Launcher and Desktop Shortcut
echo "Creating Installer Launchers..."

# CLI wrapper so users can run 'install-telcosec' or 'telcosec-install' directly
cat << 'EOF' > /usr/local/bin/install-telcosec
#!/bin/bash
# TelcoChisel Installer CLI Launcher
if [ "$(id -u)" -ne 0 ]; then
  exec sudo -E calamares "$@"
else
  exec calamares "$@"
fi
EOF
chmod 755 /usr/local/bin/install-telcosec
ln -sf /usr/local/bin/install-telcosec /usr/local/bin/telcosec-install

mkdir -p /etc/skel/Desktop

# Polyglot desktop entry: valid INI desktop launcher in GUI + executable shell script if invoked via ./install-telcosec.desktop
cat << 'EOF' > /etc/skel/Desktop/install-telcosec.desktop
#!/usr/bin/env -S sh -c "exec /usr/local/bin/install-telcosec \"$@\""
[Desktop Entry]
Type=Application
Version=1.0
Name=Install TelcoChisel
Comment=Install this system permanently to your hard disk
Exec=sudo -E calamares
Icon=telcochisel
Terminal=false
StartupNotify=true
Categories=System;
EOF

chmod 755 /etc/skel/Desktop/install-telcosec.desktop
gio set -t string /etc/skel/Desktop/install-telcosec.desktop metadata::trusted true 2>/dev/null || true

if [ -d /home/telcosec ]; then
  mkdir -p /home/telcosec/Desktop
  cp -f /etc/skel/Desktop/install-telcosec.desktop /home/telcosec/Desktop/
  chmod 755 /home/telcosec/Desktop/install-telcosec.desktop || true
  gio set -t string /home/telcosec/Desktop/install-telcosec.desktop metadata::trusted true 2>/dev/null || true
  chown -R telcosec:telcosec /home/telcosec/Desktop
fi

# 3. Create Autostart Hook for Direct-Install Boot Mode
echo "Creating Calamares direct-install autostart hook..."
mkdir -p /etc/skel/.config/autostart
cat << 'EOF' > /etc/skel/.config/autostart/calamares-boot.desktop
[Desktop Entry]
Type=Application
Version=1.0
Name=Calamares Installer Autostart
Comment=Automatically launch Calamares if booted with install option
Exec=sh -c 'if grep -Ewq "calamares|only-ubiquity" /proc/cmdline; then sudo -E calamares; fi'
Terminal=false
StartupNotify=false
Hidden=false
EOF

if [ -d /home/telcosec ]; then
  mkdir -p /home/telcosec/.config/autostart
  cp -f /etc/skel/.config/autostart/calamares-boot.desktop /home/telcosec/.config/autostart/
  chown -R telcosec:telcosec /home/telcosec/.config
fi
