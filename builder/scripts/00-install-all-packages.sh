#!/bin/bash
set -e

# =============================================================================
# 00-install-all-packages.sh
# Consolidated APT package installation for TelcoChisel ISO build.
# Combines all PPAs, third-party repos, and apt-get install calls from
# scripts 01–09 into a single transaction to eliminate redundant index
# downloads and dependency resolution cycles.
# =============================================================================

echo "=== [Phase 0] Consolidated Package Installation ==="

export DEBIAN_FRONTEND=noninteractive

# Speed up apt downloads: parallel host-based queue, pipelining, auto-retry
cat > /etc/apt/apt.conf.d/99fast-dl << 'APT_FAST'
Acquire::Queue-Mode "host";
Acquire::http::Pipeline-Depth 5;
Acquire::Retries 3;
APT_FAST

# ─── 0. Chroot service suppression ──────────────────────────────────────────
# Hardware package postinstalls call udevadm/invoke-rc.d which fail in a
# chroot (no udev socket, no running init). Suppress them for the duration
# of the install phase so dpkg doesn't abort on packages like librtlsdr2,
# libhackrf0, etc.
cat > /usr/sbin/policy-rc.d << 'POLICY'
#!/bin/sh
exit 101
POLICY
chmod +x /usr/sbin/policy-rc.d

# Use dpkg-divert to intercept absolute-path /usr/bin/udevadm calls from postinstalls.
dpkg-divert --local --rename --add /usr/bin/udevadm 2>/dev/null || true
cat > /usr/bin/udevadm << 'UDEVADM'
#!/bin/sh
exit 0
UDEVADM
chmod +x /usr/bin/udevadm
mkdir -p /usr/local/sbin
cp /usr/bin/udevadm /usr/local/sbin/udevadm
export PATH="/usr/local/sbin:$PATH"

# ─── 1. Add all third-party repositories first ──────────────────────────────

echo "  Adding third-party repositories..."

# Prerequisites for add-apt-repository
apt-get install -y software-properties-common curl wget gnupg

# Firefox PPA (native .deb, not snap)
add-apt-repository -y ppa:mozillateam/ppa
cat << 'EOF' > /etc/apt/preferences.d/99mozillateam
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 1001
EOF

# Open5GS and MongoDB are NOT installed at build time.
# They are pulled in at first run via: sudo open5gs-install

# Osmocom official repository (OsmoBTS, OsmocomBB, osmo-trx, etc.)
# Key must be dearmored (binary GPG) for apt signed-by= to work.
# On failure, remove the repo file so apt-get update doesn't error out.
OSMOCOM_KEY=/usr/share/keyrings/osmocom.gpg
OSMOCOM_LIST=/etc/apt/sources.list.d/osmocom.list
OSMOCOM_URL="https://downloads.osmocom.org/packages/osmocom:/latest/xUbuntu_24.04"
if wget -qO- "${OSMOCOM_URL}/Release.key" 2>/dev/null | \
     gpg --dearmor --yes -o "$OSMOCOM_KEY" 2>/dev/null && \
   [ -s "$OSMOCOM_KEY" ]; then
  echo "deb [signed-by=${OSMOCOM_KEY}] ${OSMOCOM_URL}/ ./" > "$OSMOCOM_LIST"
  echo "  Osmocom repo added successfully."
else
  echo "  WARNING: Osmocom repo key import failed — skipping repo (tools will build from source in script 10)."
  rm -f "$OSMOCOM_LIST" "$OSMOCOM_KEY"
fi

# Kismet official repo (removed from Ubuntu 24.04 official repos)
KISMET_KEY=/usr/share/keyrings/kismet-archive-keyring.gpg
if wget -qO- https://www.kismetwireless.net/repos/kismet-release.gpg.key 2>/dev/null | \
     gpg --dearmor --yes -o "$KISMET_KEY" 2>/dev/null && [ -s "$KISMET_KEY" ]; then
  echo "deb [signed-by=${KISMET_KEY}] https://www.kismetwireless.net/repos/apt/release/noble noble main" \
    > /etc/apt/sources.list.d/kismet.list
  echo "  Kismet repo added."
else
  echo "  WARNING: Kismet repo key import failed — kismet will be skipped."
  rm -f "$KISMET_KEY" /etc/apt/sources.list.d/kismet.list
fi

