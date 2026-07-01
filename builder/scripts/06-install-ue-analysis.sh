#!/bin/bash
set -e

echo "=== Installing UE Analysis, Baseband & SIMtrace Tools ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/record-tool.sh
source "${SCRIPT_DIR}/lib/record-tool.sh"

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  # shellcheck source=lib/packages.sh
  source "${SCRIPT_DIR}/lib/packages.sh"
  sudo apt-get update
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PKGS_UE_ANALYSIS[@]}"
fi

# shellcheck source=lib/pip-retry.sh
source "${SCRIPT_DIR}/lib/pip-retry.sh"

# Create tools root directory
sudo mkdir -p /opt/telcosec
sudo chown -R telcosec:telcosec /opt/telcosec

# ─── Clone all repos in parallel ────────────────────────────────────────────
echo "Cloning all UE analysis repositories in parallel..."
cd /opt/telcosec

if [ ! -d firmwire ]; then git clone --depth 1 https://github.com/FirmWire/FirmWire.git firmwire & PID_FIRMWIRE=$!; else PID_FIRMWIRE=""; fi
if [ ! -d balong-flash ]; then git clone --depth 1 https://github.com/forth32/balongflash.git balong-flash & PID_BALONG_FLASH=$!; else PID_BALONG_FLASH=""; fi
if [ ! -d balongtool ]; then git clone --depth 1 https://github.com/forth32/balong-nvtool.git balongtool & PID_BALONGTOOL=$!; else PID_BALONGTOOL=""; fi
if [ ! -d mtkclient ]; then git clone --depth 1 https://github.com/bkerler/mtkclient.git mtkclient & PID_MTK=$!; else PID_MTK=""; fi
if [ ! -d pysim ]; then git clone --depth 1 https://github.com/osmocom/pysim.git pysim & PID_PYSIM=$!; else PID_PYSIM=""; fi
if [ ! -d lpac ]; then git clone --depth 1 https://github.com/estkme-group/lpac.git lpac & PID_LPAC=$!; else PID_LPAC=""; fi
if [ ! -d simtrace2 ]; then git clone --depth 1 https://github.com/osmocom/simtrace2.git simtrace2 & PID_SIMTRACE2=$!; else PID_SIMTRACE2=""; fi
if [ ! -d simurai ]; then git clone --recurse-submodules --shallow-submodules https://github.com/tomasz-lisowski/simurai.git simurai & PID_SIMURAI=$!; else PID_SIMURAI=""; fi

# Wait for all clones to complete
echo "Waiting for all git clones to finish..."
wait $PID_FIRMWIRE $PID_BALONG_FLASH $PID_BALONGTOOL $PID_MTK $PID_PYSIM $PID_LPAC $PID_SIMTRACE2 $PID_SIMURAI 2>/dev/null || true
echo "All repositories checked/cloned."

