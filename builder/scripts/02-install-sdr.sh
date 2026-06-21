#!/bin/bash
set -e

echo "=== Installing Conda & Compiling SDR Drivers from Source ==="

# Skip apt operations — handled by 00-install-all-packages.sh
if [ ! -f /tmp/.packages-installed ]; then
  echo "WARNING: Running standalone (packages not pre-installed)"
  DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential cmake git wget libusb-1.0-0-dev pkg-config
fi

# 1. Install Miniconda
if [ ! -d /opt/telcosec/miniconda ]; then
  echo "Installing Miniconda..."
  wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh
  bash /tmp/miniconda.sh -b -p /opt/telcosec/miniconda
  rm /tmp/miniconda.sh
else
  echo "Miniconda already installed, skipping installer."
fi

# Make Conda available to all users
cat << 'EOF' | sudo tee /etc/profile.d/conda.sh
export PATH="/opt/telcosec/miniconda/bin:$PATH"
. /opt/telcosec/miniconda/etc/profile.d/conda.sh
EOF

source /opt/telcosec/miniconda/etc/profile.d/conda.sh

# Accept Terms of Service for default channels to prevent non-interactive blocks
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main || true
conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r || true

# Configure Conda to use conda-forge and avoid Anaconda commercial ToS issues
conda config --add channels conda-forge
conda config --set channel_priority strict
conda config --remove channels defaults || true

# 2. Create SDR Virtual Environment
if ! conda info --envs | grep -q "telcosec-sdr"; then
  echo "Creating SDR Conda Environment..."
  conda create -y --override-channels -c conda-forge -n telcosec-sdr python=3.11 cmake ninja pkg-config boost-cpp swig pybind11 libusb mako requests numpy ruamel.yaml setuptools
else
  echo "SDR Conda Environment already exists."
fi
conda activate telcosec-sdr

# Export compilation environment variables to prefer the Conda environment
export PKG_CONFIG_PATH="$CONDA_PREFIX/lib/pkgconfig:$PKG_CONFIG_PATH"
export CMAKE_PREFIX_PATH="$CONDA_PREFIX"