# TelcoSec Custom APT Repository (hosted on GitHub Pages)
# Contains pre-compiled tools (UERANSIM, SCAT, OpenBTS, etc.) to replace source builds.
TELCOSEC_KEY=/usr/share/keyrings/telcosec-archive-keyring.gpg
TELCOSEC_LIST=/etc/apt/sources.list.d/telcosec.list
TELCOSEC_URL="https://telcosec.github.io/apt"
if wget -qO- "${TELCOSEC_URL}/Release.key" 2>/dev/null | \
     gpg --dearmor --yes -o "$TELCOSEC_KEY" 2>/dev/null && [ -s "$TELCOSEC_KEY" ]; then
  echo "deb [signed-by=${TELCOSEC_KEY}] ${TELCOSEC_URL}/ noble main" > "$TELCOSEC_LIST"
  echo "  TelcoSec custom APT repo added."
else
  echo "  WARNING: TelcoSec custom APT repo not available yet — advanced tools will build from source."
  rm -f "$TELCOSEC_KEY" "$TELCOSEC_LIST"
fi

# ─── 2. Single apt-get update ───────────────────────────────────────────────

echo "  Updating package index (single pass)..."
apt-get update

# ─── 3. System upgrade ──────────────────────────────────────────────────────

echo "  Upgrading base system..."
apt-get upgrade -y

# ─── 4. Consolidated package install ────────────────────────────────────────
# Every package from scripts 01–09, deduplicated and sorted by category.

echo "  Installing all packages (single transaction)..."

