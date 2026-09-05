#!/usr/bin/env bash
set -euo pipefail

KEY_EMAIL="repo@telcosec.net"
KEY_NAME="TelcoSec Package Signing Key"
KEY_COMMENT="TelcoChisel Official APT Repository"

mkdir -p ~/.gnupg
chmod 700 ~/.gnupg
echo "allow-loopback-pinentry" >> ~/.gnupg/gpg-agent.conf
echo "pinentry-mode loopback" >> ~/.gnupg/gpg.conf
gpgconf --reload gpg-agent 2>/dev/null || true

KEY_IMPORTED=0
if [ -n "${GPG_PRIVATE_KEY:-}" ]; then
    if echo "${GPG_PRIVATE_KEY}" | gpg --batch --import 2>/dev/null; then
        echo "[+] Successfully imported GPG_PRIVATE_KEY directly."
        KEY_IMPORTED=1
    elif echo "${GPG_PRIVATE_KEY}" | base64 -d 2>/dev/null | gpg --batch --import 2>/dev/null; then
        echo "[+] Successfully imported base64-decoded GPG_PRIVATE_KEY."
        KEY_IMPORTED=1
    fi
fi

if [ "${KEY_IMPORTED}" -eq 0 ]; then
    echo "[!] Generating signing key for ${KEY_EMAIL} in CI..."
    gpg --batch --generate-key <<EOF
%no-protection
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: ${KEY_NAME}
Name-Comment: ${KEY_COMMENT}
Name-Email: ${KEY_EMAIL}
Expire-Date: 2y
%commit
EOF
    echo "[+] Generated signing key for ${KEY_EMAIL}."
fi
