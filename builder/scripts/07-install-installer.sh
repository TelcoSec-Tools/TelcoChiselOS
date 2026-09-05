#!/bin/bash
set -e

echo "=== Installing & Fully Optimizing Calamares Installer ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
      calamares \
      qml-module-qtquick-controls qml-module-qtquick-controls2 \
      qml-module-qtquick-dialogs qml-module-qtquick-layouts \
      qml-module-qtquick-window2 \
      upower os-prober python3-jsonschema
fi

# 1. Deploy pre-built Calamares config from our builder directory
echo "Deploying Calamares config and branding..."
sudo mkdir -p /etc/calamares/modules
sudo mkdir -p /etc/calamares/branding/telcosec
sudo mkdir -p /usr/share/calamares/branding/telcosec

sudo cp -f /tmp/calamares-config/settings.conf /etc/calamares/settings.conf
sudo cp -rf /tmp/calamares-config/modules/. /etc/calamares/modules/
sudo cp -rf /tmp/calamares-config/branding/telcosec/. /usr/share/calamares/branding/telcosec/
sudo cp -rf /tmp/calamares-config/branding/telcosec/. /etc/calamares/branding/telcosec/

# 2. Create Desktop Shortcut
echo "Creating Desktop Launcher..."
sudo mkdir -p /etc/skel/Desktop

cat << 'EOF' | sudo tee /etc/skel/Desktop/install-telcosec.desktop
[Desktop Entry]
Type=Application
Version=1.0
Name=Install TelcoChisel
Comment=Install this system permanently to your hard disk
Exec=sudo -E calamares
Icon=calamares
Terminal=false
StartupNotify=true
Categories=System;
EOF

sudo chmod +x /etc/skel/Desktop/install-telcosec.desktop

if [ -d /home/telcosec ]; then
  sudo mkdir -p /home/telcosec/Desktop
  sudo cp -f /etc/skel/Desktop/install-telcosec.desktop /home/telcosec/Desktop/
  sudo chmod +x /home/telcosec/Desktop/install-telcosec.desktop || true
  sudo chown -R telcosec:telcosec /home/telcosec/Desktop
fi

# 3. Create Autostart Hook for Direct-Install Boot Mode
echo "Creating Calamares direct-install autostart hook..."
sudo mkdir -p /etc/skel/.config/autostart
cat << 'EOF' | sudo tee /etc/skel/.config/autostart/calamares-boot.desktop
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
  sudo mkdir -p /home/telcosec/.config/autostart
  sudo cp -f /etc/skel/.config/autostart/calamares-boot.desktop /home/telcosec/.config/autostart/
  sudo chown -R telcosec:telcosec /home/telcosec/.config
fi
