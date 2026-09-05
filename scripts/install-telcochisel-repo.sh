#!/usr/bin/env bash
# =============================================================================
# install-telcochisel-repo.sh
# Adds the official TelcoChisel APT repository to Ubuntu 24.04 (Noble) systems.
# Enables installing TelcoChisel metapackages, SDR udev rules, and tools.
# =============================================================================

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== TelcoChisel Official APT Repository Installer ===${NC}"

if [ "$(id -u)" -ne 0 ]; then
  echo -e "${RED}ERROR: Please run as root or with sudo: sudo bash $0${NC}"
  exit 1
fi

TELCOSEC_URL="https://meta.telcosec.net"
TELCOSEC_KEY="/etc/apt/keyrings/telcochisel-archive-keyring.asc"
TELCOSEC_SOURCES="/etc/apt/sources.list.d/telcochisel.sources"
TELCOSEC_FPR="6326A34C15FEF05FBD63518B4325182E2F0D9DB9"

echo "--> Installing prerequisites..."
apt-get update -qq
apt-get install -y -qq curl gnupg ca-certificates

echo "--> Fetching repository signing key..."
mkdir -p /etc/apt/keyrings
curl -fsSL "${TELCOSEC_URL}/public.gpg" -o "$TELCOSEC_KEY"

echo "--> Verifying GPG signing key fingerprint..."
ACTUAL_FPR=$(gpg --show-keys --with-colons "$TELCOSEC_KEY" 2>&1 | awk -F: '$1=="fpr"{print $10; exit}')

if [ -z "$ACTUAL_FPR" ]; then
  echo -e "${RED}ERROR: Could not read fingerprint from downloaded key.${NC}"
  rm -f "$TELCOSEC_KEY"
  exit 1
fi

if [ "$ACTUAL_FPR" != "$TELCOSEC_FPR" ]; then
  echo -e "${RED}ERROR: Key fingerprint mismatch!${NC}"
  echo "Expected: $TELCOSEC_FPR"
  echo "Actual:   $ACTUAL_FPR"
  rm -f "$TELCOSEC_KEY"
  exit 1
fi

chmod 0644 "$TELCOSEC_KEY"
echo -e "${GREEN}✓ Key verified successfully: $ACTUAL_FPR${NC}"

echo "--> Configuring APT source list..."
cat > "$TELCOSEC_SOURCES" << EOF
Types: deb
URIs: ${TELCOSEC_URL}
Suites: noble
Components: main
Signed-By: ${TELCOSEC_KEY}
EOF

chmod 0644 "$TELCOSEC_SOURCES"

echo "--> Refreshing package indices..."
apt-get update

echo -e "\n${GREEN}=== TelcoChisel Repository Successfully Installed! ===${NC}"
echo -e "You can now install official TelcoChisel metapackages:"
echo -e "  ${YELLOW}sudo apt install telcochisel-meta-full${NC}      # Full suite (All tools, drivers, and tuning)"
echo -e "  ${YELLOW}sudo apt install telcochisel-hardware-sdr${NC}   # SDR udev rules, blacklists & USB tuning"
echo -e "  ${YELLOW}sudo apt install telcochisel-base${NC}           # Low-latency RT limits & SCTP autoloading"
echo -e "  ${YELLOW}sudo apt install telcochisel-tools-sdr${NC}     # Core SDR DSP tools (GNU Radio, GQRX, etc.)"
echo -e "  ${YELLOW}sudo apt install telcochisel-tools-sim${NC}     # Smartcard & SIM provisioning tools"
echo ""