apt-get install -y \
  \
  `# === Live boot infrastructure (must precede kernel) ===` \
  casper initramfs-tools \
  \
  `# === Kernel ===` \
  linux-image-generic \
  \
  `# === Desktop environment (01-install-base.sh) ===` \
  xserver-xorg xserver-xorg-input-all \
  network-manager-gnome \
  terminator firefox \
  open-vm-tools open-vm-tools-desktop \
  \
  `# === XFCE desktop, display manager, and core apps ===` \
  xfce4 xfce4-goodies \
  lightdm thunar \
  xfce4-terminal xfce4-taskmanager \
  \
  `# === Themes and icon sets ===` \
  yaru-theme-gtk yaru-theme-icon \
  papirus-icon-theme \
  \
  `# === Core system tools (01-install-base.sh) ===` \
  git vim nano htop fzf \
  build-essential cmake pkg-config \
  ufw openssh-server \
  openvpn network-manager-openvpn network-manager-openvpn-gnome \
  wireguard wireguard-tools resolvconf \
  docker.io docker-compose-v2 \
  sudo tuned \
  \
  `# === SDR build deps (02-install-sdr.sh) ===` \
  wget libusb-1.0-0-dev \
  \
  `# === SDR global packages (02-install-sdr.sh) ===` \
  gnuradio gnuradio-dev \
  libfftw3-double3 libfftw3-dev libfftw3-bin \
  autoconf automake libtool \
  libsqlite3-dev libwxgtk3.2-dev freeglut3-dev \
  \
  `# === Core network build deps (03-install-core-network.sh) ===` \
  cmake ninja-build \
  clang-15 lld-15 lldb-15 \
  libfftw3-dev liblapacke-dev libblas-dev liblapack-dev \
  libsctp-dev lksctp-tools \
  libzmq3-dev libczmq-dev \
  libjson-c-dev \
  libglib2.0-dev \
  libconfig-dev \
  libyaml-cpp-dev \
  libboost-all-dev \
  libssl-dev \
  libmbedtls-dev \
  libnuma-dev \
  python3-yaml \
  libbladerf2 libbladerf-dev bladerf \
  \
  `# === Security tools (04-install-tools.sh) ===` \
  wireshark tshark \
  nmap \
  macchanger vlan freeradius-utils hashcat john pppoe nikto gobuster \
  libglib2.0-dev libsctp-dev \
  ruby ruby-snmp \
  sipsak \
  python3-pip python3-venv \
  wireguard \
  `# === UE analysis & baseband deps (06-install-ue-analysis.sh) ===` \
  pcscd pcsc-tools libpcsclite-dev libccid \
  python3-pyscard python3-dev \
  libosmocore-dev libmd-dev librocksdb-dev \
  unzip \
  qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils \
  bison flex libpcap-dev libgcrypt20-dev libpugixml-dev libgtest-dev \
  qtbase5-dev qttools5-dev qtmultimedia5-dev libqt5svg5-dev libc-ares-dev \
  libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0 \
  libcurl4-openssl-dev \
  libelf-dev libffi-dev libdwarf-dev libwiretap-dev wireshark-dev python3-pycparser \
  protobuf-compiler protobuf-c-compiler libprotoc-dev libprotobuf-dev libprotobuf-c-dev libjsoncpp-dev \
  gdb-multiarch libcapstone-dev gcc-mipsel-linux-gnu gcc-arm-none-eabi \
  scons g++ make \
  dfu-util autoconf-archive \
  libtalloc-dev libgnutls28-dev liburing-dev \
  `# osmo-simtrace2 — not available as pre-built deb; compiled from source in 06-install-ue-analysis.sh` \
  \
  `# === Calamares installer (07-install-installer.sh) ===` \
  calamares \
  qml-module-qtquick-controls qml-module-qtquick-controls2 \
  qml-module-qtquick-dialogs qml-module-qtquick-layouts \
  qml-module-qtquick-window2 \
  upower os-prober python3-jsonschema \
  \
  `# === 5Ghoul build toolchain (09-install-5ghoul.sh) ===` \
  git-lfs \
  meson ccache \
  python3-numpy python3-pandas python3-scapy \
  nodejs npm \
  libqt5websockets5-dev \
  \
  `# === 5Ghoul fuzzer runtime (09-install-5ghoul.sh) ===` \
  libsnappy-dev \
  liblua5.2-dev \
  libnl-3-dev libnl-route-3-dev libnl-genl-3-dev \
  libnghttp2-dev \
  libnss3-dev \
  libtbb-dev \
  libdouble-conversion-dev \
  libdwarf-dev libelf-dev libiberty-dev \
  libunwind-dev \
  libgflags-dev \
  libevent-dev \
  libfmt-dev \
  libasan6 libubsan1 \
  \
  `# === 5Ghoul requirements.sh deps (Ubuntu 24.04/Noble universe) ===` \
  `# These are pulled by the upstream requirements.sh on first-run.` \
  `# Pre-installing here avoids live-system apt errors during 5ghoul-install.` \
  bc swig graphviz libgraphviz-dev \
  libspandsp-dev \
  libsbc-dev libspeexdsp-dev \
  libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev \
  libmaxminddb-dev \
  libfreetype-dev \
  libgl-dev \
  libpcre2-dev \
  libxss1 \
  sshpass \
  libgoogle-glog-dev libzstd-dev \
  \
  `# === Developer tools & language runtimes (10/11) ===` \
  openjdk-17-jdk maven \
  ccache \
  tmux \
  \
  `# === Modem & AT command tools (11-install-device-tools.sh) ===` \
  minicom gammu modem-manager-gui screen picocom python3-serial \
  modemmanager libqmi-utils libmbim-utils \
  usb-modeswitch usb-modeswitch-data \
  \
  `# === Network analysis & wireless tools ===` \
  tcpdump iw aircrack-ng \
  \
  `# === Device flashing tools (11-install-device-tools.sh) ===` \
  heimdall-flash adb fastboot \
  \
  `# === DOCSIS & HFC Tools ===` \
  tftpd-hpa tftp-hpa isc-dhcp-server yersinia ettercap-text-only \
  \
  `# === VoIP & SIP tools (11-install-device-tools.sh / 04) ===` \
  linphone-desktop twinkle baresip \
  ppp wvdial \
  \
  `# === SNMP / BSS management ===` \
  snmp snmp-mibs-downloader snmpd libsnmp-dev \
  \
  `# === Telecom tool build dependencies (10-install-telecom-advanced.sh) ===` \
  linux-headers-generic \
  libconfig++-dev \
  libliquid-dev \
  libtalloc2 libtalloc-dev \
  libqwt-qt5-dev librtlsdr-dev libboost-all-dev libitpp-dev libfftw3-dev \
  libncurses5-dev cargo libxcrypt-dev libqt5charts5-dev libsqlite3-dev

# ─── 5. Remove chroot service suppression ────────────────────────────────────
rm -f /usr/sbin/policy-rc.d /usr/local/sbin/udevadm
if dpkg-divert --list /usr/bin/udevadm | grep -q "diversion of"; then
  rm -f /usr/bin/udevadm
  dpkg-divert --local --rename --remove /usr/bin/udevadm 2>/dev/null || true
fi

# ─── 6. Wireshark non-interactive config ─────────────────────────────────────

echo "wireshark-common wireshark-common/install-syscap boolean true" | debconf-set-selections
dpkg-reconfigure wireshark-common
if ! getent group wireshark >/dev/null; then
  groupadd -r wireshark
fi

# ─── 7. Clang alternatives (OAI build requires clang-15 as default) ─────────

