#!/bin/bash
set -e

echo "=== Configuring Base System ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    software-properties-common curl wget
  sudo add-apt-repository -y ppa:mozillateam/ppa
  cat << 'EOF' | sudo tee /etc/apt/preferences.d/99mozillateam
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    casper initramfs-tools
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    linux-image-generic
  # Bootloader packages needed INSIDE the image (see lib/packages.sh PKGS_BASE
  # for the full rationale) — without these, Calamares can't install a
  # bootloader on the target system at all.
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    grub-pc-bin grub-efi-amd64-bin shim-signed grub-efi-amd64-signed
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 xfce4-goodies lightdm \
    xserver-xorg xserver-xorg-input-all \
    network-manager-gnome \
    terminator firefox \
    open-vm-tools open-vm-tools-desktop \
    git vim nano htop \
    build-essential cmake pkg-config \
    ufw openssh-server \
    docker.io docker-compose-v2
fi

echo "=== Ensuring initrd is generated ==="
KVER=$(ls /boot/vmlinuz-* 2>/dev/null | sort -V | tail -1 | sed 's|/boot/vmlinuz-||')
if [ -n "$KVER" ] && [ ! -f "/boot/initrd.img-$KVER" ]; then
  update-initramfs -c -k "$KVER"
fi

echo "=== Configuring NetworkManager ==="
sudo systemctl enable NetworkManager
sudo systemctl enable lightdm

echo "=== Creating Default User ==="
# Pre-create telcosec group and user (UID/GID 1000) for build compatibility
sudo groupadd -g 1000 telcosec || true
sudo useradd -m -s /bin/bash -u 1000 -g telcosec telcosec || true
echo "telcosec:telcosec" | sudo chpasswd
sudo usermod -aG sudo,dialout,plugdev,audio,video,docker,netdev telcosec || true