# Download SIMtrace 2 firmware binaries into the newly cloned directory
echo "Downloading SIMtrace 2 firmware binaries..."
sudo mkdir -p /opt/telcosec/simtrace2/firmware
sudo wget -qO /opt/telcosec/simtrace2/firmware/simtrace-trace-dfu.bin https://ftp.osmocom.org/binaries/simtrace2/firmware/latest/simtrace-trace-dfu-latest.bin || true
sudo wget -qO /opt/telcosec/simtrace2/firmware/simtrace-cardem-dfu.bin https://ftp.osmocom.org/binaries/simtrace2/firmware/latest/simtrace-cardem-dfu-latest.bin || true
sudo chmod 644 /opt/telcosec/simtrace2/firmware/*.bin || true


# ─── Build/install sequentially ─────────────────────────────────────────────

# FirmWire (Samsung Shannon & MediaTek baseband emulation/fuzzing)
echo "Installing FirmWire..."
cd /opt/telcosec/firmwire

# FirmWire's util/param.py imports Mapping from collections, an alias removed
# in Python 3.10+ (the venv uses the system interpreter, which is 3.12 on
# Ubuntu 24.04, so this raises ImportError at runtime without this patch).
grep -rl "from collections import Mapping" --include="*.py" . 2>/dev/null | \
  xargs -r sed -i 's/from collections import Mapping/from collections.abc import Mapping/'

rm -rf venv
python3 -m venv venv
./venv/bin/pip install --upgrade pip
./venv/bin/pip install "Cython<3.0.0" setuptools wheel

# Workaround for python-rocksdb build failure on RocksDB 7.x/8.x (backupable_db.h removed)
if [ ! -f /usr/include/rocksdb/utilities/backupable_db.h ]; then
  echo "=== Creating compatibility header backupable_db.h for RocksDB ==="
  sudo mkdir -p /usr/include/rocksdb/utilities/
  cat << 'EOF' | sudo tee /usr/include/rocksdb/utilities/backupable_db.h
#pragma once
#include "rocksdb/utilities/backup_engine.h"
namespace rocksdb {
  typedef BackupEngineOptions BackupableDBOptions;
  typedef BackupEngine BackupableDB;
  typedef BackupInfo BackupableDBInfo;
}
EOF
fi

echo "=== Downloading and patching python-rocksdb for RocksDB 7+/8+ ==="
mkdir -p /tmp/rocksdb-build
cd /tmp/rocksdb-build
/opt/telcosec/firmwire/venv/bin/pip download --no-binary :all: --no-deps rocksdb
tar -xzf rocksdb-*.tar.gz
cd rocksdb-*/

# Patch 1: filter_policy_wrapper.hpp — add missing virtual method overrides (RocksDB 7+)
python3 -c "
with open('rocksdb/cpp/filter_policy_wrapper.hpp', 'r') as f:
    content = f.read()

replacement = '''            virtual const char* CompatibilityName() const override {
                return this->name.c_str();
            }

            virtual rocksdb::FilterBitsBuilder* GetBuilderWithContext(
                const rocksdb::FilterBuildingContext&) const override {
                return nullptr;
            }

            virtual rocksdb::FilterBitsReader* GetFilterBitsReader(
                const rocksdb::Slice&) const override {
                return nullptr;
            }

            virtual const char* Name() const {'''

new_content = content.replace('            virtual const char* Name() const {', replacement)
with open('rocksdb/cpp/filter_policy_wrapper.hpp', 'w') as f:
    f.write(new_content)
"

# Patch 2: _rocksdb.pyx & options.pxd & table_factory.pxd & filter_policy.pxd
python3 - <<'PYEOF'
import re, pathlib

# Patch _rocksdb.pyx properties
pyx = pathlib.Path('rocksdb/_rocksdb.pyx').read_text()

# Remove properties from ColumnFamilyOptions/Options
for prop in ['purge_redundant_kvs_while_flush', 'rate_limit_delay_max_milliseconds', 'soft_rate_limit', 'hard_rate_limit', 'max_mem_compaction_level', 'skip_log_error_on_recovery']:
    pyx = re.sub(
        r'\s*property ' + prop + r':\s*'
        r'def __get__\(self\):.*?'
        r'def __set__\(self, \w+\):.*?self\.(copts|opts)\.' + prop + r'\s*=\s*\w+\b[^\n]*\n',
        '\n',
        pyx,
        flags=re.DOTALL
    )

# Comment out hash_index_allow_collision and block_cache_compressed assignments in BlockBasedTableFactory
pyx = pyx.replace(
    '        if hash_index_allow_collision:\n            table_options.hash_index_allow_collision = True\n        else:\n            table_options.hash_index_allow_collision = False',
    '        # disabled hash_index_allow_collision for RocksDB 7+'
)
pyx = pyx.replace(
    '        if block_cache_compressed is not None:\n            table_options.block_cache_compressed = block_cache_compressed.get_cache()',
    '        # disabled block_cache_compressed for RocksDB 7+'
)