update-alternatives --install /usr/bin/clang   clang   /usr/bin/clang-15   100 || true
update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100 || true
update-alternatives --install /usr/bin/lld     lld     /usr/bin/lld-15     100 || true

# ─── 6b. Global pip config — extend timeout for large wheel downloads ────────
# SSL DECRYPTION_FAILED on large wheels (>20 MB) is a transient network error.
# pip's --retries does not catch it (urllib3 marks it non-retriable), so scripts
# that download big packages use shell-level retry loops. This config increases
# the per-request timeout so slower CI mirrors don't also time out.
mkdir -p /etc/pip
cat > /etc/pip/pip.conf << 'PIPCONF'
[global]
timeout = 120
retries = 10
PIPCONF

# ─── 7. Hand typing-extensions ownership to pip ─────────────────────────────
# Ubuntu 24.04 installs typing-extensions via apt without a pip RECORD file.
# Any subsequent pip install that tries to upgrade it aborts with
# "Cannot uninstall … RECORD file not found". Force-reinstalling it now
# gives pip a proper RECORD file so later installs can upgrade it freely.
pip3 install --break-system-packages --force-reinstall --no-deps \
  typing-extensions || true

# ─── 8. Rust — deferred to first-run (~550 MB saved from ISO) ───────────────
# Rust is not required by any tool compiled during the ISO build. Deferring it
# saves ~550 MB. Run 'sudo telcosec-install-rust' on the live system when needed.
cat > /usr/local/bin/telcosec-install-rust << 'RUST_SCRIPT'
#!/bin/bash
set -e
echo "=== Installing Rust toolchain (stable, system-wide) ==="
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
  sh -s -- -y --no-modify-path --default-toolchain stable
cat > /etc/profile.d/rust.sh << 'EOF'
export RUSTUP_HOME=/usr/local/rustup
export CARGO_HOME=/usr/local/cargo
export PATH="$CARGO_HOME/bin:$PATH"
EOF
chmod 644 /etc/profile.d/rust.sh
ln -sf /usr/local/cargo/bin/rustc /usr/local/bin/rustc
ln -sf /usr/local/cargo/bin/cargo /usr/local/bin/cargo
echo "Rust installed. Run: source /etc/profile.d/rust.sh"
RUST_SCRIPT
chmod +x /usr/local/bin/telcosec-install-rust

# ─── 9. JAVA_HOME environment ────────────────────────────────────────────────
echo "  Setting JAVA_HOME..."
JAVA_PATH=$(update-alternatives --list java 2>/dev/null | grep java-17 | head -1 || true)
if [ -n "$JAVA_PATH" ]; then
  JAVA_HOME_DIR=$(dirname "$(dirname "$JAVA_PATH")")
  cat > /etc/profile.d/java.sh << EOF
export JAVA_HOME=${JAVA_HOME_DIR}
export PATH="\$JAVA_HOME/bin:\$PATH"
EOF
  chmod 644 /etc/profile.d/java.sh
fi

# ─── 10. Kismet (official repo — not in Ubuntu 24.04 universe) ──────────────
if [ -f /etc/apt/sources.list.d/kismet.list ]; then
  apt-get update -q
  apt-get install -y kismet || echo "  WARNING: kismet install failed"
else
  echo "  WARNING: Kismet repo unavailable — skipping kismet."
fi

# ─── 11. SIPp (not in Ubuntu 24.04 — build from source) ─────────────────────
if ! command -v sipp >/dev/null 2>&1; then
  echo "  Building sipp from source..."
  mkdir -p /opt/telcosec/src
  git clone --depth 1 https://github.com/SIPp/sipp /opt/telcosec/src/sipp 2>/dev/null || true
  if [ -d /opt/telcosec/src/sipp ]; then
    cmake -S /opt/telcosec/src/sipp -B /opt/telcosec/src/sipp/build \
      -DCMAKE_BUILD_TYPE=Release -DUSE_SCTP=1 -DUSE_PCAP=1 \
      -DBUILD_TESTING=OFF \
      -DCMAKE_INSTALL_PREFIX=/usr/local >/dev/null
    make -C /opt/telcosec/src/sipp/build -j"$(nproc)" sipp >/dev/null
    install -m 755 /opt/telcosec/src/sipp/build/sipp /usr/local/bin/sipp
    echo "  sipp built and installed."
  else
    echo "  WARNING: sipp source clone failed — skipping."
  fi
fi

# ─── 12. Mark phase 0 complete ───────────────────────────────────────────────

touch /tmp/.packages-installed
echo "=== [Phase 0] All packages installed successfully ==="
