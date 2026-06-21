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
cmake ../ -DENABLE_EXPORT=ON -DENABLE_ZEROMQ=ON -DENABLE_BLADERF=ON -DENABLE_LIMESDR=ON
echo "[3/3] Compiling (this takes 10-20 min)..."
make -j$(nproc)
make install
echo ""
echo "✓ srsRAN installed. Run: srsgnb --help"
SRSRAN_SCRIPT
sudo chmod +x /usr/local/bin/srsran-install

# Open5GS — Dockerized deployment to keep the host OS clean and prevent dependency conflicts
echo "Creating Open5GS first-run install script..."
cat << 'OPEN5GS_SCRIPT' | sudo tee /usr/local/bin/open5gs-install
#!/bin/bash
set -e
echo "╔══════════════════════════════════════════════╗"
echo "║   Open5GS 5G SA Core Docker Installer      ║"
echo "║   https://open5gs.org                        ║"
echo "╚══════════════════════════════════════════════╝"
echo ""
if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo open5gs-install"
  exit 1
fi

echo "Setting up Open5GS Docker environment..."
mkdir -p /opt/telcosec/open5gs
cd /opt/telcosec/open5gs

if [ ! -d "/opt/telcosec/open5gs/docker_open5gs/.git" ]; then
  git clone https://github.com/herlesupreeth/docker_open5gs
fi

cd docker_open5gs
echo "Pulling Open5GS Docker images..."
docker compose pull || docker-compose pull

echo "Patching PLMN to 5Ghoul default test PLMN (MCC 001, MNC 01)..."
if [ -f .env ]; then
  sed -i 's/MCC=.*/MCC=001/g' .env
  sed -i 's/MNC=.*/MNC=01/g' .env
fi

echo "Enable IP forwarding for UPF data plane..."
cat > /etc/sysctl.d/99-open5gs.conf << 'SYSCTL'
net.ipv4.ip_forward=1
net.ipv6.conf.all.forwarding=1
SYSCTL
sysctl -p /etc/sysctl.d/99-open5gs.conf || true

echo ""
echo "✓ Open5GS Dockerized environment installed."
echo "  Start:  sudo open5gs-start"
echo "  Stop:   sudo open5gs-stop"
echo "  Add UE: sudo 5ghoul-add-subscriber (or use the webui on http://localhost:3000)"
OPEN5GS_SCRIPT
sudo chmod +x /usr/local/bin/open5gs-install

echo "=== Core network stack configured ==="
