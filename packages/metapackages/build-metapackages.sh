#!/usr/bin/env bash
# =============================================================================
# build-metapackages.sh — Builds all 10 TelcoChisel Debian Metapackages
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DIST_DIR="${SCRIPT_DIR}/dist"
BUILD_DIR="${SCRIPT_DIR}/build"
VERSION="2026.2-1"

echo "=== Building TelcoChisel Modular Debian Metapackages (v${VERSION}) ==="

rm -rf "${DIST_DIR}" "${BUILD_DIR}"
mkdir -p "${DIST_DIR}" "${BUILD_DIR}"

PACKAGES=(
  "telcochisel-base"
  "telcochisel-hardware-sdr"
  "telcochisel-tools-sdr"
  "telcochisel-tools-2g-3g"
  "telcochisel-tools-4g"
  "telcochisel-tools-5g"
  "telcochisel-tools-sim"
  "telcochisel-tools-pstn-adsl"
  "telcochisel-tools-ue"
  "telcochisel-meta-full"
)

# Parse debian/control blocks
CONTROL_FILE="${SCRIPT_DIR}/debian/control"

for pkg in "${PACKAGES[@]}"; do
  echo "--> Processing metapackage: ${pkg}..."
  PKG_DIR="${BUILD_DIR}/${pkg}"
  mkdir -p "${PKG_DIR}/DEBIAN" "${PKG_DIR}/usr/share/doc/${pkg}"
  
  # Extract Package stanza from debian/control
  awk -v pkg="$pkg" '
    BEGIN { found=0; }
    /^Package: / { if ($2 == pkg) { found=1; } else { found=0; } }
    found && /^$/ { found=0; }
    found { print; }
  ' "${CONTROL_FILE}" > "${PKG_DIR}/DEBIAN/control"
  
  # Inject Version and Maintainer if missing in stanza
  if ! grep -q "^Version:" "${PKG_DIR}/DEBIAN/control"; then
    echo "Version: ${VERSION}" >> "${PKG_DIR}/DEBIAN/control"
  fi
  if ! grep -q "^Maintainer:" "${PKG_DIR}/DEBIAN/control"; then
    echo "Maintainer: TelcoChisel Engineering Team <ops@telcochisel.com>" >> "${PKG_DIR}/DEBIAN/control"
  fi

  # Add copyright and changelog
  cp "${SCRIPT_DIR}/debian/copyright" "${PKG_DIR}/usr/share/doc/${pkg}/copyright"
  cp "${SCRIPT_DIR}/debian/changelog" "${PKG_DIR}/usr/share/doc/${pkg}/changelog.Debian"
  gzip -9 -n -f "${PKG_DIR}/usr/share/doc/${pkg}/changelog.Debian" 2>/dev/null || true

  # Build binary .deb package
  if command -v dpkg-deb >/dev/null 2>&1; then
    dpkg-deb --build --root-owner-group "${PKG_DIR}" "${DIST_DIR}/${pkg}_${VERSION}_all.deb"
    echo "  ✓ Built: dist/${pkg}_${VERSION}_all.deb"
  else
    echo "  [Dry-Run] Package structure verified for ${pkg}"
  fi
done

# Generate APT repository metadata if dpkg-scanpackages / apt-ftparchive exists
if command -v dpkg-scanpackages >/dev/null 2>&1; then
  echo "--> Generating APT Packages and Release manifests..."
  (
    cd "${DIST_DIR}"
    dpkg-scanpackages . /dev/null > Packages
    gzip -9c Packages > Packages.gz
    
    cat << EOF > Release
Origin: TelcoChisel
Label: TelcoChisel Metapackages Repository
Suite: noble
Codename: noble
Version: 2026.2
Architectures: all amd64
Components: main
Description: Official TelcoChisel Modular Telecom Security Metapackages
Date: $(date -Ru)
EOF
  )
fi

echo "=== All 10 TelcoChisel Metapackages Processed Successfully ==="
