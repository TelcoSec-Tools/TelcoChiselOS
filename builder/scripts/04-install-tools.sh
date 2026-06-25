#!/bin/bash
set -e

echo "=== Installing Security Tools ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  # shellcheck source=lib/packages.sh
  source "${SCRIPT_DIR}/lib/packages.sh"
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKGS_TOOLS[@]}"
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

# ─── SigPloit (SS7/Diameter/GTP Exploitation Framework) ─────────────────────
# Python 2.7 is EOL and building from source is slow. SigPloit is containerized.
echo "Setting up SigPloit Docker environment..."
sudo mkdir -p /opt/telcosec/sigploit
[ -d /opt/telcosec/sigploit/.git ] || \
  sudo git clone --depth 1 https://github.com/SigPloiter/SigPloit.git /opt/telcosec/sigploit

cat << 'EOF' | sudo tee /opt/telcosec/sigploit/Dockerfile
FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y python2 python-pip libsctp-dev git && rm -rf /var/lib/apt/lists/*
# pip2 needs to be curl'd or apt-get install python-pip in 20.04 (yes, python-pip exists in 20.04)
RUN pip2 install colorama pyfiglet termcolor configobj 'IPy==0.83' pysctp
WORKDIR /app
ENTRYPOINT ["python2", "sigploit.py"]
EOF

cat << 'EOF' | sudo tee /usr/local/bin/sigploit
#!/bin/bash
cd /opt/telcosec/sigploit
if ! docker image inspect sigploit:latest >/dev/null 2>&1; then
  echo "Building SigPloit Docker image for the first time..."
  docker build -t sigploit:latest .
fi
# Run interactively with host networking so SCTP sockets bind directly
exec docker run -it --rm --net=host -v "$PWD:/app" sigploit:latest "$@"
EOF
sudo chmod +x /usr/local/bin/sigploit
sudo chown -R telcosec:telcosec /opt/telcosec/sigploit

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

# Install telecom-specific wordlists
echo "Installing TelcoSec wordlists..."
sudo mkdir -p /usr/share/wordlists/telecom
if [ -d "/tmp/wordlists" ] && [ "$(ls -A /tmp/wordlists 2>/dev/null)" ]; then
  sudo cp -r /tmp/wordlists/. /usr/share/wordlists/telecom/
else
  sudo git clone --depth 1 https://github.com/TelcoSec-Tools/TelcoSec-Wordlists /usr/share/wordlists/telecom/ 2>/dev/null || true
fi
sudo find /usr/share/wordlists/telecom -type f -exec chmod 644 {} + 2>/dev/null || true
sudo find /usr/share/wordlists/telecom -type d -exec chmod 755 {} + 2>/dev/null || true
echo "Wordlists installed: $(find /usr/share/wordlists/telecom -type f 2>/dev/null | wc -l) files"

# Install wordlist helper scripts as system tools
echo "Installing wordlist helper scripts..."
[ -f /usr/share/wordlists/telecom/scripts/apn_permutator.py ] && sudo install -m 755 /usr/share/wordlists/telecom/scripts/apn_permutator.py  /usr/local/bin/telcosec-apn-permutator || true
[ -f /usr/share/wordlists/telecom/scripts/imsi_generator.py ] && sudo install -m 755 /usr/share/wordlists/telecom/scripts/imsi_generator.py  /usr/local/bin/telcosec-imsi-generator || true
