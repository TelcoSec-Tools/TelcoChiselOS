#!/bin/bash
set -e

echo "=== Installing Advanced Telecom Tools ==="

# Prevent git from blocking on credential prompts in non-interactive CI/chroot builds.
# GIT_TERMINAL_PROMPT=0 stops the terminal askpass; credential.helper='' disables
# the credential manager (which can auto-fill username and then hang waiting for password);
# GIT_ASKPASS=/bin/false makes any remaining askpass call return immediately with failure.
export GIT_TERMINAL_PROMPT=0
export GIT_ASKPASS=/bin/false
git config --global credential.helper ''

TELCOSEC_OPT=/opt/telcosec
mkdir -p "$TELCOSEC_OPT"

# ─── Pre-clone all repos in parallel before starting any builds ──────────────
echo "  Cloning repositories in parallel..."
mkdir -p "$TELCOSEC_OPT"
git clone --depth 1 https://github.com/aligungr/UERANSIM        "${TELCOSEC_OPT}/ueransim"        2>/dev/null || true &
git clone --depth 1 https://github.com/fgsect/scat              "${TELCOSEC_OPT}/scat"            2>/dev/null || true &
git clone --depth 1 https://github.com/steve-m/kalibrate-gsm   "${TELCOSEC_OPT}/kalibrate-gsm"   2>/dev/null || true &
git clone --depth 1 https://github.com/S3cur1ty-fr/modmobmap   "${TELCOSEC_OPT}/modmobmap"       2>/dev/null || true &
git clone --depth 1 https://github.com/srlabs/SIMtester         "${TELCOSEC_OPT}/simtester"       2>/dev/null || true &
git clone --depth 1 https://github.com/yatebts/yatebts          "${TELCOSEC_OPT}/yatebts"         2>/dev/null || true &
git clone --depth 1 https://github.com/RangeNetworks/openbts    "${TELCOSEC_OPT}/openbts"         2>/dev/null || true &
git clone --depth 1 https://github.com/srsran/srsgui            "${TELCOSEC_OPT}/srsgui"          2>/dev/null || true &
git clone --depth 1 https://github.com/Evrytania/LTE-Cell-Scanner "${TELCOSEC_OPT}/lte-cellscanner" 2>/dev/null || true &
git clone --depth 1 https://github.com/SysSec-KAIST/LTESniffer  "${TELCOSEC_OPT}/ltesniffer"      2>/dev/null || true &
git clone --depth 1 https://github.com/free5gc/gtp5g            "${TELCOSEC_OPT}/gtp5g"           2>/dev/null || true &
git clone --depth 1 https://github.com/TelcoSec-Tools/RDNSx     "${TELCOSEC_OPT}/rdnsx"           2>/dev/null || true &
git clone --depth 1 https://github.com/rlaager/docsis           "${TELCOSEC_OPT}/docsis"          2>/dev/null || true &
git clone --depth 1 https://github.com/fkie-cad/falcon          "${TELCOSEC_OPT}/falcon"          2>/dev/null || true &
git clone --depth 1 https://github.com/TelcoSec-Tools/TelcoSec-ChiselControl-Dashboard "${TELCOSEC_OPT}/dashboard" 2>/dev/null || true &
wait
echo "  Parallel clone complete."

# Test PLMN constants (ITU-T standard test network)
MCC=001
MNC=01

# ─── Global PLMN config ──────────────────────────────────────────────────────
mkdir -p /etc/telcosec
cat > /etc/telcosec/plmn.conf << EOF
# TelcoSec test PLMN configuration (ITU-T test network 001-01)
MCC=${MCC}
MNC=${MNC}
PLMN=${MCC}${MNC}
TAC=0x0001
EOF

# ─── A. UERANSIM (5G UE/gNB simulator) ─────────────────────────────────────
echo "  Installing UERANSIM..."
if dpkg-query -W ueransim 2>/dev/null; then
  echo "    UERANSIM already installed via APT."
elif apt-cache show ueransim >/dev/null 2>&1; then
  apt-get install -y ueransim
