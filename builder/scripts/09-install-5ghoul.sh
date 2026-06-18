#!/bin/bash
set -e

echo "=== Installing 5Ghoul 5G NR Attack Framework Dependencies ==="
# 5Ghoul (https://github.com/asset-group/5ghoul-5g-nr-attacks) uses OpenAirInterface
# as the rogue gNB. Supported radios: USRP B210 (primary) and BladeRF A4 (20 MHz NR max).
# All system deps are installed here during ISO build; the repo clone + compilation is
# deferred to first-run to keep ISO build time reasonable. No VM support.

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  # ── Build toolchain ──────────────────────────────────────────────────────────
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git git-lfs \
    cmake ninja-build meson \
    ccache \
    python3-pip python3-dev python3-numpy python3-pandas python3-scapy \
    nodejs npm \
    wireshark-dev \
    libqt5websockets5-dev

  # ── 5Ghoul fuzzer runtime deps ───────────────────────────────────────────────
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    libglib2.0-dev \
    libsnappy-dev \
    liblua5.2-dev \
    libc-ares-dev \
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
    libpcap-dev \
    libasan6 libubsan1
fi

# ── Python tooling ───────────────────────────────────────────────────────
sudo pip3 install --break-system-packages \
  colorlog \
  pyzmq \
  pycryptodome \
  construct \
  pyshark || true

# ── Open5GS TUN interface (ogstun) for UPF user-plane traffic ────────────────
cat << 'EOF' | sudo tee /etc/systemd/network/99-ogstun.netdev
[NetDev]
Name=ogstun
Kind=tun
EOF

cat << 'EOF' | sudo tee /etc/systemd/network/99-ogstun.network
[Match]
Name=ogstun

[Network]
Address=10.45.0.1/16
Address=2001:db8:cafe::1/48
EOF

# ── ogstun bring-up + NAT masquerade (runs at boot) ─────────────────────────
cat << 'SVCSCRIPT' | sudo tee /usr/local/bin/5ghoul-setup-net
#!/bin/bash
ip tuntap add name ogstun mode tun 2>/dev/null || true
ip addr add 10.45.0.1/16        dev ogstun 2>/dev/null || true
ip addr add 2001:db8:cafe::1/48 dev ogstun 2>/dev/null || true
ip link set ogstun up

iptables  -t nat -C POSTROUTING -s 10.45.0.0/16      ! -o ogstun -j MASQUERADE 2>/dev/null || \
  iptables  -t nat -A POSTROUTING -s 10.45.0.0/16    ! -o ogstun -j MASQUERADE
ip6tables -t nat -C POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE 2>/dev/null || \
  ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE

echo "5Ghoul network interfaces ready."
SVCSCRIPT
sudo chmod +x /usr/local/bin/5ghoul-setup-net

cat << 'EOF' | sudo tee /etc/systemd/system/5ghoul-net.service
[Unit]
Description=5Ghoul ogstun Interface and NAT Setup
After=network.target
Before=open5gs-upfd.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/5ghoul-setup-net
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable 5ghoul-net.service || true

# ── Test subscriber helper ────────────────────────────────────────────────────
# Default 5Ghoul credentials: IMSI 001011234567890, K 465B5CE8B199B49FAA5F0A2EE238A6BC
# OPc E8ED289DEBA952E4283B54E88E6183CA  (matches 5Ghoul documentation)
cat << 'EOF' | sudo tee /usr/local/bin/5ghoul-add-subscriber
#!/bin/bash
if ! command -v open5gs-dbctl &>/dev/null; then
  echo "Open5GS is not installed. Run: sudo open5gs-install"
  exit 1
fi
echo "Adding 5Ghoul test subscriber to Open5GS..."
open5gs-dbctl add 001011234567890 465B5CE8B199B49FAA5F0A2EE238A6BC E8ED289DEBA952E4283B54E88E6183CA \
  || echo "Subscriber already exists."
echo "IMSI : 001011234567890"
echo "K    : 465B5CE8B199B49FAA5F0A2EE238A6BC"
echo "OPc  : E8ED289DEBA952E4283B54E88E6183CA"
EOF
sudo chmod +x /usr/local/bin/5ghoul-add-subscriber

