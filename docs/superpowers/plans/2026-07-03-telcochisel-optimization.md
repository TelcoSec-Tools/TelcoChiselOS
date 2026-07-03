# TelcoChisel Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix the device-access, installer, boot-performance, and SDR-tooling defects surfaced by the four-part audit, and add the highest-leverage SDR hardware/usability improvements — without regressing any of the deliberate research-testbed tradeoffs documented in CLAUDE.md.

**Architecture:** This is a live-ISO *builder*, not an application. "Implementation" means editing shell provisioning scripts (`builder/scripts/*.sh`), udev/security/config files under `builder/`, the Calamares config, and the boot orchestration in `build-iso.sh`. There is no unit-test framework: verification is static (grep/`shellcheck`/file-existence) per task, plus a single end-to-end build+boot smoke test at the end. Work proceeds in three commit phases — **A: Critical correctness**, **B: Boot/service performance**, **C: SDR env + hardware + cleanup** — each independently shippable.

**Tech Stack:** Bash, udev, systemd, tuned, Calamares (YAML modules), Conda/conda-forge, GRUB/casper, squashfs, Plymouth.

## Global Constraints

- **Do not "fix" documented-intentional tradeoffs** (verbatim from CLAUDE.md "Security Posture"): `mitigations=off`, default `telcosec:telcosec` creds + SSH, `telcosec` in `docker` group, `rp_filter=0`. None of the tasks below touch these; if a change appears to, stop.
- **Both tool catalogs must stay in sync:** any edit to `docs/data/tools.js` (76 entries) must be mirrored in `builder/docs/app.js` (76 entries) and vice-versa.
- **Chroot context:** scripts 01–12 run inside the chroot. `systemctl enable`/`mask` only create/remove symlinks (safe in chroot); never call `systemctl start`.
- **Script run order is `00 01 02 03 04 06 05 07 08 09 10 11 12`** — `06` before `05`. When two scripts write the same file, the later one wins; account for this.
- **Standalone-run fallback:** each provisioning script may run alone for testing, so package/tool additions belong in the relevant `lib/packages.sh` array, not inline.
- **Commit after every task.** End each commit message with the Co-Authored-By trailer used by this repo.
- **No new build-time network fetches** where a vendored/deferred pattern already exists (follow the "clone-if-missing" / first-run-helper convention).

---

## Phase A — Critical Correctness

### Task A1: Fix USRP udev vendor IDs (B200/B210 device access)

**Files:**
- Modify: `builder/udev/50-telcosec-hw.rules:19` and `:74`

**Problem:** `idVendor=="2514"` is a Microchip USB hub, not Ettus. No USRP ever gets `plugdev` access; `uhd_usrp_probe` fails for non-root.

- [ ] **Step 1: Replace the single USRP access rule (line 19)** with the full Ettus/NI set:

```
# USRP UHD (Ettus Research / National Instruments)
# B200/B210/B200mini (2500), NI-branded (3923), USRP1 (fffe), un-fused FX3 (04b4)
ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0020", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0021", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="2500", ATTRS{idProduct}=="0022", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="3923", ATTRS{idProduct}=="7813", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="3923", ATTRS{idProduct}=="7814", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="fffe", ATTRS{idProduct}=="0002", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="00f0", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="04b4", ATTRS{idProduct}=="00f3", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
```

- [ ] **Step 2: Replace the autosuspend rule (old line 74, `idVendor=="2514"`)** with `2500`-matching entries:

```
ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2500", ATTR{idProduct}=="0020", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2500", ATTR{idProduct}=="0021", ATTR{power/control}="on"
ACTION=="add", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{idVendor}=="2500", ATTR{idProduct}=="0022", ATTR{power/control}="on"
```

- [ ] **Step 3: Verify** no stray `2514` remains and the new IDs are present:

Run: `grep -nE '2514|2500|3923|fffe|04b4' builder/udev/50-telcosec-hw.rules`
Expected: no `2514` lines; `2500`/`3923`/`fffe`/`04b4` present.

