#!/bin/bash
set -e

echo "=== Installing Security Tools ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wireshark tshark \
    nmap \
    macchanger vlan asleap freeradius-utils hashcat john pppoe nikto gobuster snmpcheck \
    lksctp-tools libsctp-dev libglib2.0-dev \
    sipsak \
    python3-pip python3-venv \
    wireguard twinkle baresip
fi

# Install SIPVicious and Scapy
pip3 install sipvicious scapy --break-system-packages

# Compile and Install sctpscan
echo "Compiling and installing sctpscan..."
sudo mkdir -p /opt/telcosec
[ -d /opt/telcosec/sctpscan ] || sudo git clone --depth 1 https://github.com/philpraxis/sctpscan.git /opt/telcosec/sctpscan
cd /opt/telcosec/sctpscan
# Patch 1: Remove legacy STREAMS header (dropped in glibc 2.30 / Ubuntu 24.04)
sudo sed -i '/#include <stropts.h>/d' sctpscan.c
# Patch 2: Fix old BSD two-arg setpgrp(0, getpid()) — modern POSIX takes no args
sudo sed -i 's/setpgrp(0, getpid())/setpgrp()/g' sctpscan.c
# Patch 3: Add sys/ioctl.h for ioctl() (no longer pulled in transitively)
sudo sed -i '/#include <sys\/socket.h>/a #include <sys\/ioctl.h>' sctpscan.c
# Suppress harmless pointer-to-int-cast and unused-result warnings
gcc -O2 -Wno-pointer-to-int-cast -Wno-unused-result \
  sctpscan.c -o sctpscan $(pkg-config --cflags --libs glib-2.0)
sudo cp sctpscan /usr/local/bin/
sudo chmod 755 /usr/local/bin/sctpscan
sudo chown -R telcosec:telcosec /opt/telcosec/sctpscan
cd -

# ─── Python 2.7 from source (SigPloit is Python 2-only; not in Ubuntu 24.04 repos) ───
# Ubuntu 24.04 (Noble) ships only Python 3.x — Python 2 was dropped from the
# official repos. SigPloit targets raw SS7/Diameter/GTP sockets and its byte-
# level packet construction is semantically tied to Python 2 str-as-bytes; a
# mechanical 2to3 port would silently corrupt protocol payloads. Building the
# final upstream Python 2 release (2.7.18) from source into /opt/telcosec/python2
# keeps it isolated and avoids touching the system python3 symlink.
PY2_PREFIX=/opt/telcosec/python2
if [ ! -x "${PY2_PREFIX}/bin/python2.7" ]; then
  echo "Building Python 2.7.18 from source..."
  mkdir -p /tmp/py2-build && cd /tmp/py2-build
  wget -q https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz
  tar -xzf Python-2.7.18.tgz
  cd Python-2.7.18

  # OpenSSL 3.x (Ubuntu 24.04) removed SSLv3_method and other APIs that
  # CPython 2.7's Modules/_ssl.c uses — building _ssl fails unconditionally.
  # Disable it via Setup.dist so the build doesn't abort; SigPloit's own
  # requirements.txt has no SSL dependency (pure socket/SCTP transport).
  sed -i 's/^SSL=/\#SSL=/' Modules/Setup.dist 2>/dev/null || true

  ./configure \
    --prefix="${PY2_PREFIX}" \
    --enable-unicode=ucs4 \
    --with-ensurepip=install \
    --quiet 2>&1 | tail -5

  make -j"$(nproc)" 2>&1 | tail -10
  make install 2>&1 | tail -5
  cd / && rm -rf /tmp/py2-build
  echo "Python 2.7.18 installed → ${PY2_PREFIX}/bin/python2.7"
else
  echo "Python 2.7 already present, skipping build."
fi

# ─── SigPloit (SS7/Diameter/GTP Exploitation Framework) ─────────────────────
echo "Installing SigPloit..."
[ -d /opt/telcosec/sigploit ] || \
  git clone --depth 1 https://github.com/SigPloiter/SigPloit.git /opt/telcosec/sigploit

# Install SigPloit's Python 2 dependencies into the vendored python2 interpreter.
# pysctp builds a C extension against libsctp-dev (present from 00-packages).
"${PY2_PREFIX}/bin/pip2" install \
  colorama pyfiglet termcolor configobj 'IPy==0.83' pysctp \
  2>/dev/null || \
"${PY2_PREFIX}/bin/python2.7" -m pip install \
  colorama pyfiglet termcolor configobj 'IPy==0.83' pysctp

chown -R telcosec:telcosec /opt/telcosec/sigploit "${PY2_PREFIX}"

# Install Diafuzzer (Orange Diameter Fuzzer)
echo "Installing Diafuzzer..."
[ -d /opt/telcosec/diafuzzer ] || sudo git clone --depth 1 https://github.com/Orange-OpenSource/diafuzzer.git /opt/telcosec/diafuzzer || true
if [ -f /opt/telcosec/diafuzzer/requirements.txt ]; then
  pip3 install -r /opt/telcosec/diafuzzer/requirements.txt --break-system-packages || true
fi
sudo chown -R telcosec:telcosec /opt/telcosec/diafuzzer

# Wireshark permissions (dpkg-reconfigure already done in 00-install-all-packages.sh)
if [ ! -f /tmp/.packages-installed ]; then
  echo "wireshark-common wireshark-common/install-syscap boolean true" | sudo debconf-set-selections
  sudo DEBIAN_FRONTEND=noninteractive dpkg-reconfigure wireshark-common
fi
if ! getent group wireshark >/dev/null; then
  sudo groupadd -r wireshark
fi
sudo usermod -a -G wireshark telcosec || true

# Install telecom-specific wordlists (vendored from TelcoSec-Tools/TelcoSec-Wordlists)
echo "Installing TelcoSec wordlists..."
sudo mkdir -p /usr/share/wordlists/telecom
sudo cp -r /tmp/wordlists/. /usr/share/wordlists/telecom/
sudo find /usr/share/wordlists/telecom -type f -exec chmod 644 {} +
sudo find /usr/share/wordlists/telecom -type d -exec chmod 755 {} +
echo "Wordlists installed: $(find /usr/share/wordlists/telecom -type f | wc -l) files"

# Install wordlist helper scripts as system tools
echo "Installing wordlist helper scripts..."
sudo install -m 755 /tmp/wordlists/scripts/apn_permutator.py  /usr/local/bin/telcosec-apn-permutator
sudo install -m 755 /tmp/wordlists/scripts/imsi_generator.py  /usr/local/bin/telcosec-imsi-generator