# ── BladeRF A4 config patcher ─────────────────────────────────────────────────
# Translates USRP-specific OAI gNB conf files into BladeRF-compatible variants.
# Key differences:
#   sdr_addrs  "type=b200" → "bladerf"  (libbladeRF auto-selects the device)
#   max_rxgain 114         → 60         (AD9361 max gain on BladeRF A4)
#   max_txgain (any)       → 60         (BladeRF A4 TX gain range 0–66 dB)
#   Bandwidth is capped at 106 PRBs (20 MHz); 40 MHz causes RX overruns on BladeRF.
cat << 'PATCHSCRIPT' | sudo tee /usr/local/bin/5ghoul-bladerf-patch
#!/bin/bash
set -e
INSTALL_DIR="${1:-/opt/telcosec/5ghoul}"

echo "Patching OAI gNB configs for BladeRF A4..."

patch_conf() {
  local src="$1" dst="$2"
  cp "$src" "$dst"
  # Device address: USRP B210 address string → BladeRF auto-detect
  sed -i \
    -e 's|sdr_addrs\s*=\s*"type=b200[^"]*"|sdr_addrs = "bladerf"|g' \
    -e 's|sdr_addrs\s*=\s*"addr=[^"]*"|sdr_addrs = "bladerf"|g' \
    "$dst"
  # RF gain: clamp to BladeRF A4 AD9361 max (60 dB RX, 60 dB TX)
  sed -i \
    -e 's|max_rxgain\s*=\s*[0-9][0-9]*|max_rxgain = 60|g' \
    -e 's|max_txgain\s*=\s*[0-9][0-9]*|max_txgain = 60|g' \
    "$dst"
  # Ensure bandwidth stays at 106 PRBs (20 MHz) — comment out any 217/162 PRB entries
  sed -i \
    -e 's|^\(\s*N_RB_DL\s*=\s*21[0-9]\)|# BladeRF: max 106 PRBs (20 MHz)\n# \1|g' \
    -e 's|^\(\s*N_RB_DL\s*=\s*16[0-9]\)|# BladeRF: max 106 PRBs (20 MHz)\n# \1|g' \
    "$dst"
  echo "  Created: $dst"
}

# Search all known conf locations in the 5Ghoul repo tree
found=0
while IFS= read -r -d '' usrp_conf; do
  # Derive BladeRF conf path by replacing usrp/b210 tokens in filename
  bladerf_conf=$(echo "$usrp_conf" | sed \
    -e 's/usrpb210/bladerf-a4/g' \
    -e 's/usrp\.b210/bladerf.a4/g' \
    -e 's/\.usrp\b/.bladerf/g' \
    -e 's/usrp/bladerf/g' \
    -e 's/b210/bladerf-a4/g')
  if [ "$bladerf_conf" != "$usrp_conf" ]; then
    patch_conf "$usrp_conf" "$bladerf_conf"
    found=$((found + 1))
  fi
done < <(find "$INSTALL_DIR" \
  \( -name "*usrpb210*" -o -name "*usrp.b210*" -o -name "*.usrp.*" \) \
  -name "*.conf" -print0 2>/dev/null)

# Also patch any generic gNB confs that contain USRP device strings
while IFS= read -r -d '' conf; do
  # Only process files not already processed above
  if [[ "$conf" != *bladerf* ]]; then
    bladerf_conf="${conf%.conf}.bladerf-a4.conf"
    patch_conf "$conf" "$bladerf_conf"
    found=$((found + 1))
  fi
done < <(grep -rlZ 'type=b200\|sdr_addrs.*b200' "$INSTALL_DIR" \
  --include='*.conf' 2>/dev/null || true)

if [ "$found" -eq 0 ]; then
  echo "  No USRP conf files found yet (repo not cloned?); patch will re-run at build time."
fi

# Patch build.sh to compile OAI with the BladeRF (-w BLADERF) backend
for build_script in "$INSTALL_DIR/build.sh" "$INSTALL_DIR"/build*.sh; do
  [ -f "$build_script" ] || continue
  if grep -q '\-w USRP' "$build_script" 2>/dev/null; then
    sed -i 's/-w USRP\b/-w BLADERF/g' "$build_script"
    echo "  Patched build backend: $build_script  (-w USRP → -w BLADERF)"
  fi
done

# Patch any nested OAI build_oai calls in subdirectories
find "$INSTALL_DIR" -name "*.sh" -not -path '*/.git/*' \
  -exec grep -lq '\-w USRP' {} \; 2>/dev/null | while read -r f; do
  sed -i 's/-w USRP\b/-w BLADERF/g' "$f"
  echo "  Patched: $f"
done

echo "BladeRF patch complete."
PATCHSCRIPT
sudo chmod +x /usr/local/bin/5ghoul-bladerf-patch