else
  if [ -d "${TELCOSEC_OPT}/ueransim" ]; then
    cd "${TELCOSEC_OPT}/ueransim"
    cmake -DCMAKE_BUILD_TYPE=Release . 2>&1 | tail -3
    make -j"$(nproc)" 2>&1 | tail -5
    ln -sf "${TELCOSEC_OPT}/ueransim/build/nr-gnb" /usr/local/bin/nr-gnb
    ln -sf "${TELCOSEC_OPT}/ueransim/build/nr-ue"  /usr/local/bin/nr-ue
    ln -sf "${TELCOSEC_OPT}/ueransim/build/nr-cli" /usr/local/bin/nr-cli

    # Deploy test PLMN config templates
    mkdir -p /etc/telcosec/ueransim
    cp config/open5gs-gnb.yaml /etc/telcosec/ueransim/gnb.yaml   2>/dev/null || true
    cp config/open5gs-ue.yaml  /etc/telcosec/ueransim/ue.yaml    2>/dev/null || true
    # Patch MCC/MNC into configs
    sed -i "s/mcc: '999'/mcc: '${MCC}'/g; s/mcc: 999/mcc: ${MCC}/g" \
      /etc/telcosec/ueransim/*.yaml 2>/dev/null || true
    sed -i "s/mnc: '70'/mnc: '${MNC}'/g;  s/mnc: 70/mnc: ${MNC}/g" \
      /etc/telcosec/ueransim/*.yaml 2>/dev/null || true
    chown -R telcosec:telcosec "${TELCOSEC_OPT}/ueransim" /etc/telcosec/ueransim
    cd /
  fi
fi

# ─── B. SCAT (Diag protocol / Samsung/Qualcomm log decoder) ─────────────────
echo "  Installing SCAT..."
pip3 install scat --break-system-packages 2>/dev/null || true
if [ -d "${TELCOSEC_OPT}/scat" ]; then
  pip3 install -e "${TELCOSEC_OPT}/scat" --break-system-packages 2>/dev/null || true
fi

# ─── C. Osmocom tools (GSM/2G BTS stack) ────────────────────────────────────
echo "  Installing Osmocom tools..."
# Try the Osmocom APT repo first (added by 00-install-all-packages.sh).
# If the repo key wasn't imported successfully the list file won't exist,
# so we fall back to source builds / skip gracefully.
OSMOCOM_PKGS="osmo-bts-virtual osmo-bts-trx osmo-trx-common osmo-hlr osmo-msc osmo-bsc osmo-sgsn osmocom-utils libosmocore-dev libosmovty-dev libosmosim-dev libosmogb-dev libosmo-sigtran-dev"
if [ -f /etc/apt/sources.list.d/osmocom.list ]; then
  apt-get update -qq 2>/dev/null || true
  # shellcheck disable=SC2086
  apt-get install -y --no-install-recommends $OSMOCOM_PKGS 2>/dev/null || \
    echo "  WARNING: Some Osmocom packages unavailable — continuing without them"
else
  echo "  Osmocom APT repo not available — skipping binary package install."
  echo "  Osmocom tools can be compiled from source: https://osmocom.org/projects/cellular-infrastructure/wiki"
fi

# ─── D. Kalibrate-GSM (GSM frequency calibration) ──────────────────────────
echo "  Installing Kalibrate-GSM..."
if [ -d "${TELCOSEC_OPT}/kalibrate-gsm" ]; then
  cd "${TELCOSEC_OPT}/kalibrate-gsm"
  ./bootstrap.sh 2>/dev/null || autoreconf -fi
  ./configure && make -j"$(nproc)"
  cp src/kal /usr/local/bin/kal-gsm 2>/dev/null || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/kalibrate-gsm"
  cd /
fi

# ─── E. Modmobmap (cell mapping via AT commands) ────────────────────────────
echo "  Installing Modmobmap..."
if [ -d "${TELCOSEC_OPT}/modmobmap" ]; then
  pip3 install -r "${TELCOSEC_OPT}/modmobmap/requirements.txt" \
    --break-system-packages 2>/dev/null || true
  cat > /usr/local/bin/modmobmap << 'SCRIPT'
#!/bin/bash
python3 /opt/telcosec/modmobmap/modmobmap.py "$@"
SCRIPT
  chmod +x /usr/local/bin/modmobmap
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/modmobmap"
fi

# ─── F. SIMTester (Java SIM card security testing) ──────────────────────────
echo "  Installing SIMTester..."
if [ -d "${TELCOSEC_OPT}/simtester" ]; then
  # The srlabs/SIMtester repo provides pre-compiled binaries instead of Maven source.
  JAR=$(find "${TELCOSEC_OPT}/simtester/binaries" -name "SIMTester.jar" | sort -V | tail -n 1)
  if [ -n "$JAR" ]; then
    cat > /usr/local/bin/simtester << EOF
#!/bin/bash
exec java -jar ${JAR} "\$@"
EOF
    chmod +x /usr/local/bin/simtester
  else
    echo "  WARNING: SIMTester.jar not found in binaries folder."
  fi
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/simtester"
fi

# ─── G. YateBTS + Yate (GSM/UMTS BTS with BladeRF support) ─────────────────
echo "  Installing YateBTS (deferred compile — providing installer helper)..."

cat > /usr/local/bin/yatebts-install << 'SCRIPT'
#!/bin/bash
set -e
echo "=== YateBTS Full Install (BladeRF optimized) ==="
if [ ! -d /opt/telcosec/yatebts ]; then
  echo "Cloning YateBTS source..."
  git clone --depth 1 https://github.com/yatebts/yatebts /opt/telcosec/yatebts
fi
cd /opt/telcosec/yatebts

# Install Yate first
if [ ! -d /opt/telcosec/yate ]; then
  apt-get install -y yate yate-dev 2>/dev/null || \
    git clone --depth 1 https://github.com/YateTEL/yate /opt/telcosec/yate
  if [ -d /opt/telcosec/yate ] && [ ! -f /usr/local/bin/yate ]; then
    cd /opt/telcosec/yate
    ./autogen.sh && ./configure && make -j$(nproc) && make install
    cd -
  fi
fi

# Build YateBTS against Yate
cd /opt/telcosec/yatebts
./autogen.sh && ./configure && make -j$(nproc) && make install

# BladeRF / LimeSDR configs
mkdir -p /etc/yate
cat > /etc/yate/ybladerf.conf << EOF
[general]
; BladeRF A4 configuration for YateBTS
rx_latency=3
tx_latency=3
threads=2
loopback=none
EOF
cat > /etc/yate/ylms.conf << EOF
[general]
; LimeSDR Mini configuration for YateBTS
rx_latency=3
tx_latency=3
threads=2
loopback=none
EOF
echo "YateBTS installed. Start with: sudo yate -s -l /var/log/yate.log"
SCRIPT
chmod +x /usr/local/bin/yatebts-install
chown -R telcosec:telcosec "${TELCOSEC_OPT}/yatebts" 2>/dev/null || true

# ─── H. OpenBTS (GSM BTS, deferred compile) ─────────────────────────────────
echo "  Installing OpenBTS helper..."

cat > /usr/local/bin/openbts-install << 'SCRIPT'
#!/bin/bash
set -e
echo "=== OpenBTS Install ==="
if [ ! -d /opt/telcosec/openbts ]; then
  echo "Cloning OpenBTS source..."
  git clone --depth 1 https://github.com/RangeNetworks/openbts /opt/telcosec/openbts
fi
cd /opt/telcosec/openbts
# OpenBTS requires libosip2, libexosip2, liba53
apt-get install -y libosip2-dev libexosip2-dev
./autogen.sh && ./configure && make -j$(nproc) && make install
echo "OpenBTS installed. Configure: /etc/OpenBTS/OpenBTS.conf"
SCRIPT
chmod +x /usr/local/bin/openbts-install
chown -R telcosec:telcosec "${TELCOSEC_OPT}/openbts" 2>/dev/null || true

# ─── I. srsGUI (visualization for srsRAN metrics) ───────────────────────────
echo "  Installing srsGUI..."
if [ -d "${TELCOSEC_OPT}/srsgui" ]; then
  cd "${TELCOSEC_OPT}/srsgui"
  mkdir -p build && cd build
  cmake .. -DCMAKE_BUILD_TYPE=Release 2>&1 | tail -3
  # srsGUI CMakeLists.txt adds test subdirs unconditionally; build only the main target
  # to avoid test compilation failures (missing Qt test harness).
  make -j"$(nproc)" srsgui 2>&1 | tail -5 || \
    make -j"$(nproc)" 2>&1 | tail -5 || true
  [ -f srsgui ] && ln -sf "${TELCOSEC_OPT}/srsgui/build/srsgui" /usr/local/bin/srsgui || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/srsgui"
  cd /
fi

# ─── J. LTE-CellScanner ──────────────────────────────────────────────────────
echo "  Installing LTE-CellScanner..."
if [ -d "${TELCOSEC_OPT}/lte-cellscanner" ]; then
  cd "${TELCOSEC_OPT}/lte-cellscanner"
  mkdir -p build && cd build
  cmake .. 2>&1 | tail -3
  make -j"$(nproc)" 2>&1 | tail -5 || true
  [ -f src/CellSearch ] && ln -sf "${TELCOSEC_OPT}/lte-cellscanner/build/src/CellSearch" \
    /usr/local/bin/LTE-CellSearch || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/lte-cellscanner"
  cd /
fi

# ─── K. LTESniffer ───────────────────────────────────────────────────────────
echo "  Installing LTESniffer..."
if [ -d "${TELCOSEC_OPT}/ltesniffer" ]; then
  cd "${TELCOSEC_OPT}/ltesniffer"
  mkdir -p build && cd build
  export CFLAGS="-Wno-error"
  export CXXFLAGS="-Wno-error"
  cmake .. -DCMAKE_BUILD_TYPE=Release 2>&1 | tail -3
  make -j"$(nproc)" 2>&1 | tail -5 || true
  SNIFFER_BIN=$(find . -name "ltesniffer" -type f 2>/dev/null | head -1)
  [ -n "$SNIFFER_BIN" ] && \
    ln -sf "${TELCOSEC_OPT}/ltesniffer/build/${SNIFFER_BIN}" /usr/local/bin/ltesniffer || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/ltesniffer"
  cd /
fi

# ─── L. 5G GTP kernel module (gtp5g) ─────────────────────────────────────────
echo "  Installing gtp5g kernel module..."
# Kernel module cannot be compiled inside the chroot (no kernel headers).
# gtp5g-load compiles and inserts it at first run on the live system.
# Always create the helper — it clones the source if the build-time clone was skipped.
cat > /usr/local/bin/gtp5g-load << 'GSCRIPT'
#!/bin/bash
set -e
# Build (if needed) and load the 5G GTP kernel module
if [ ! -d /opt/telcosec/gtp5g ]; then
  echo "Cloning gtp5g source..."
  git clone --depth 1 https://github.com/free5gc/gtp5g /opt/telcosec/gtp5g
fi
cd /opt/telcosec/gtp5g
[ -f gtp5g.ko ] || make -j$(nproc)
make install
modprobe gtp5g
echo "gtp5g module loaded: $(lsmod | grep gtp5g)"
GSCRIPT
chmod +x /usr/local/bin/gtp5g-load
if [ -d "${TELCOSEC_OPT}/gtp5g" ]; then
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/gtp5g"
fi

# ─── M. GTP Python toolkit ───────────────────────────────────────────────────
echo "  Installing GTP Python tools..."
pip3 install gtplib --break-system-packages 2>/dev/null || true
pip3 install python-messaging --break-system-packages 2>/dev/null || true

# ─── N. OAI UE installer helper ──────────────────────────────────────────────
echo "  Installing OAI-UE helper script..."
cat > /usr/local/bin/oai-install << 'SCRIPT'
#!/bin/bash
set -e
echo "=== OpenAirInterface UE Install ==="
git clone --depth 1 https://gitlab.eurecom.fr/oai/openairinterface5g.git /opt/telcosec/oai
cd /opt/telcosec/oai
source oaienv
# Note: User can modify this script locally to use -w LMSSDR for LimeSDR.
./cmake_targets/build_oai.sh -I --ue -w BLADERF 2>&1 | tee /tmp/oai-build.log
echo "OAI UE installed. Binaries in targets/bin/"
SCRIPT
chmod +x /usr/local/bin/oai-install

# ─── O. BSS management helper scripts (Nokia/Ericsson/Huawei) ────────────────
echo "  Installing BSS management scripts..."
mkdir -p "${TELCOSEC_OPT}/bss-tools"

cat > /usr/local/bin/nokia-netact-cli << 'SCRIPT'
#!/bin/bash
# Nokia NetAct CLI wrapper (SNMP + SSH)
# Usage: nokia-netact-cli <host> [community]
HOST=${1:-127.0.0.1}; COMMUNITY=${2:-public}
snmpwalk -v2c -c "$COMMUNITY" "$HOST" iso.3.6.1.2.1.1 2>/dev/null || \
  ssh -o StrictHostKeyChecking=no "netact@${HOST}" 2>/dev/null
SCRIPT

cat > /usr/local/bin/ericsson-enm-cli << 'SCRIPT'
#!/bin/bash
# Ericsson ENM CLI wrapper (SSH scripting)
# Usage: ericsson-enm-cli <host> [user]
HOST=${1:-127.0.0.1}; USER=${2:-nmsadm}
ssh -o StrictHostKeyChecking=no "${USER}@${HOST}"
SCRIPT

cat > /usr/local/bin/huawei-u2000-cli << 'SCRIPT'
#!/bin/bash
# Huawei U2000 CLI wrapper (telnet/SSH)
# Usage: huawei-u2000-cli <host> [port]
HOST=${1:-127.0.0.1}; PORT=${2:-22}
ssh -p "$PORT" -o StrictHostKeyChecking=no "mscuser@${HOST}" 2>/dev/null || \
  telnet "$HOST" "$PORT"
SCRIPT

chmod +x /usr/local/bin/nokia-netact-cli \
         /usr/local/bin/ericsson-enm-cli \
         /usr/local/bin/huawei-u2000-cli
chown -R telcosec:telcosec "${TELCOSEC_OPT}/bss-tools"

# ─── P. Open5GS test PLMN patch (only if installed) ─────────────────────────
if [ -d /etc/open5gs ]; then
  echo "  Patching Open5GS to use test PLMN ${MCC}/${MNC}..."
  for CFG in /etc/open5gs/*.yaml; do
    [ -f "$CFG" ] || continue
    sed -i \
      -e "s/mcc: '901'/mcc: '${MCC}'/g" \
      -e "s/mnc: '70'/mnc: '${MNC}'/g"  \
      -e "s/mcc: 901/mcc: ${MCC}/g"     \
      -e "s/mnc: 70/mnc: ${MNC}/g"      \
      "$CFG" 2>/dev/null || true
  done
else
  echo "  Open5GS not installed — skipping PLMN patch (run sudo open5gs-install first)"
fi

# ─── Q. srsRAN test PLMN patch ───────────────────────────────────────────────
echo "  Patching srsRAN config to use test PLMN..."
for CFG in /etc/srsran/*.conf; do
  [ -f "$CFG" ] || continue
  sed -i \
    -e "s/^mcc\s*=.*/mcc = ${MCC}/" \
    -e "s/^mnc\s*=.*/mnc = ${MNC}/" \
    "$CFG" 2>/dev/null || true