- [ ] **Step 4: Commit**

```bash
git add builder/udev/50-telcosec-hw.rules
git commit -m "fix(udev): correct USRP vendor IDs so B200/B210 get plugdev access"
```

### Task A2: Blacklist the RTL-SDR DVB-T kernel driver

**Files:**
- Create: `builder/modprobe/blacklist-rtlsdr.conf`
- Modify: `builder/scripts/08-system-optimization.sh` (install step, near the udev/modprobe copies) and `build-iso.sh` (stage the new dir into `/tmp`)

**Problem:** No blacklist exists for `dvb_usb_rtl28xxu`/`rtl2832`, so the kernel TV driver claims RTL dongles first and `rtl_test`/`grgsm_scanner`/`kalibrate-rtl` fail with `usb_claim_interface error -6`. The docs already claim this blacklist ships (`docs/utils/driverMetadata.js:67`).

- [ ] **Step 1: Create the blacklist file** `builder/modprobe/blacklist-rtlsdr.conf`:

```
# TelcoChisel: keep the DVB-T TV driver off RTL2832U SDR dongles so
# rtl_sdr / grgsm / kalibrate-rtl can claim the USB interface directly.
blacklist dvb_usb_rtl28xxu
blacklist rtl2832
blacklist rtl2830
blacklist dvb_usb_v2
```

- [ ] **Step 2: Stage the dir in `build-iso.sh`.** Find the block that copies `builder/{udev,security,...}` into `/tmp/...` and add a copy of `builder/modprobe` → `/tmp/modprobe` alongside the others.

Run (to locate the block): `grep -n "cp -r.*builder/udev\|/tmp/udev\|/tmp/security" build-iso.sh`

- [ ] **Step 3: Install it in `08-system-optimization.sh`.** Next to where `50-telcosec-hw.rules` is copied into `/etc/udev/rules.d/`, add:

```bash
# RTL-SDR: block the DVB-T kernel driver from grabbing the dongle
sudo cp /tmp/modprobe/blacklist-rtlsdr.conf /etc/modprobe.d/blacklist-rtlsdr.conf
```

- [ ] **Step 4: Verify** the file will be installed:

Run: `grep -n "blacklist-rtlsdr" builder/scripts/08-system-optimization.sh build-iso.sh; ls builder/modprobe/`
Expected: install line present; file exists.

- [ ] **Step 5: Commit**

```bash
git add builder/modprobe/blacklist-rtlsdr.conf builder/scripts/08-system-optimization.sh build-iso.sh
git commit -m "fix(sdr): blacklist DVB-T driver so RTL-SDR dongles work out of the box"
```

### Task A3: Raise `usbfs_memory_mb` for high-rate SDR capture

**Files:**
- Modify: `builder/scripts/08-system-optimization.sh:179` (tuned `[bootloader] cmdline`)
- Modify: `build-iso.sh` live GRUB menuentries (append same flag to the live cmdline)

**Problem:** usbfs buffer stays at 16 MB. UHD B200/B210 errors outright; HackRF/RTL drop samples. Neither the installed cmdline nor the live cmdline raises it.

- [ ] **Step 1: Append to the tuned bootloader cmdline** (`08-...:179`), so the *installed* system gets it:

Change the line to:
```
cmdline=mitigations=off clocksource=tsc tsc=reliable intel_idle.max_cstate=1 processor.max_cstate=1 usbcore.usbfs_memory_mb=1000
```

- [ ] **Step 2: Add the flag to the live ISO cmdline** in `build-iso.sh`. Locate the `menuentry` lines (around 654–676) and append `usbcore.usbfs_memory_mb=1000` to the `linux ... boot=casper ...` cmdline of each live entry.

Run (to locate): `grep -n "boot=casper\|vmlinuz\|menuentry" build-iso.sh`

- [ ] **Step 3: Verify** both surfaces carry the flag:

Run: `grep -n "usbfs_memory_mb" builder/scripts/08-system-optimization.sh build-iso.sh`
Expected: at least one hit in each file.