# ── First-run installer (clones repo + compiles on live system) ──────────────
# Usage: sudo 5ghoul-install [--radio USRP|BLADERF]
cat << 'INSTALLSCRIPT' | sudo tee /usr/local/bin/5ghoul-install
#!/bin/bash
set -e
INSTALL_DIR="/opt/telcosec/5ghoul"
RADIO="USRP"

# Parse --radio argument
while [[ $# -gt 0 ]]; do
  case "$1" in
    --radio)   RADIO="${2^^}"; shift 2 ;;
    --radio=*) RADIO="${1#*=}"; RADIO="${RADIO^^}"; shift ;;
    *)         shift ;;
  esac
done

case "$RADIO" in
  USRP|BLADERF) ;;
  *) echo "Unknown --radio value: $RADIO. Options: USRP, BLADERF"; exit 1 ;;
esac

echo "╔══════════════════════════════════════════════════════╗"
echo "║      5Ghoul 5G NR Attack Framework Installer        ║"
echo "║  https://github.com/asset-group/5ghoul-5g-nr-attacks ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""
echo "Radio backend : $RADIO"
if [ "$RADIO" = "BLADERF" ]; then
  echo "Hardware      : BladeRF A4 (BladeRF 2.0 micro xA4) via USB 3.0"
  echo "Max bandwidth : 20 MHz NR (106 PRBs) — 40 MHz causes RX overruns on BladeRF"
else
  echo "Hardware      : USRP B210 via USB 3.0"
fi
echo "Build time    : 20–60 min"
echo ""

if [ "$(id -u)" -ne 0 ]; then
  echo "Run as root: sudo 5ghoul-install [--radio USRP|BLADERF]"
  exit 1
fi

# Verify the requested hardware library is present
if [ "$RADIO" = "BLADERF" ]; then
  if ! dpkg -l libbladerf2 2>/dev/null | grep -q '^ii'; then
    echo "ERROR: libbladerf2 not found. Install with: apt-get install libbladerf2 libbladerf-dev"
    exit 1
  fi
  echo "  libbladerf2 found."
  bladerf_info=$(bladerf-cli -e version 2>/dev/null || true)
  if [ -n "$bladerf_info" ]; then
    echo "  BladeRF CLI: $bladerf_info"
  fi
fi

# [1/5] Clone
if [ ! -d "$INSTALL_DIR/.git" ]; then
  echo "[1/5] Cloning 5Ghoul repository..."
  git clone --depth 1 --recurse-submodules --shallow-submodules \
    https://github.com/asset-group/5ghoul-5g-nr-attacks \
    "$INSTALL_DIR"
else
  echo "[1/5] Repository already cloned, updating..."
  git -C "$INSTALL_DIR" pull --recurse-submodules || true
fi

cd "$INSTALL_DIR"

# [2/5] Radio-specific pre-build patching
if [ "$RADIO" = "BLADERF" ]; then
  echo "[2/5] Applying BladeRF patches to OAI config and build scripts..."
  /usr/local/bin/5ghoul-bladerf-patch "$INSTALL_DIR"
  # Record which radio this build targets so 5ghoul-run can auto-select configs
  echo "BLADERF" > "$INSTALL_DIR/.radio-backend"
else
  echo "[2/5] USRP backend selected — no patching required."
  echo "USRP" > "$INSTALL_DIR/.radio-backend"
fi

# [3/5] Framework dependencies
echo "[3/5] Installing framework dependencies..."
bash requirements.sh dev
bash requirements.sh 5g

# [4/5] Compile
echo "[4/5] Compiling (this takes a while)..."
bash build.sh all

# [5/5] Permissions
echo "[5/5] Setting permissions..."
chown -R telcosec:plugdev "$INSTALL_DIR" || true
chmod -R g+rw "$INSTALL_DIR" || true

echo ""
echo "✓ 5Ghoul installed at $INSTALL_DIR (radio: $RADIO)"
echo ""
echo "Quick start:"
echo "  1. sudo 5ghoul-add-subscriber      # register test UE in Open5GS"
echo "  2. sudo open5gs-start              # start 5G SA core"
if [ "$RADIO" = "BLADERF" ]; then
  BCONF=$(find "$INSTALL_DIR" -name '*bladerf*' -name '*.conf' 2>/dev/null | head -1)
  echo "  3. Connect BladeRF A4 via USB 3.0"
  echo "  4. cd $INSTALL_DIR"
  if [ -n "$BCONF" ]; then
    echo "  5. sudo ./build/5g_fuzzer --gnb.conf $BCONF --Attack.Name=NAS_5GS_Fuzz --UE.IMSI=001011234567890"
  else
    echo "  5. sudo ./build/5g_fuzzer --Attack.Name=NAS_5GS_Fuzz --UE.IMSI=001011234567890"
  fi
  echo ""
  echo "Note: If you see RX overrun errors, reduce the NR bandwidth to 20 MHz (106 PRBs)."