# Patch PyBloomFilterPolicy in _rocksdb.pyx
pyx = pyx.replace(
    '    def create_filter(self, keys):\n        cdef string dst\n        cdef vector[Slice] c_keys\n\n        for key in keys:\n            c_keys.push_back(bytes_to_slice(key))\n\n        self.policy.get().CreateFilter(\n            vector_data(c_keys),\n            <int>c_keys.size(),\n            cython.address(dst))\n\n        return string_to_bytes(dst)',
    '    def create_filter(self, keys):\n        raise NotImplementedError("create_filter is not supported in RocksDB 7+")'
)
pyx = pyx.replace(
    '    def key_may_match(self, key, filter_):\n        return self.policy.get().KeyMayMatch(\n            bytes_to_slice(key),\n            bytes_to_slice(filter_))',
    '    def key_may_match(self, key, filter_):\n        raise NotImplementedError("key_may_match is not supported in RocksDB 7+")'
)

pathlib.Path('rocksdb/_rocksdb.pyx').write_text(pyx)
print("Patched _rocksdb.pyx successfully")

# Patch table_factory.pxd
pxd = pathlib.Path('rocksdb/table_factory.pxd').read_text()
pxd = pxd.replace('        cpp_bool hash_index_allow_collision\n', '')
pxd = pxd.replace('        shared_ptr[Cache] block_cache_compressed\n', '')
pathlib.Path('rocksdb/table_factory.pxd').write_text(pxd)
print("Patched table_factory.pxd successfully")

# Patch filter_policy.pxd
f_pxd = pathlib.Path('rocksdb/filter_policy.pxd').read_text()
f_pxd = f_pxd.replace('        void CreateFilter(const Slice*, int, string*) nogil except+\n', '')
f_pxd = f_pxd.replace('        cpp_bool KeyMayMatch(const Slice&, const Slice&) nogil except+\n', '')
pathlib.Path('rocksdb/filter_policy.pxd').write_text(f_pxd)
print("Patched filter_policy.pxd successfully")

# Patch setup.py to use C++17 (required by modern RocksDB headers on Ubuntu 24.04 noble)
setup_py = pathlib.Path('setup.py').read_text()
setup_py = setup_py.replace("'-std=c++11'", "'-std=c++17'")
pathlib.Path('setup.py').write_text(setup_py)
print("Patched setup.py to compile with C++17 successfully")
PYEOF

# Remove the pre-compiled C++ source file so setuptools/pip is forced
# to run Cython to regenerate _rocksdb.cpp from our patched _rocksdb.pyx.
rm -f rocksdb/_rocksdb.cpp

/opt/telcosec/firmwire/venv/bin/pip install --no-build-isolation .
cd /opt/telcosec/firmwire
rm -rf /tmp/rocksdb-build

./venv/bin/pip install -r requirements.txt

# avatar2 (pulled in by requirements.txt) imports `from pkg_resources import
# packaging`. pkg_resources lives in setuptools, which pip may remove or
# downgrade during dependency resolution on Python 3.12 venvs. Reinstalling
# after requirements.txt guarantees it survives.
./venv/bin/pip install --upgrade setuptools

# The patched python-rocksdb build (the most fragile step in this install —
# custom Cython patches against whatever RocksDB headers Ubuntu ships) is the
# best available proxy for "did the whole FirmWire venv actually come together."
FIRMWIRE_ROCKSDB=$(find /opt/telcosec/firmwire/venv/lib -maxdepth 3 -iname 'rocksdb*' 2>/dev/null | head -1)
record_tool "FirmWire" "$FIRMWIRE_ROCKSDB" "baseband"

# QCSuper (Qualcomm DIAG port traffic capture and Wireshark dissection)
# Installed from PyPI — QCSuper no longer ships a requirements.txt in the repo.
# Use pip_retry (defined above) instead of a bare pip3 call: this is a network
# install with no retry/guard, so a transient PyPI/SSL failure would abort the
# rest of the script under `set -e`.
echo "Installing QCSuper..."
pip_retry install --upgrade qcsuper --break-system-packages
record_tool "QCSuper" "$(command -v qcsuper 2>/dev/null)" "baseband"