done

# ─── R. RDNSx (Rapid DNS Reverse Resolver) ──────────────────────────────────
echo "  Installing RDNSx..."
if dpkg-query -W rdnsx 2>/dev/null; then
  echo "    RDNSx already installed via APT."
elif apt-cache show rdnsx >/dev/null 2>&1; then
  apt-get install -y rdnsx
else
  if [ -d "${TELCOSEC_OPT}/rdnsx" ]; then
    cd "${TELCOSEC_OPT}/rdnsx"
    export CARGO_HOME=/usr/local/cargo
    export PATH="${CARGO_HOME}/bin:$PATH"
    if command -v cargo &>/dev/null; then
      cargo build --release 2>&1 | tail -5
      [ -f target/release/rdnsx ] && ln -sf "${TELCOSEC_OPT}/rdnsx/target/release/rdnsx" /usr/local/bin/rdnsx || true
    else
      echo "    WARNING: cargo not found. Skipping RDNSx compilation."
    fi
    chown -R telcosec:telcosec "${TELCOSEC_OPT}/rdnsx"
    cd /
  fi
fi

# ─── S. Broadband & ADSL Exploitation Tools ─────────────────────────────────
echo "  Installing Broadband & ADSL Exploitation Tools..."

# 1. Asleap (PPPoE / MS-CHAPv2 offline cracker)
if [ ! -d "${TELCOSEC_OPT}/asleap" ]; then
  git clone --depth 1 https://github.com/joswr1ght/asleap "${TELCOSEC_OPT}/asleap" 2>/dev/null || true