- [ ] **Step 4: Commit**

```bash
git add builder/scripts/08-system-optimization.sh build-iso.sh
git commit -m "perf(sdr): raise usbfs_memory_mb to 1000 on live and installed cmdline"
```

### Task A4: Wire up the Calamares cleanup module instance

**Files:**
- Modify: `builder/calamares/settings.conf:4`

**Problem:** `sequence` runs `shellprocess@cleanup` but `instances: []` is empty and no `shellprocess.conf` exists, so the cleanup (remove casper hook, `userdel telcosec`, drop sudoers/polkit, remove live autologin) never runs — or the installer fails to launch, version-depending.

- [ ] **Step 1: Declare the instance.** Replace `instances: []` with:

```yaml
instances:
- id: cleanup
  module: shellprocess
  config: shellprocess-cleanup.conf
```

- [ ] **Step 2: Verify** the config target the instance names exists:

Run: `ls builder/calamares/modules/shellprocess-cleanup.conf && grep -n "shellprocess@cleanup\|id: cleanup" builder/calamares/settings.conf`
Expected: file exists; both lines present.

- [ ] **Step 3: Commit**

```bash
git add builder/calamares/settings.conf
git commit -m "fix(calamares): declare shellprocess@cleanup instance so post-install cleanup runs"
```

---

## Phase B — Boot & Service Performance

### Task B1: Mask `NetworkManager-wait-online` (kills the 90–120 s boot stall)

**Files:**
- Modify: `builder/scripts/08-system-optimization.sh` (service-disable block, ~240–247)

**Problem:** `docker.service` pulls in `network-online.target`, which activates `NetworkManager-wait-online.service` — up to ~120 s stall on a VM/bench with no carrier. Nothing on the path to the XFCE desktop needs it.

- [ ] **Step 1: Add the mask** in the service block:

```bash
# Nothing on the path to the desktop needs network-online; docker pulls it in
# and it stalls boot up to 2 min with no carrier. Mask it.
sudo systemctl mask NetworkManager-wait-online.service || true
```

- [ ] **Step 2: Verify:** `grep -n "wait-online" builder/scripts/08-system-optimization.sh` → present.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/08-system-optimization.sh
git commit -m "perf(boot): mask NetworkManager-wait-online to remove boot stall"
```

### Task B2: Disable ModemManager by default

**Files:**
- Modify: `builder/scripts/11-install-device-tools.sh:166`

**Problem:** ModemManager probes every serial/USB device at boot and grabs baseband/SDR serial ports (Qualcomm diag, SIMtrace, AT). The SDR/baseband udev rules already set `ID_MM_DEVICE_IGNORE`, but disabling the service removes the boot cost and protects non-listed devices. Users who genuinely want managed modems can `sudo systemctl start ModemManager`.

- [ ] **Step 1:** Change the enable at line 166 to a disable:

```bash
# ModemManager grabs baseband/diag/AT serial ports the flashing tools need,
# and slows boot by probing every tty. Off by default; start on demand.
sudo systemctl disable ModemManager.service 2>/dev/null || true
```

- [ ] **Step 2: Verify:** `grep -n "ModemManager" builder/scripts/11-install-device-tools.sh` → shows `disable`, no `enable`.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/11-install-device-tools.sh
git commit -m "perf(boot): disable ModemManager by default to free baseband serial ports"
```

### Task B3: Guarantee `tuned` is enabled at boot

**Files:**
- Modify: `builder/scripts/08-system-optimization.sh:202-204`

**Problem:** the script sets the *active profile* but never `systemctl enable tuned`; if the package postinst enable didn't stick under `policy-rc.d`, the performance governor/hugepages/cmdline never apply.

- [ ] **Step 1:** After the `tuned-adm profile` block, add:

```bash
# Ensure the service actually starts on the installed/live system so the
# telcosec-sdr profile (governor=performance, hugepages, bootloader cmdline) applies.
sudo systemctl enable tuned.service 2>/dev/null || true
```

