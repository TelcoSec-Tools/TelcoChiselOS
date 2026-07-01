#!/bin/bash
# =============================================================================
# lib/packages.sh — TelcoChisel shared package arrays
#
# SINGLE SOURCE OF TRUTH for per-script APT package sets.
# Used in two contexts:
#   1. 00-install-all-packages.sh  — sources this file and installs the union
#      in one consolidated apt-get transaction (fast path, normal build).
#   2. Each provisioning script    — sources this file and installs only its
#      own group when running standalone (no /tmp/.packages-installed sentinel).
#
# To add/change a package:
#   • Edit the relevant PKGS_* array below.
#   • That's it — both 00 and the standalone fallback pick it up automatically.
#
# DO NOT call apt-get here; this file is sourced, not executed.
# =============================================================================

# ─── 01-install-base.sh ──────────────────────────────────────────────────────
PKGS_BASE=(
  # Live boot infrastructure (must precede kernel)
  casper initramfs-tools
  # Kernel
  linux-image-generic
  # Bootloader — needed INSIDE the chroot/squashfs, not just on the build
  # host. build-iso.sh's own prereq check requires these on the HOST to
  # build/sign the live ISO's own boot media, but that's a separate concern
  # from what ships in the installed system. Without these here, Calamares'
  # `bootloader` module (which chroots into the freshly-installed target and
  # runs grub-install) finds no grub-install/update-grub binary at all —
  # BIOS or UEFI, Secure Boot or not. grub-efi-amd64-signed + shim-signed
  # additionally let Ubuntu's patched grub-install auto-install the signed
  # shim so the installed system also boots under Secure Boot.
  grub-pc-bin grub-efi-amd64-bin shim-signed grub-efi-amd64-signed
  # Desktop (XFCE + LightDM)
  xfce4 xfce4-goodies lightdm thunar
  xfce4-terminal xfce4-taskmanager
  xserver-xorg xserver-xorg-input-all
  network-manager-gnome
  terminator firefox
  open-vm-tools open-vm-tools-desktop
  # Themes
  yaru-theme-gtk yaru-theme-icon papirus-icon-theme
  # Core system tools
  git vim nano htop fzf
  build-essential cmake pkg-config
  ufw openssh-server
  openvpn network-manager-openvpn network-manager-openvpn-gnome
  wireguard wireguard-tools resolvconf
  docker.io docker-compose-v2
  sudo tuned
)

# ─── 02-install-sdr.sh ───────────────────────────────────────────────────────
PKGS_SDR=(
  wget libusb-1.0-0-dev
  gnuradio gnuradio-dev
  libfftw3-double3 libfftw3-dev libfftw3-bin
  autoconf automake libtool
  libsqlite3-dev libwxgtk3.2-dev freeglut3-dev
)

# ─── 03-install-core-network.sh ──────────────────────────────────────────────
PKGS_CORE_NETWORK=(
  cmake ninja-build
  clang-15 lld-15 lldb-15
  libfftw3-dev liblapacke-dev libblas-dev liblapack-dev
  libsctp-dev lksctp-tools
  libzmq3-dev libczmq-dev
  libjson-c-dev
  libglib2.0-dev
  libconfig-dev
  libyaml-cpp-dev
  libboost-all-dev
  libssl-dev
  libmbedtls-dev
  libnuma-dev
  python3-yaml
  libbladerf2 libbladerf-dev bladerf
)

# ─── 04-install-tools.sh ─────────────────────────────────────────────────────
PKGS_TOOLS=(
  wireshark tshark
  nmap
  macchanger vlan freeradius-utils hashcat john pppoe nikto gobuster
  lksctp-tools libsctp-dev libglib2.0-dev
  ruby ruby-snmp
  sipsak
  python3-pip python3-venv
  wireguard
  twinkle baresip linphone-desktop
)