fi
if [ -d "${TELCOSEC_OPT}/asleap" ]; then
  cd "${TELCOSEC_OPT}/asleap"
  make -j"$(nproc)" 2>&1 | tail -5 || true
  [ -f asleap ] && ln -sf "${TELCOSEC_OPT}/asleap/asleap" /usr/local/bin/asleap || true
  [ -f genkeys ] && ln -sf "${TELCOSEC_OPT}/asleap/genkeys" /usr/local/bin/genkeys || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/asleap"
  cd /
fi

# 2. snmp-check (Kali Linux native SNMP enumerator)
if [ ! -f /usr/local/bin/snmp-check ]; then
  wget -q https://gitlab.com/kalilinux/packages/snmpcheck/-/raw/kali/master/snmpcheck-1.9.rb -O /usr/local/bin/snmp-check || true
  if [ -s /usr/local/bin/snmp-check ]; then
    chmod +x /usr/local/bin/snmp-check
  fi
fi

# 3. RouterSploit (Embedded device exploitation framework)
if [ ! -d "${TELCOSEC_OPT}/routersploit" ]; then
  git clone --depth 1 https://github.com/threat9/routersploit "${TELCOSEC_OPT}/routersploit" 2>/dev/null || true
fi
if [ -d "${TELCOSEC_OPT}/routersploit" ]; then
  cd "${TELCOSEC_OPT}/routersploit"
  pip3 install -r requirements.txt --break-system-packages 2>/dev/null || true
  cat > /usr/local/bin/routersploit << 'SCRIPT'