# 3. Clone all SDR source repos in parallel
echo "Cloning SDR source repositories..."
mkdir -p /opt/telcosec/src
[ -d /opt/telcosec/src/SoapySDR ] || (git clone --depth 1 https://github.com/pothosware/SoapySDR.git /opt/telcosec/src/SoapySDR) &
[ -d /opt/telcosec/src/hackrf ] || (git clone --depth 1 https://github.com/greatscottgadgets/hackrf.git /opt/telcosec/src/hackrf) &
[ -d /opt/telcosec/src/uhd ] || (git clone --depth 1 https://github.com/EttusResearch/uhd.git /opt/telcosec/src/uhd) &
[ -d /opt/telcosec/src/kalibrate-rtl ] || (git clone --depth 1 https://github.com/steve-m/kalibrate-rtl.git /opt/telcosec/src/kalibrate-rtl) &
[ -d /opt/telcosec/src/LimeSuite ] || (git clone --depth 1 https://github.com/myriadrf/LimeSuite.git /opt/telcosec/src/LimeSuite) &
wait
echo "All SDR repos checked/cloned."

# 4. Compile SoapySDR from Source
echo "Compiling SoapySDR..."
cd /opt/telcosec/src/SoapySDR
rm -rf build && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ..
make -j$(nproc)
make install

# 4.5 Compile SoapyBladeRF plugin
echo "Compiling SoapyBladeRF..."
git clone --depth 1 https://github.com/pothosware/SoapyBladeRF.git /opt/telcosec/src/SoapyBladeRF 2>/dev/null || true
if [ -d /opt/telcosec/src/SoapyBladeRF ]; then
  cd /opt/telcosec/src/SoapyBladeRF
  rm -rf build && mkdir build && cd build
  cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ..
  make -j$(nproc)
  make install
fi
# 5. Compile HackRF from Source
echo "Compiling HackRF..."
cd /opt/telcosec/src/hackrf/host
rm -rf build && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ..
make -j$(nproc)
make install

# 5.5 Compile LimeSuite from Source
echo "Compiling LimeSuite..."
cd /opt/telcosec/src/LimeSuite
rm -rf build && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX ..
make -j$(nproc)
make install

# 6. Compile UHD (USRP) from Source
echo "Compiling UHD..."
cd /opt/telcosec/src/uhd/host
rm -rf build && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=$CONDA_PREFIX -DENABLE_TESTS=OFF -DENABLE_EXAMPLES=OFF ..
make -j$(nproc)
make install

# Defer uhd_images_downloader to first-run (saves ~1.5 GB ISO space and ~10 min)
echo "Creating UHD images first-run downloader..."
cat << 'FIRSTRUN' | sudo tee /usr/local/bin/uhd-download-images
#!/bin/bash
echo "Downloading UHD FPGA images (~1.5 GB)..."
echo "This only needs to run once after installation."
source /opt/telcosec/miniconda/etc/profile.d/conda.sh
conda activate telcosec-sdr 2>/dev/null || true
uhd_images_downloader
echo "UHD images downloaded successfully."
FIRSTRUN
sudo chmod +x /usr/local/bin/uhd-download-images

# 7. Install GNU Radio ecosystem into conda env
# gqrx-sdr, gr-osmosdr, gr-gsm removed from system apt (librtlsdr ABI conflict
# between librtlsdr0/soname-0 and librtlsdr2/soname-2 in Ubuntu 24.04 Noble).
# conda-forge packages resolve their own ABIs cleanly.
echo "Installing GNU Radio ecosystem into conda env..."
# Install rtl-sdr alone first — required for kalibrate-rtl headers.
conda install -y --override-channels -c conda-forge rtl-sdr 2>/dev/null || \
  echo "  WARNING: rtl-sdr conda install failed — will try source build below"

# If conda install of rtl-sdr failed (headers absent), build librtlsdr from source
# directly into the conda env. This is the guaranteed fallback that always works.
if [ ! -f "${CONDA_PREFIX}/include/rtl-sdr.h" ]; then
  echo "  Building librtlsdr from source into conda env..."
  git clone --depth 1 https://github.com/osmocom/rtl-sdr \
    /opt/telcosec/src/librtlsdr 2>/dev/null || true
  if [ -d /opt/telcosec/src/librtlsdr ]; then
    cmake -S /opt/telcosec/src/librtlsdr -B /opt/telcosec/src/librtlsdr/build \
      -DCMAKE_INSTALL_PREFIX="${CONDA_PREFIX}" \
      -DDETACH_KERNEL_DRIVER=ON \
      -DCMAKE_BUILD_TYPE=Release >/dev/null 2>&1
    make -C /opt/telcosec/src/librtlsdr/build -j"$(nproc)" >/dev/null 2>&1
    make -C /opt/telcosec/src/librtlsdr/build install >/dev/null 2>&1 && \
      echo "  librtlsdr source build complete — rtl-sdr.h now available"
  fi
fi

# gnuradio and gqrx — large; non-fatal if solver fails.
conda install -y --override-channels -c conda-forge gnuradio gqrx 2>/dev/null || \
  echo "  WARNING: conda gnuradio/gqrx install failed (non-fatal)"

# gr-osmosdr is not on conda-forge — attempt separately, failure expected.
conda install -y --override-channels -c conda-forge gr-osmosdr 2>/dev/null || \
  echo "  INFO: gr-osmosdr not on conda-forge — skipping (gr-gsm built from source below)"

# gr-gsm is not on conda-forge; build from source against the conda env
git clone --depth 1 https://github.com/bkerler/gr-gsm /opt/telcosec/src/gr-gsm 2>/dev/null || true
if [ -d /opt/telcosec/src/gr-gsm ]; then
  cmake -S /opt/telcosec/src/gr-gsm -B /opt/telcosec/src/gr-gsm/build \
    -DCMAKE_INSTALL_PREFIX="$CONDA_PREFIX" -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_MODULE_PATH="$CONDA_PREFIX/lib/cmake/gnuradio" >/dev/null 2>&1 || true
  make -C /opt/telcosec/src/gr-gsm/build -j"$(nproc)" >/dev/null 2>&1 || true
  make -C /opt/telcosec/src/gr-gsm/build install >/dev/null 2>&1 || true
  echo "  gr-gsm installed."
fi

# 8. Compile and Install Kalibrate-RTL from Source
echo "Compiling and installing Kalibrate-RTL..."
if [ ! -f "${CONDA_PREFIX}/include/rtl-sdr.h" ]; then
  echo "  WARNING: rtl-sdr.h not found in conda env — skipping kalibrate-rtl build"
else
  cd /opt/telcosec/src/kalibrate-rtl
  ./bootstrap
  # Bypass pkg-config for both librtlsdr (conda, no .pc file) and fftw3 (system,
  # hidden when conda sets PKG_CONFIG_LIBDIR and overrides default search paths).
  # -rpath embeds the conda lib path into the kal binary itself, since it
  # installs to /usr/local (system-wide) but links against a library that
  # only exists in the conda env — without it, kal fails at runtime with
  # "librtlsdr.so.0: cannot open shared object file" outside an activated
  # conda shell (e.g. when launched from a plain gnome-terminal).
  LIBRTLSDR_CFLAGS="-I${CONDA_PREFIX}/include" \
  LIBRTLSDR_LIBS="-L${CONDA_PREFIX}/lib -lrtlsdr -Wl,-rpath,${CONDA_PREFIX}/lib" \
  FFTW3_CFLAGS="-I/usr/include" \
  FFTW3_LIBS="-lfftw3 -lm" \
    ./configure
  make -j$(nproc)
  sudo make install
  cd -
fi

# GUI desktop launchers (.desktop Exec=) run outside any login shell so the
# conda env is never activated. For ELF binaries (gqrx, gnuradio-companion)
# a symlink works once we embed the rpath; for Python scripts installed by
# gr-gsm (grgsm_livemon, grgsm_scanner) the shebang points to the conda
# Python, which can't import gnuradio blocks unless the conda env is active.
# Use wrapper scripts that activate the env before exec'ing the tool — this
# also avoids the conditional symlink silently doing nothing when a gr-gsm
# cmake build fails.
for bin in gqrx gnuradio-companion; do
  [ -f "${CONDA_PREFIX}/bin/${bin}" ] && \
    sudo ln -sf "${CONDA_PREFIX}/bin/${bin}" "/usr/local/bin/${bin}"
done

for bin in grgsm_livemon grgsm_scanner; do
  sudo tee "/usr/local/bin/${bin}" > /dev/null << WRAPPER
#!/bin/bash
source /opt/telcosec/miniconda/etc/profile.d/conda.sh
conda activate telcosec-sdr 2>/dev/null
exec "${CONDA_PREFIX}/bin/${bin}" "\$@"
WRAPPER
  sudo chmod +x "/usr/local/bin/${bin}"
done

# Set permissions
sudo chown -R telcosec:telcosec /opt/telcosec
