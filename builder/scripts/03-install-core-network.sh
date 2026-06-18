#!/bin/bash
set -e

echo "=== Configuring Core Network Stack (srsRAN + Open5GS first-run helpers) ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    cmake ninja-build \
    clang-15 lld-15 lldb-15 \
    libfftw3-dev liblapacke-dev libblas-dev liblapack-dev \
    libsctp-dev lksctp-tools \
    libzmq3-dev libczmq-dev \
    libjson-c-dev libglib2.0-dev libconfig-dev \
    libyaml-cpp-dev libboost-all-dev libssl-dev libmbedtls-dev \
    python3-yaml \
    libbladerf2 libbladerf-dev bladerf
  sudo update-alternatives --install /usr/bin/clang   clang   /usr/bin/clang-15   100 || true
  sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100 || true
  sudo update-alternatives --install /usr/bin/lld     lld     /usr/bin/lld-15     100 || true
fi

# srsRAN — no Ubuntu 24.04 noble apt package available.
# Install a first-run build script at /usr/local/bin/srsran-install.
# Users run: sudo srsran-install
echo "Creating srsRAN first-run build script..."
cat << 'SRSRAN_SCRIPT' | sudo tee /usr/local/bin/srsran-install
#!/bin/bash
set -e
INSTALL_DIR="/opt/telcosec/srsRAN_Project"
echo "╔══════════════════════════════════════════════╗"
echo "║   srsRAN Project Builder                    ║"
echo "║   https://github.com/srsran/srsRAN_Project  ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo srsran-install"
  exit 1
fi
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "[1/3] Cloning srsRAN_Project..."
  git clone --depth 1 --recurse-submodules https://github.com/srsran/srsRAN_Project.git "$INSTALL_DIR"
else
  echo "[1/3] Already cloned, pulling latest..."
  git -C "$INSTALL_DIR" pull || true
fi
cd "$INSTALL_DIR"
mkdir -p build && cd build
echo "[2/3] Configuring with cmake..."
cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON
echo "[3/3] Compiling (this takes 10-20 min)..."
make -j$(nproc)
make install
echo ""
echo "✓ srsRAN installed. Run: srsgnb --help"
SRSRAN_SCRIPT
sudo chmod +x /usr/local/bin/srsran-install

# Open5GS — not installed at build time to keep ISO lean.
# Users run: sudo open5gs-install
echo "Creating Open5GS first-run install script..."
cat << 'OPEN5GS_SCRIPT' | sudo tee /usr/local/bin/open5gs-install
#!/bin/bash
set -e
echo "╔══════════════════════════════════════════════╗"
echo "║   Open5GS 5G SA Core Installer             ║"
echo "║   https://open5gs.org                       ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo open5gs-install"
  exit 1
fi

# Add Open5GS PPA
add-apt-repository -y ppa:open5gs/latest

# Add MongoDB repo (required by Open5GS)
mkdir -p /usr/share/keyrings
wget -qO- https://pgp.mongodb.com/server-8.0.asc | gpg --dearmor > /usr/share/keyrings/mongodb-server-8.0.gpg
echo "deb [signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.0 multiverse" \
  > /etc/apt/sources.list.d/mongodb-org-8.0.list

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y mongodb-org open5gs

# Disable auto-start — core functions are started manually during testing
for svc in open5gs-amfd open5gs-smfd open5gs-upfd open5gs-nrfd \
           open5gs-ausfd open5gs-udmd open5gs-pcfd open5gs-nssfd \
           open5gs-bsfd open5gs-udrd; do
  systemctl disable "$svc" 2>/dev/null || true
done

# Patch PLMN to 5Ghoul default test PLMN (MCC 001, MNC 01)
if [ -d /etc/open5gs ]; then
  find /etc/open5gs -name "*.yaml" -exec \
    sed -i \
      -e 's/mcc: 999/mcc: 001/g' \
      -e 's/mnc: 70/mnc: 01/g' \
      -e 's/mcc: 901/mcc: 001/g' \
    {} \;
  echo "PLMN patched to MCC=001, MNC=01"
fi

# Enable IP forwarding for UPF data plane
cat > /etc/sysctl.d/99-open5gs.conf << 'SYSCTL'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
SYSCTL
sysctl -p /etc/sysctl.d/99-open5gs.conf

echo ""
echo "✓ Open5GS installed."
echo "  Start:  sudo open5gs-start"
echo "  Add UE: sudo 5ghoul-add-subscriber"
OPEN5GS_SCRIPT
sudo chmod +x /usr/local/bin/open5gs-install

echo "=== Core network stack configured ==="