- [ ] **Step 2: Verify:** `grep -n "systemctl enable tuned" builder/scripts/08-system-optimization.sh` → present.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/08-system-optimization.sh
git commit -m "fix(perf): enable tuned.service so the SDR performance profile applies at boot"
```

### Task B4: Trim GRUB timeout and add a `toram` live entry

**Files:**
- Modify: `build-iso.sh` (GRUB menu generation, ~628 timeout and ~654–676 menuentries)

**Problem:** `timeout=15` is long; there is no `toram` option for faster runtime / removable media.

- [ ] **Step 1:** Change `timeout=15` → `timeout=5` (keep `default=0`).

Run (locate): `grep -n "timeout=" build-iso.sh`

- [ ] **Step 2:** Duplicate the primary live `menuentry` into a new entry titled `"Try TelcoChisel (load to RAM)"` whose `linux` line appends `toram` to the existing `boot=casper ...` cmdline (including the `usbcore.usbfs_memory_mb=1000` from Task A3). Keep the same `vmlinuz`/`initrd` paths as the primary entry.

- [ ] **Step 3: Verify:** `grep -n "timeout=5\|toram" build-iso.sh` → both present.

- [ ] **Step 4: Commit**

```bash
git add build-iso.sh
git commit -m "perf(boot): shorten GRUB timeout to 5s and add a toram live entry"
```

### Task B5: Resolve the `resolvconf` / `systemd-resolved` conflict

**Files:**
- Modify: `builder/scripts/lib/packages.sh:49` (remove `resolvconf` from `PKGS_BASE`)

**Problem:** `resolvconf` and `systemd-resolved` (configured in `08:249-256`) both claim `/etc/resolv.conf`, causing DNS stalls. Ubuntu 24.04's default is `systemd-resolved`.

- [ ] **Step 1:** Delete the `resolvconf` token from the `PKGS_BASE` array.

- [ ] **Step 2: Verify:** `grep -n "resolvconf" builder/scripts/lib/packages.sh builder/scripts/*.sh` → no install of `resolvconf` remains.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/lib/packages.sh
git commit -m "fix(net): drop resolvconf, rely on systemd-resolved to avoid DNS stalls"
```

### Task B6: Ensure Plymouth is installed and password assets exist

**Files:**
- Modify: `builder/scripts/lib/packages.sh` (`PKGS_BASE`: add `plymouth`, `plymouth-themes`)
- Create: `builder/boot/plymouth/password_field.png`, `builder/boot/plymouth/password_dot.png`
- Modify: `builder/scripts/08-system-optimization.sh:100-101` (copy the local assets instead of the non-existent Kali `emerald` theme)

**Problem:** `telcosec.script:128-129` needs `password_field.png`/`password_dot.png`, currently sourced from a Kali `emerald` theme absent on Ubuntu 24.04 (silent no-op) → LUKS installs can hit a black/frozen splash. Plymouth itself isn't in `PKGS_BASE`.

- [ ] **Step 1:** Add `plymouth` and `plymouth-themes` to `PKGS_BASE` in `lib/packages.sh`.

- [ ] **Step 2:** Generate the two PNG assets locally (a 300×40 rounded field and a 12×12 dot, amber-on-dark to match the theme) and commit them under `builder/boot/plymouth/`. Use the existing `builder/boot/generate-assets.py` if it already emits Plymouth assets; otherwise create them with any tool and drop the PNGs in place. Verify with `file` that they are real PNGs.

- [ ] **Step 3:** Replace the `emerald`-sourced copy at `08:100-101` with a copy from the staged local theme dir (`/tmp/boot/plymouth/password_*.png` → the installed theme dir), guarded by existence.

- [ ] **Step 4: Verify:**

Run: `file builder/boot/plymouth/password_field.png builder/boot/plymouth/password_dot.png; grep -n "plymouth" builder/scripts/lib/packages.sh; grep -n "emerald\|password_field" builder/scripts/08-system-optimization.sh`
Expected: both are `PNG image data`; plymouth in packages; no remaining dependence on `emerald`.

- [ ] **Step 5: Commit**

```bash
git add builder/boot/plymouth/password_field.png builder/boot/plymouth/password_dot.png builder/scripts/lib/packages.sh builder/scripts/08-system-optimization.sh
git commit -m "fix(boot): ship Plymouth + password assets so encrypted-install splash never breaks"
```

### Task B7: Fix LightDM autologin group membership

**Files:**
- Modify: `builder/scripts/01-install-base.sh:56` (user group list) or `05-desktop-customization.sh` (near autologin config)

**Problem:** `autologin-user=telcosec` is set but `telcosec` is not in an `autologin` group; several LightDM/PAM setups drop to the greeter without it. Docs promise graphical autologin.

- [ ] **Step 1:** Ensure the group exists and the user is enrolled — add near the user creation:

```bash
sudo groupadd -f autologin
sudo usermod -aG autologin telcosec
```

- [ ] **Step 2: Verify:** `grep -n "autologin" builder/scripts/01-install-base.sh builder/scripts/05-desktop-customization.sh` → group add + usermod present.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/01-install-base.sh
git commit -m "fix(boot): add telcosec to autologin group so LightDM autologin fires"
```

> **Note (dashboard service deferral):** deferring `postgresql`/`nginx`/`php-fpm` off boot (audit B2) is deliberately **out of scope** here — the `telcosec-dashboard-db-init.service` oneshot orders `After=postgresql`, so disabling it needs a coordinated first-run-enable rework. Masking `NetworkManager-wait-online` (B1) removes the dominant boot cost; revisit dashboard deferral as its own spec if boot time is still a concern after B1–B7.

---

## Phase C — SDR Environment, Hardware Coverage & Cleanup

### Task C1: Make the `telcosec-sdr` CLI tools reachable from a terminal

**Files:**
- Modify: `builder/scripts/02-install-sdr.sh` (after the existing symlink/wrapper block, ~280)

**Problem:** the conda env is never activated for interactive shells and its CLI tools (`hackrf_info`, `uhd_usrp_probe`, `SoapySDRUtil`, `rtl_test`, `rtl_sdr`, `LimeUtil`) are off `PATH`. Typing `hackrf_info` gives "command not found."

- [ ] **Step 1:** After the `grgsm_*` wrapper loop, symlink the key CLIs into `/usr/local/bin` (they are rpath-linked ELF binaries, so a bare symlink resolves):

```bash
# Surface the core SDR CLIs outside the conda env (they carry an embedded rpath).
for bin in hackrf_info hackrf_transfer uhd_usrp_probe uhd_find_devices \
           SoapySDRUtil rtl_test rtl_sdr rtl_fm LimeUtil; do
  [ -f "${CONDA_PREFIX}/bin/${bin}" ] && \
    sudo ln -sf "${CONDA_PREFIX}/bin/${bin}" "/usr/local/bin/${bin}"
done
```

- [ ] **Step 2: Verify:** `grep -n "hackrf_info\|SoapySDRUtil\|/usr/local/bin/\${bin}" builder/scripts/02-install-sdr.sh` → new loop present.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/02-install-sdr.sh
git commit -m "fix(sdr): symlink core conda SDR CLIs into PATH for terminal use"
```

### Task C2: Install the full SoapySDR module set

**Files:**
- Modify: `builder/scripts/02-install-sdr.sh` (GNU Radio ecosystem section, ~196–202)

**Problem:** only `SoapyBladeRF` is built, so `SoapySDRUtil --find` sees only bladeRF and Soapy-abstracted tools can't reach HackRF/RTL/UHD/Lime — contradicting the docs.

- [ ] **Step 1:** Add a conda install of the Soapy modules (non-fatal, matching sibling calls):

```bash
# Soapy hardware modules so SoapySDRUtil --find sees all radios, not just bladeRF.
conda install -y --override-channels -c conda-forge \
  soapysdr-module-rtlsdr soapysdr-module-hackrf soapysdr-module-uhd \
  soapysdr-module-lms7 soapysdr-module-remote 2>/dev/null || \
  echo "  WARNING: some soapysdr-module-* installs failed (non-fatal)"
```

- [ ] **Step 2: Verify:** `grep -n "soapysdr-module" builder/scripts/02-install-sdr.sh` → present.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/02-install-sdr.sh
git commit -m "feat(sdr): install SoapySDR modules for RTL/HackRF/UHD/Lime/Remote"
```

### Task C3: Fix the broken `gr-osmosdr` conda package name

**Files:**
- Modify: `builder/scripts/02-install-sdr.sh:201`

**Problem:** the conda-forge package is `gnuradio-osmosdr`, not `gr-osmosdr`; the current line always fails (masked by `|| INFO`).

- [ ] **Step 1:** Change the package name on line 201 from `gr-osmosdr` to `gnuradio-osmosdr` (keep the non-fatal guard).

- [ ] **Step 2: Verify:** `grep -n "osmosdr" builder/scripts/02-install-sdr.sh` → `gnuradio-osmosdr`.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/02-install-sdr.sh
git commit -m "fix(sdr): use correct conda-forge package name gnuradio-osmosdr"
```

### Task C4: Add udev rules for Airspy, PlutoSDR, LimeSDR Mini, BladeRF x40/x115, HackRF Jawbreaker

**Files:**
- Modify: `builder/udev/50-telcosec-hw.rules` (SDR section + autosuspend section)

**Problem:** popular/advertised radios have no device rules (Airspy, Pluto, Lime Mini, older BladeRF, Jawbreaker).

- [ ] **Step 1:** Add to the SDR access section:

```
# Airspy R2 / Mini
ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="60a1", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
# Airspy HF+
ATTRS{idVendor}=="03eb", ATTRS{idProduct}=="800c", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
# ADALM-Pluto (run) + DFU
ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b673", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
ATTRS{idVendor}=="0456", ATTRS{idProduct}=="b674", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
# LimeSDR Mini (FTDI)
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="601f", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
# BladeRF x40 / x115 (original)
ATTRS{idVendor}=="2cf0", ATTRS{idProduct}=="5246", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
# HackRF Jawbreaker
ATTRS{idVendor}=="1d50", ATTRS{idProduct}=="604b", MODE="0660", GROUP="plugdev", ENV{ID_SOFTWARE_RADIO}="1", ENV{ID_MM_DEVICE_IGNORE}="1"
```

- [ ] **Step 2:** Add matching autosuspend-off lines for the same IDs in the autosuspend section (copy the `ATTR{power/control}="on"` pattern used there).

- [ ] **Step 3: Verify:** `grep -cE '60a1|800c|b673|b674|601f|5246|604b' builder/udev/50-telcosec-hw.rules` → ≥ 7.

- [ ] **Step 4: Commit**

```bash
git add builder/udev/50-telcosec-hw.rules
git commit -m "feat(sdr): add udev rules for Airspy, PlutoSDR, LimeSDR Mini, BladeRF x40/x115, Jawbreaker"
```

### Task C5: Merge Wireshark `mon0`/promiscuous defaults into the canonical preferences

**Files:**
- Modify: `builder/wireshark/preferences` (add the three capture lines)
- Modify: `builder/scripts/05-desktop-customization.sh:363-373` (drop the now-redundant duplicate write)

**Problem:** script 05 writes `capture.default_interface: mon0` etc., then script 08 overwrites the same file with a version lacking them → shipped image loses the mon0 default.

- [ ] **Step 1:** Append to `builder/wireshark/preferences` (keep `gui.column.format` single-line — do not disturb it):

```
capture.default_interface: mon0
capture.prom_mode: TRUE
gui.expert_composite_eyecandy: TRUE
```

- [ ] **Step 2:** Remove the duplicate `preferences` write in `05-desktop-customization.sh:363-373` (the `08` copy of `/tmp/wireshark/preferences` is now the single source of truth). Leave any non-preferences Wireshark setup in 05 intact.

- [ ] **Step 3: Verify:** `grep -n "capture.default_interface\|gui.column.format" builder/wireshark/preferences` → mon0 present, column.format still one line; `grep -n "capture.default_interface" builder/scripts/05-desktop-customization.sh` → no longer written there.

- [ ] **Step 4: Commit**

```bash
git add builder/wireshark/preferences builder/scripts/05-desktop-customization.sh
git commit -m "fix(wireshark): keep mon0/promiscuous defaults by merging into canonical preferences"
```

### Task C6: Fix the two broken launcher commands

**Files:**
- Modify: `builder/menu/applications/diafuzzer.desktop:6`
- Modify: `builder/menu/applications/gammu-sms.desktop:5`

**Problem:** `diafuzzer.desktop` calls `diafuzzer.py`/`diameter_fuzzer.py` (real script is `dia_fuzzer.py`); `gammu-sms.desktop` runs `gammu-at --help` where the wrapper treats `--help` as the serial device.

- [ ] **Step 1:** In `diafuzzer.desktop`, point the `Exec` at `python3 /opt/telcosec/diafuzzer/dia_fuzzer.py --help` (verify the checked-out repo's entry filename first with `ls /opt/telcosec/diafuzzer` semantics — the Orange-OpenSource repo ships `dia_fuzzer.py`).

- [ ] **Step 2:** In `gammu-sms.desktop`, change the `Exec` to `gammu --help` (which does not consume a positional device), or `gammu-at /dev/ttyUSB0 --identify` if a device-scoped demo is preferred.

- [ ] **Step 3: Verify:** `grep -n "Exec=" builder/menu/applications/diafuzzer.desktop builder/menu/applications/gammu-sms.desktop` → corrected commands.

- [ ] **Step 4: Commit**

```bash
git add builder/menu/applications/diafuzzer.desktop builder/menu/applications/gammu-sms.desktop
git commit -m "fix(menu): correct diafuzzer and gammu-sms launcher commands"
```

### Task C7: Fix the `update-sdr` alias

**Files:**
- Modify: `builder/scripts/08-system-optimization.sh:316`

**Problem:** the alias calls conda binaries not on root's PATH and misspells `LimeUtil` as `limeUtil`.

- [ ] **Step 1:** Replace the alias body to reuse the working first-run helper and the correct binary name:

```bash
alias update-sdr="sudo /usr/local/bin/uhd-download-images && sudo /usr/local/bin/LimeUtil --update"
```

(`LimeUtil` is symlinked into `/usr/local/bin` by Task C1.)

- [ ] **Step 2: Verify:** `grep -n "update-sdr" builder/scripts/08-system-optimization.sh` → uses `uhd-download-images` and `LimeUtil`.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/08-system-optimization.sh
git commit -m "fix(sdr): repair update-sdr alias (correct LimeUtil name and PATH)"
```

### Task C8: Remove stale `srsGUI` catalog entry (both catalogs)

**Files:**
- Modify: `builder/docs/app.js` (the `cmd: "srsgui"` entry, ~112–113)
- Modify: `docs/data/tools.js` (the matching srsGUI entry)

**Problem:** the `srsgui.desktop` launcher was correctly deleted (no `srsgui` binary is produced), but both tool catalogs still list it. Catalogs must stay in sync at matching counts.

- [ ] **Step 1:** Remove the srsGUI object from `builder/docs/app.js`.

- [ ] **Step 2:** Remove the corresponding srsGUI object from `docs/data/tools.js`.

- [ ] **Step 3: Verify counts still match:**

Run: `grep -c "status:" builder/docs/app.js docs/data/tools.js`
Expected: both report the same number (75 after removing one from each 76-entry catalog); `grep -in "srsgui" builder/docs/app.js docs/data/tools.js` → no matches.

- [ ] **Step 4: Commit**

```bash
git add builder/docs/app.js docs/data/tools.js
git commit -m "docs: remove stale srsGUI entry from both tool catalogs"
```

### Task C9: Remove dead `xfce4-terminal` config and correct the doc reference

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh:375-409` (delete the `terminalrc` block)
- Modify: `CLAUDE.md` (terminal reference)

**Problem:** `05` writes `/etc/xdg/xfce4/terminal/terminalrc` but `xfce4-terminal` is never installed; the actual default is `gnome-terminal` everywhere. CLAUDE.md still says `xfce4-terminal`.

- [ ] **Step 1:** Delete the `terminalrc` heredoc block (`05:375-409`). Leave the `gnome-terminal` default-setting lines (TERMINAL env, x-terminal-emulator alternative, mimeapps, autostart, keybinding) untouched.

- [ ] **Step 2:** In `CLAUDE.md`, change the `xfce4-terminal` mention to `gnome-terminal` (matching the implementation).

- [ ] **Step 3: Verify:** `grep -n "xfce4-terminal\|terminalrc" builder/scripts/05-desktop-customization.sh CLAUDE.md` → no dead terminalrc write; doc says gnome-terminal.

- [ ] **Step 4: Commit**

```bash
git add builder/scripts/05-desktop-customization.sh CLAUDE.md
git commit -m "chore: drop dead xfce4-terminal config, align docs with gnome-terminal default"
```

---

## Final Validation (after all phases)

### Task V1: Static sweep

- [ ] **Step 1:** Shell-lint every touched script:

Run: `shellcheck -S error builder/scripts/02-install-sdr.sh builder/scripts/05-desktop-customization.sh builder/scripts/08-system-optimization.sh builder/scripts/11-install-device-tools.sh build-iso.sh`
Expected: no error-level findings introduced by these edits.

- [ ] **Step 2:** Confirm no reintroduced regressions:

Run: `grep -rnE '2514|limeUtil|gr-osmosdr|srsgui' builder/ docs/ build-iso.sh`
Expected: no `2514`, no `limeUtil`, no `gr-osmosdr` (only `gnuradio-osmosdr`), no `srsgui`.

### Task V2: End-to-end build + boot smoke test

- [ ] **Step 1:** Build the ISO from WSL:

Run: `bash build-wsl.sh`
Expected: completes; `build-iso.sh`'s integrity loop-mount check passes ("Build complete"); tool-manifest summary shows the SDR tools PASS.

- [ ] **Step 2:** Boot `TelcoChisel-live.iso` in a VM and verify, in one terminal session:
  - `hackrf_info` / `SoapySDRUtil --find` resolve by name (Task C1/C2).
  - `cat /etc/modprobe.d/blacklist-rtlsdr.conf` present (A2).
  - `cat /sys/module/usbcore/parameters/usbfs_memory_mb` → 1000 (A3).
  - `tuned-adm active` → `telcosec-sdr`; `systemctl is-enabled tuned` → enabled (B3).
  - `systemctl is-enabled NetworkManager-wait-online` → masked (B1); `ModemManager` → disabled (B2).
  - Autologin lands on the XFCE desktop without a greeter prompt (B7).
  - GRUB shows the `toram` entry and a 5 s timeout (B4).

- [ ] **Step 2 (installed path, optional):** Run the Calamares installer to a scratch disk and confirm the installed system has no `telcosec` user and no casper hook (A4 cleanup ran), and boots.

---

## Self-Review Notes

- **Spec coverage:** every audit finding maps to a task — Critical (A1–A4), boot/service (B1–B7), SDR/launcher/doc (C1–C9). The one audit item intentionally deferred (dashboard service deferral) is called out with rationale under Phase B.
- **Cross-task consistency:** Task C7's `update-sdr` alias depends on the `/usr/local/bin/LimeUtil` symlink created in Task C1 — C1 precedes C7. Task B4's `toram` entry inherits the `usbfs_memory_mb` flag added in A3 — A3 precedes B4.
- **Do-not-touch tradeoffs** (mitigations=off, creds/SSH, docker group, rp_filter) are untouched by every task.