# Balong-Flash & Balongtool (Huawei Balong modem flashing and engineering)
# Non-critical: guarded so a Makefile failure doesn't abort the whole script.
# A successful `make` only produces a binary in the source tree — neither
# tool was ever symlinked onto PATH, so even a successful build was
# unreachable as a command. Guard the symlink on the binary actually existing.
echo "Compiling Huawei Balong Flashing Tools..."
cd /opt/telcosec/balong-flash
make || echo "WARNING: balong-flash make failed — tool will be unavailable"
BALONG_FLASH_BIN=$(find . -maxdepth 1 -type f -executable -iname 'balong-flash*' 2>/dev/null | head -1)
[ -n "$BALONG_FLASH_BIN" ] && sudo ln -sf "/opt/telcosec/balong-flash/${BALONG_FLASH_BIN#./}" /usr/local/bin/balong-flash
record_tool "balong-flash" "/usr/local/bin/balong-flash" "baseband"

cd /opt/telcosec/balongtool
make || echo "WARNING: balongtool make failed — tool will be unavailable"
BALONGTOOL_BIN=$(find . -maxdepth 1 -type f -executable -iname 'balongtool*' -o -maxdepth 1 -type f -executable -iname 'nvtool*' 2>/dev/null | head -1)
[ -n "$BALONGTOOL_BIN" ] && sudo ln -sf "/opt/telcosec/balongtool/${BALONGTOOL_BIN#./}" /usr/local/bin/balongtool
record_tool "balongtool" "/usr/local/bin/balongtool" "baseband"

# MTKClient (MediaTek BootROM bypass, flashing and partitioning)
echo "Installing MediaTek client (mtkclient)..."
cd /opt/telcosec/mtkclient
# MTKClient's requirements.txt lists both 'keystone-engine' (the assembler, needed)
# and bare 'keystone' (OpenStack identity service, a stale upstream mistake). The
# OpenStack package pulls in the entire oslo.* stack which then tries to upgrade
# apt-managed typing-extensions — causing a pip RECORD-file abort. Strip it out.
grep -v '^keystone[[:space:]]*$' requirements.txt > /tmp/mtkclient-req.txt
sudo_pip_retry install -r /tmp/mtkclient-req.txt --break-system-packages
sudo_pip_retry install --break-system-packages .
record_tool "mtkclient" "$(command -v mtk 2>/dev/null)" "baseband"

# pySim (SIM/USIM smartcard programming and operations)
echo "Installing Osmocom pySim smartcard utility..."
cd /opt/telcosec/pysim
sudo_pip_retry install -r requirements.txt --break-system-packages
sudo_pip_retry install --break-system-packages .
# pySim-shell.py is a standalone script in the repo, not a pip console_script
# entry point — `pip install .` only installs the importable pySim library.
# Symlink it onto PATH so launchers can invoke it as a plain command.
chmod +x pySim-shell.py pySim-prog.py pySim-read.py 2>/dev/null || true
ln -sf /opt/telcosec/pysim/pySim-shell.py /usr/local/bin/pySim-shell
record_tool "pySim" "/usr/local/bin/pySim-shell" "sim"

# lpac (eSIM Local Profile Assistant tool for profile downloads & management)
# Guarded like its sibling tools above — cmake/make previously ran unguarded
# under `set -e`, so a build failure here would abort the rest of the script
# (FirmWire, MTKClient, pySim, simtrace2, SIMurai never run). Non-fatal now.
echo "Compiling and installing lpac eSIM profile manager..."
cd /opt/telcosec/lpac
rm -rf build && mkdir build && cd build
if cmake -DCMAKE_BUILD_TYPE=Release .. && make -j"$(nproc)"; then
  sudo cp src/lpac /usr/local/bin/lpac
  sudo chmod 755 /usr/local/bin/lpac
else
  echo "WARNING: lpac build failed — tool will be unavailable"
fi
record_tool "lpac" "/usr/local/bin/lpac" "sim"

# ─── Build libosmocore from source ──────────────────────────────────────────
# Ubuntu 24.04 ships libosmocore 1.7.0; simtrace2 host requires >= 1.11.0.
# Install directly into the multiarch path so pkg-config finds it without
# any PKG_CONFIG_PATH tricks — this overwrites the system 1.7.0 .pc file.
echo "Building libosmocore from source (Ubuntu 24.04 ships 1.7.0, need >= 1.11.0)..."