#!/bin/bash
python3 /opt/telcosec/routersploit/rsf.py "$@"
SCRIPT
  chmod +x /usr/local/bin/routersploit
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/routersploit"
  cd /
fi

# 4. DOCSIS config tool
if [ -d "${TELCOSEC_OPT}/docsis" ]; then
  cd "${TELCOSEC_OPT}/docsis"
  ./autogen.sh && ./configure && make -j"$(nproc)" 2>&1 | tail -5 || true
  make install || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/docsis"
  cd /
fi

# ─── T. Falcon GUI (LTE Network Analyzer) ──────────────────────────────────
echo "  Installing Falcon GUI..."
if [ -d "${TELCOSEC_OPT}/falcon" ]; then
  cd "${TELCOSEC_OPT}/falcon"
  mkdir -p build && cd build
  cmake .. -DCMAKE_BUILD_TYPE=Release 2>&1 | tail -3
  make -j"$(nproc)" 2>&1 | tail -5 || true
  [ -f falcon ] && ln -sf "${TELCOSEC_OPT}/falcon/build/falcon" /usr/local/bin/falcon || true
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/falcon"
  cd /
fi

# ─── U. TelcoSec ChiselControl Dashboard ──────────────────────────────────────
echo "  Configuring ChiselControl Dashboard..."
if [ -d "${TELCOSEC_OPT}/dashboard" ]; then
  chown -R telcosec:telcosec "${TELCOSEC_OPT}/dashboard"
fi

echo "=== Advanced Telecom Tools installation complete ==="