else
  echo "  3. Connect USRP B210 via USB 3.0"
  echo "  4. cd $INSTALL_DIR"
  echo "  5. sudo ./build/5g_fuzzer --Attack.Name=NAS_5GS_Fuzz --UE.IMSI=001011234567890"
fi
INSTALLSCRIPT
sudo chmod +x /usr/local/bin/5ghoul-install

# ── Fuzzer launcher wrapper ───────────────────────────────────────────────────
# Auto-selects the BladeRF gNB conf when the build was done with --radio BLADERF.
cat << 'RUNSCRIPT' | sudo tee /usr/local/bin/5ghoul-run
#!/bin/bash
INSTALL_DIR="/opt/telcosec/5ghoul"
FUZZER="$INSTALL_DIR/build/5g_fuzzer"

if [ ! -f "$FUZZER" ]; then
  echo "5Ghoul not yet built."
  echo "  For USRP B210:   sudo 5ghoul-install"
  echo "  For BladeRF A4:  sudo 5ghoul-install --radio BLADERF"
  if command -v xterm &>/dev/null; then
    xterm -fa 'Monospace' -fs 11 -T '5Ghoul — choose radio' \
      -e 'echo "Build for USRP B210 or BladeRF A4?"; \
          PS3="Select: "; select r in USRP BLADERF; do \
            sudo 5ghoul-install --radio "$r" && break; done; \
          read -rp "Press Enter to close..."'
  fi
  exit 1
fi

cd "$INSTALL_DIR"

# If the build was done for BladeRF and no --gnb.conf was given, auto-insert one
RADIO_BACKEND="USRP"
[ -f "$INSTALL_DIR/.radio-backend" ] && RADIO_BACKEND=$(cat "$INSTALL_DIR/.radio-backend")

EXTRA_ARGS=()
if [ "$RADIO_BACKEND" = "BLADERF" ] && ! printf '%s\n' "$@" | grep -q -- '--gnb.conf'; then
  BCONF=$(find "$INSTALL_DIR" -name '*bladerf*' -name '*.conf' 2>/dev/null | head -1)
  if [ -n "$BCONF" ]; then
    echo "Auto-selected BladeRF gNB config: $BCONF"
    EXTRA_ARGS=(--gnb.conf "$BCONF")
  fi
fi

exec sudo "$FUZZER" "${EXTRA_ARGS[@]}" "$@"
RUNSCRIPT
sudo chmod +x /usr/local/bin/5ghoul-run

# ── Open5GS start/stop helpers ───────────────────────────────────────────────
cat << 'EOF' | sudo tee /usr/local/bin/open5gs-start
#!/bin/bash
if ! dpkg -l open5gs &>/dev/null 2>&1; then
  echo "Open5GS is not installed. Run: sudo open5gs-install"
  exit 1
fi
echo "Starting Open5GS 5G SA core network functions..."
for svc in open5gs-nrfd open5gs-ausfd open5gs-udmd open5gs-udrd \
           open5gs-bsfd open5gs-pcfd open5gs-nssfd open5gs-amfd \
           open5gs-smfd open5gs-upfd; do
  sudo systemctl start "$svc" 2>/dev/null && echo "  started $svc" || echo "  failed  $svc"
done
echo "Done. Check status: systemctl status 'open5gs-*'"
EOF
sudo chmod +x /usr/local/bin/open5gs-start

cat << 'EOF' | sudo tee /usr/local/bin/open5gs-stop
#!/bin/bash
if ! dpkg -l open5gs &>/dev/null 2>&1; then
  echo "Open5GS is not installed."
  exit 1
fi
echo "Stopping Open5GS..."
sudo systemctl stop open5gs-amfd open5gs-smfd open5gs-upfd open5gs-nrfd \
  open5gs-ausfd open5gs-udmd open5gs-pcfd open5gs-nssfd open5gs-bsfd open5gs-udrd 2>/dev/null || true
echo "Done."
EOF
sudo chmod +x /usr/local/bin/open5gs-stop

echo "=== 5Ghoul dependencies installed ==="
echo "  USRP B210:   sudo 5ghoul-install"
echo "  BladeRF A4:  sudo 5ghoul-install --radio BLADERF"