# Install build deps unconditionally — these may be missing if the build is
# resuming from a cached chroot where 00-install-all-packages.sh was skipped.
apt-get install -y liburing-dev libtalloc-dev libgnutls28-dev autoconf-archive

rm -rf /tmp/libosmocore
git clone --depth 1 https://gitea.osmocom.org/osmocom/libosmocore.git /tmp/libosmocore
cd /tmp/libosmocore
autoreconf -fi
./configure \
    --prefix=/usr \
    --libdir=/usr/lib/x86_64-linux-gnu \
    --disable-doxygen \
    --disable-tests
make -j$(nproc)
sudo make install
# git-version-gen returns UNKNOWN on shallow clones (no tag history).
# libosmocore installs a family of .pc files (libosmocore, libosmosim,
# libosmogsm, libosmovty, libosmocoding, libosmogb, …) — patch them all.
echo "=== Patching all libosmo*.pc files: UNKNOWN → 1.11.0 (shallow clone has no tags) ==="
find /usr/lib/x86_64-linux-gnu/pkgconfig/ -name 'libosmo*.pc' | while read -r pc; do
    if grep -q 'UNKNOWN' "$pc" 2>/dev/null; then
        sudo sed -i '/^Version:/c\Version: 1.11.0' "$pc"
        echo "  Patched: $pc"
    fi
done
sudo ldconfig
rm -rf /tmp/libosmocore

# Verify all osmocom libs that simtrace2 configure checks satisfy >= 1.11.0
for lib in libosmocore libosmosim libosmogsm libosmovty; do
    VER=$(pkg-config --modversion "$lib" 2>/dev/null || echo "NOT_FOUND")
    if [ "$VER" = "NOT_FOUND" ] || [ "$VER" = "UNKNOWN" ]; then
        echo "ERROR: $lib reports '$VER' — simtrace2 configure will fail"
        exit 1
    fi
    pkg-config --atleast-version=1.11.0 "$lib" || {
        echo "ERROR: $lib $VER is < 1.11.0"
        exit 1
    }
    echo "  OK: $lib $VER"
done
echo "=== All osmocom libs passed version check ==="
record_tool "libosmocore" "/usr/lib/x86_64-linux-gnu/pkgconfig/libosmocore.pc" "baseband"

# SIMtrace 2 host software (simtrace2-list, simtrace2-sniff, simtrace2-cardem-pcsc)
echo "Compiling and installing SIMtrace 2 host utilities..."
cd /opt/telcosec/simtrace2/host
autoreconf -fi
./configure
make -j$(nproc)
sudo make install
sudo ldconfig
record_tool "simtrace2" "$(command -v simtrace2-list 2>/dev/null)" "sim"

# SIMurai — software SIM emulator + virtual PC/SC IFD driver
# Provides swsim (emulated SIM card that speaks ISO-7816 over TCP/IP) and
# swicc-pcsc (a pcscd IFD handler that bridges swsim into the PC/SC stack).
echo "Compiling SIMurai software SIM platform..."
if [ -d /opt/telcosec/simurai/swsim ]; then
    cd /opt/telcosec/simurai/swsim
    make main -j"$(nproc)" || echo "WARNING: swsim build failed — simurai will be unavailable"
    if [ -f build/swsim.elf ]; then
        sudo install -m 755 build/swsim.elf /usr/local/bin/simurai
    fi

    cd /opt/telcosec/simurai/swicc-pcsc
    make main -j"$(nproc)" && sudo make install \
        || echo "WARNING: swicc-pcsc build/install failed"
else
    echo "WARNING: simurai clone missing — skipping SIMurai build"
fi
record_tool "SIMurai" "/usr/local/bin/simurai" "sim"

# Clean up build objects and update ownership
cd /opt/telcosec
sudo chown -R telcosec:telcosec /opt/telcosec

echo "=== All Baseband, SIM, and UE Analysis Tools Installed Successfully ==="