# ─── 06-install-ue-analysis.sh ───────────────────────────────────────────────
PKGS_UE_ANALYSIS=(
  pcscd pcsc-tools libpcsclite-dev libccid
  python3-pyscard python3-dev
  libosmocore-dev libmd-dev librocksdb-dev
  git wget unzip cmake pkg-config build-essential gnupg autoconf automake libtool
  qemu-system-arm qemu-system-mips qemu-system-x86 qemu-utils
  libglib2.0-dev bison flex libpcap-dev libgcrypt20-dev libpugixml-dev libgtest-dev
  qtbase5-dev qttools5-dev qtmultimedia5-dev libqt5svg5-dev libc-ares-dev
  libsdl2-mixer-2.0-0 libsdl2-image-2.0-0 libsdl2-2.0-0
  libcurl4-openssl-dev
  libelf-dev libffi-dev libdwarf-dev libwiretap-dev wireshark-dev python3-pycparser
  protobuf-compiler protobuf-c-compiler libprotoc-dev libprotobuf-dev libprotobuf-c-dev libjsoncpp-dev
  gdb-multiarch libcapstone-dev gcc-mipsel-linux-gnu gcc-arm-none-eabi
  scons g++ make dfu-util autoconf-archive
  libtalloc-dev libgnutls28-dev liburing-dev
)

# ─── 09-install-5ghoul.sh — build toolchain ──────────────────────────────────
PKGS_5GHOUL_BUILD=(
  git git-lfs
  cmake ninja-build meson
  ccache
  python3-pip python3-dev python3-numpy python3-pandas python3-scapy
  nodejs npm
  wireshark-dev
  libqt5websockets5-dev
)

# ─── 09-install-5ghoul.sh — fuzzer runtime ───────────────────────────────────
PKGS_5GHOUL_RUNTIME=(
  libglib2.0-dev
  libsnappy-dev
  liblua5.2-dev
  libc-ares-dev
  libnl-3-dev libnl-route-3-dev libnl-genl-3-dev
  libnghttp2-dev
  libnss3-dev
  libtbb-dev
  libdouble-conversion-dev
  libdwarf-dev libelf-dev libiberty-dev
  libunwind-dev
  libgflags-dev
  libevent-dev
  libfmt-dev
  libpcap-dev
  libasan6 libubsan1
)

# ─── 5Ghoul requirements.sh pre-deps ─────────────────────────────────────────
PKGS_5GHOUL_REQS=(
  bc swig graphviz libgraphviz-dev
  libspandsp-dev
  libsbc-dev libspeexdsp-dev
  libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev
  libmaxminddb-dev
  libfreetype-dev
  libgl-dev
  libpcre2-dev
  libxss1
  sshpass
  libgoogle-glog-dev libzstd-dev
)

# ─── Developer tools & advanced build deps (10/11) ───────────────────────────
PKGS_ADVANCED=(
  openjdk-17-jdk maven
  ccache
  tmux
  # Modem & AT command tools
  minicom gammu modem-manager-gui screen picocom python3-serial
  modemmanager libqmi-utils libmbim-utils
  usb-modeswitch usb-modeswitch-data
  # Network analysis
  tcpdump iw aircrack-ng
  # Device flashing
  heimdall-flash adb fastboot
  # DOCSIS / HFC
  tftpd-hpa tftp-hpa isc-dhcp-server yersinia ettercap-text-only
  # VoIP extras (not covered by PKGS_TOOLS)
  ppp wvdial
  # SNMP / BSS management
  snmp snmp-mibs-downloader snmpd libsnmp-dev
  # Calamares installer
  calamares
  qml-module-qtquick-controls qml-module-qtquick-controls2
  qml-module-qtquick-dialogs qml-module-qtquick-layouts
  qml-module-qtquick-window2
  upower os-prober python3-jsonschema
  # Telecom tool build deps (10-install-telecom-advanced.sh)
  linux-headers-generic
  libconfig++-dev
  libliquid-dev
  libtalloc2 libtalloc-dev
  libqwt-qt5-dev librtlsdr-dev libboost-all-dev libitpp-dev
  libncurses-dev cargo libcrypt-dev libqt5charts5-dev
)
