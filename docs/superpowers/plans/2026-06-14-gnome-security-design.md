# GNOME Security Hardening & TelcoSec Design Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Harden GNOME 46's privacy/security defaults for a professional telecom security research environment, and apply a cohesive TelcoSec dark design (Yaru-teal-dark theme, Papirus-Dark icons, GDM3 branded login, hierarchical apps menu).

**Architecture:** All GNOME settings are delivered via two new dconf db files (`03-telcosec-security`, `04-telcosec-design`) dropped in `/etc/dconf/db/local.d/` by script `05-desktop-customization.sh`. GDM3 gets its own dconf db at `/etc/dconf/db/gdm.d/`. The XFCE menu file is renamed and cleaned up so the `apps-menu` GNOME Shell extension reads it as a traditional hierarchical "Applications" menu with all TelcoSec telecom categories. This plan extends [2026-06-14-gnome-migration.md](2026-06-14-gnome-migration.md) — it assumes that plan is already applied (GDM3 installed, dconf infrastructure in place).

**Tech Stack:** GNOME 46 (Ubuntu 24.04), dconf, Yaru-teal-dark GTK/Shell theme, Papirus-Dark icon theme, `gnome-shell-extensions` (apps-menu, places-status-indicator, appindicator), GDM3 custom login.

---

## File Map

| File | Change |
|---|---|
| `builder/scripts/00-install-all-packages.sh` | Add theme + extension packages |
| `builder/scripts/05-desktop-customization.sh` | Add `03-telcosec-security` and `04-telcosec-design` dconf files; add GDM3 branding dconf; add Nautilus bookmarks skeleton |
| `builder/scripts/08-system-optimization.sh` | Disable apport; copy `gnome-applications.menu` instead of xfce |
| `builder/menu/xfce-applications.menu` | Rename to `gnome-applications.menu`; strip XFCE-specific entries; set `<Name>Applications</Name>` |

---

## Task 1: Add Theme and Extension Packages

**Files:**
- Modify: `builder/scripts/00-install-all-packages.sh`

- [ ] **Step 1: Find the GNOME desktop package block** (added by the migration plan, near line 122)

It reads something like:
```
gnome-shell gnome-session gnome-control-center \
gdm3 nautilus gnome-tweaks dconf-cli \
```

- [ ] **Step 2: Append theme and extension packages**

Add to the same block:
```bash
  yaru-theme-gtk yaru-theme-gnome-shell yaru-theme-icon \
  papirus-icon-theme \
  gnome-shell-extensions \
  gnome-shell-extension-appindicator \
  gnome-extensions-app \
```

After edit the block should look like:
```
gnome-shell gnome-session gnome-control-center \
gdm3 nautilus gnome-tweaks dconf-cli \
yaru-theme-gtk yaru-theme-gnome-shell yaru-theme-icon \
papirus-icon-theme \
gnome-shell-extensions \
gnome-shell-extension-appindicator \
gnome-extensions-app \
```

- [ ] **Step 3: Verify and commit**

```bash
bash -n builder/scripts/00-install-all-packages.sh && echo "syntax OK"
grep -n "yaru-theme\|papirus\|gnome-shell-extensions\|appindicator" builder/scripts/00-install-all-packages.sh
git add builder/scripts/00-install-all-packages.sh
git commit -m "feat: add Yaru-teal theme, Papirus icons, and GNOME Shell extensions to package list"
```

---

## Task 2: GNOME Security Hardening dconf

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh`

Insert immediately after the `01-telcosec-appfolders` heredoc (Task 3, Step 3 of the migration plan), before the GNOME Terminal profiles section.

- [ ] **Step 1: Add the security dconf file**

```bash
# 3. GNOME Security & Privacy Hardening
echo "Applying GNOME security hardening..."
cat << 'EOF' | sudo tee /etc/dconf/db/local.d/03-telcosec-security
# ── Privacy ──────────────────────────────────────────────────────────────────
[org/gnome/desktop/privacy]
report-technical-problems=false
send-software-usage-stats=false
remove-old-trash-files=false
remove-old-temp-files=false
recent-files-max-age=-1

# ── Location services ─────────────────────────────────────────────────────────
[org/gnome/system/location]
enabled=false

# ── Software updates: never distract researchers with update banners ──────────
[org/gnome/software]
allow-updates=false
download-updates=false
download-updates-notify=false

# ── Media handling: no auto-mount (USB devices must be mounted intentionally) ─
# Researchers plug in SDR hardware, SIM readers, and suspect devices;
# auto-mount creates accidental write access to forensic evidence.
[org/gnome/desktop/media-handling]
automount=false
automount-open=false
autorun-never=true

# ── Remote desktop: disabled by default ──────────────────────────────────────
[org/gnome/desktop/remote-desktop/rdp]
enable=false

[org/gnome/desktop/remote-desktop/vnc]
enable=false

# ── Sharing: all off by default ───────────────────────────────────────────────
[org/gnome/desktop/sharing]
enabled=false

# ── Notifications: no lock-screen previews ───────────────────────────────────
[org/gnome/desktop/notifications]
show-in-lock-screen=false

# ── Nautilus security posture ─────────────────────────────────────────────────
[org/gnome/nautilus/preferences]
executable-text-activation='ask'
show-hidden-files=true
show-delete-permanently=true

[org/gnome/nautilus/list-view]
use-tree-view=true
default-zoom-level='standard'

# ── Search providers: local only, no external cloud ───────────────────────────
[org/gnome/desktop/search-providers]
disable-external=true
EOF
```

- [ ] **Step 2: Disable apport crash reporting in the same script section**

Immediately after the heredoc:
```bash
# Disable Ubuntu crash reporter — no data should leave the research environment
sudo systemctl disable apport 2>/dev/null || true
sudo systemctl mask apport 2>/dev/null || true
# Remove apport hook so it doesn't auto-re-enable on package install
sudo rm -f /etc/apport/crashdb.conf 2>/dev/null || true
```

- [ ] **Step 3: Verify syntax**

```bash
bash -n builder/scripts/05-desktop-customization.sh && echo "syntax OK"
```

- [ ] **Step 4: Commit**

```bash
git add builder/scripts/05-desktop-customization.sh
git commit -m "feat: GNOME security hardening — privacy, no auto-mount, no crash reports, no remote desktop"
```

---

## Task 3: TelcoSec Design Theme dconf

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh`

Insert after the security dconf file, still before the GNOME Terminal profiles section.

- [ ] **Step 1: Add the design dconf file**

```bash
# 4. TelcoSec Design — Yaru-teal-dark + Papirus-Dark + extensions
echo "Applying TelcoSec design configuration..."
cat << 'EOF' | sudo tee /etc/dconf/db/local.d/04-telcosec-design
# ── GTK theme: Yaru teal dark — matches TelcoSec teal (#00FFD5) brand color ─
[org/gnome/desktop/interface]
gtk-theme='Yaru-teal-dark'
icon-theme='Papirus-Dark'
cursor-theme='Yaru'
document-font-name='Sans 10'
font-name='Ubuntu 10'
monospace-font-name='IBM Plex Mono 11'
color-scheme='prefer-dark'
accent-color='teal'
clock-show-date=true
clock-show-weekday=true
clock-show-seconds=false
clock-format='24h'
enable-hot-corners=true
show-battery-percentage=true

# ── Shell theme ────────────────────────────────────────────────────────────────
[org/gnome/shell/extensions/user-theme]
name='Yaru-teal-dark'

# ── GNOME Shell extensions to enable ─────────────────────────────────────────
# apps-menu: traditional "Applications" dropdown in top bar reading
#   /etc/xdg/menus/gnome-applications.menu — our telecom categories appear here.
# places-status-indicator: quick "Places" dropdown for bookmarks and mounts.
# window-list: classic taskbar at bottom showing open windows.
# appindicatorsupport: system tray icons (Wireshark, nm-applet, etc.).
[org/gnome/shell]
disable-user-extensions=false
enabled-extensions=['apps-menu@gnome-shell-extensions.gcampax.github.com', 'places-status-indicator@gnome-shell-extensions.gcampax.github.com', 'window-list@gnome-shell-extensions.gcampax.github.com', 'appindicatorsupport@rgcjonas.gmail.com']
favorite-apps=['org.gnome.Terminal.desktop', 'firefox.desktop', 'org.wireshark.Wireshark.desktop', 'org.gnome.Nautilus.desktop', 'gnuradio-companion.desktop', 'gqrx.desktop', 'open5gs-start.desktop', 'wireshark-mon.desktop']

# ── Window list (bottom taskbar) position ─────────────────────────────────────
[org/gnome/shell/extensions/window-list]
grouping-mode='auto'
show-on-all-monitors=true

# ── Workspace behavior ────────────────────────────────────────────────────────
[org/gnome/mutter]
workspaces-only-on-primary=true
edge-tiling=true

[org/gnome/shell/overrides]
dynamic-workspaces=false

# ── Text editor defaults ──────────────────────────────────────────────────────
[org/gnome/TextEditor]
use-system-font=false
custom-font='IBM Plex Mono 11'
show-line-numbers=true
show-map=true
indent-style='space'
tab-width=uint32 4

# ── Files (Nautilus) sidebar bookmarks path will be set via skeleton ──────────
EOF
```

- [ ] **Step 2: Add Nautilus sidebar bookmarks to /etc/skel**

Immediately after the heredoc:
```bash
# Nautilus bookmarks — quick access to TelcoSec research paths
sudo mkdir -p /etc/skel/.config/gtk-3.0
cat << 'EOF' | sudo tee /etc/skel/.config/gtk-3.0/bookmarks
file:///usr/share/wordlists/telecom Telecom Wordlists
file:///opt/telcosec TelcoSec Tools
file:///usr/share/doc/telcosec TelcoSec Docs
EOF
sudo mkdir -p /home/telcosec/.config/gtk-3.0
sudo cp /etc/skel/.config/gtk-3.0/bookmarks /home/telcosec/.config/gtk-3.0/bookmarks
sudo chown -R telcosec:telcosec /home/telcosec/.config/gtk-3.0
```

- [ ] **Step 3: Verify syntax**

```bash
bash -n builder/scripts/05-desktop-customization.sh && echo "syntax OK"
```

- [ ] **Step 4: Commit**

```bash
git add builder/scripts/05-desktop-customization.sh
git commit -m "feat: TelcoSec design — Yaru-teal-dark, Papirus-Dark icons, apps-menu extension, Nautilus bookmarks"
```

---

## Task 4: GDM3 Branded Login Screen

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh`

GDM3 uses its own dconf database, separate from the user session. Setting it requires writing to `/etc/dconf/db/gdm.d/` and creating a profile file at `/etc/dconf/profile/gdm`.

- [ ] **Step 1: Add GDM dconf profile and branding after the design section**

```bash
# 5. GDM3 Login Screen Branding
echo "Branding GDM3 login screen..."
sudo mkdir -p /etc/dconf/db/gdm.d
sudo mkdir -p /etc/dconf/profile

# GDM dconf profile tells the login screen which databases to load
cat << 'EOF' | sudo tee /etc/dconf/profile/gdm
user-db:user
system-db:gdm
EOF

# Login screen settings: same wallpaper, no logo, disable user list for privacy
cat << 'EOF' | sudo tee /etc/dconf/db/gdm.d/00-telcosec-login
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/telcosec/wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/telcosec/wallpaper.png'
picture-options='scaled'
color-shading-type='solid'
primary-color='#0A0E18'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/telcosec/wallpaper.png'
color-shading-type='solid'
primary-color='#0A0E18'

[org/gnome/login-screen]
logo='/usr/share/backgrounds/telcosec/logo.png'
disable-user-list=true
banner-message-enable=true
banner-message-text='TelcoChisel — Telecom Security Research Platform\nDefault credentials: telcosec / telcosec'

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Yaru-teal-dark'
icon-theme='Papirus-Dark'
clock-show-date=true
clock-format='24h'
EOF
```

- [ ] **Step 2: Lock the GDM background so extensions can't override it**

```bash
sudo mkdir -p /etc/dconf/db/gdm.d/locks
cat << 'EOF' | sudo tee /etc/dconf/db/gdm.d/locks/00-telcosec
/org/gnome/desktop/background/picture-uri
/org/gnome/desktop/background/picture-options
/org/gnome/login-screen/disable-user-list
/org/gnome/login-screen/banner-message-enable
/org/gnome/login-screen/banner-message-text
EOF
```

- [ ] **Step 3: Verify syntax and commit**

```bash
bash -n builder/scripts/05-desktop-customization.sh && echo "syntax OK"
git add builder/scripts/05-desktop-customization.sh
git commit -m "feat: GDM3 branded login screen with TelcoSec wallpaper, dark theme, and security banner"
```

---

## Task 5: Rename and Clean the Applications Menu File

**Files:**
- Rename/rewrite: `builder/menu/xfce-applications.menu` → `builder/menu/gnome-applications.menu`
- Modify: `builder/scripts/08-system-optimization.sh`

The `apps-menu` GNOME Shell extension reads `/etc/xdg/menus/gnome-applications.menu`. Renaming our menu file and removing XFCE-specific entries makes the top-bar "Applications" dropdown show all TelcoSec telecom categories.

- [ ] **Step 1: Create `builder/menu/gnome-applications.menu`**

Create the file with this content (removes all XFCE-specific `<Filename>` layout entries and the xfce Settings submenu; renames the root `<Name>` to `Applications`):

```xml
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
  "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">

<Menu>
    <Name>Applications</Name>

    <DefaultAppDirs/>
    <DefaultDirectoryDirs/>

    <!-- 01. SDR & Spectrum -->
    <Menu>
      <Name>SDR &amp; Spectrum</Name>
      <Directory>telcosec-sdr.directory</Directory>
      <Include>
        <Category>TelcoSec-SDR</Category>
      </Include>
    </Menu>

    <!-- 02. GSM / 2G -->
    <Menu>
      <Name>GSM / 2G</Name>
      <Directory>telcosec-gsm.directory</Directory>
      <Include>
        <Category>TelcoSec-GSM</Category>
      </Include>
    </Menu>

    <!-- 03. UMTS / 3G -->
    <Menu>
      <Name>UMTS / 3G</Name>
      <Directory>telcosec-umts.directory</Directory>
      <Include>
        <Category>TelcoSec-UMTS</Category>
      </Include>
    </Menu>

    <!-- 04. LTE / 4G -->
    <Menu>
      <Name>LTE / 4G</Name>
      <Directory>telcosec-lte.directory</Directory>
      <Include>
        <Category>TelcoSec-LTE</Category>
      </Include>
    </Menu>

    <!-- 05. 5G NR -->
    <Menu>
      <Name>5G NR</Name>
      <Directory>telcosec-5gnr.directory</Directory>
      <Include>
        <Category>TelcoSec-5GNR</Category>
      </Include>
    </Menu>

    <!-- 06. Baseband & Firmware -->
    <Menu>
      <Name>Baseband &amp; Firmware</Name>
      <Directory>telcosec-baseband.directory</Directory>
      <Include>
        <Category>TelcoSec-Baseband</Category>
      </Include>
    </Menu>

    <!-- 07. SIM & eSIM -->
    <Menu>
      <Name>SIM &amp; eSIM</Name>
      <Directory>telcosec-sim.directory</Directory>
      <Include>
        <Category>TelcoSec-SIM</Category>
      </Include>
    </Menu>

    <!-- 08. Core Signaling -->
    <Menu>
      <Name>Core Signaling</Name>
      <Directory>telcosec-core.directory</Directory>
      <Include>
        <Category>TelcoSec-Core</Category>
      </Include>
    </Menu>

    <!-- 09. Device Tools -->
    <Menu>
      <Name>Device Tools</Name>
      <Directory>telcosec-device.directory</Directory>
      <Include>
        <Category>TelcoSec-Device</Category>
      </Include>
    </Menu>

    <!-- 10. Network Analysis -->
    <Menu>
      <Name>Network Analysis</Name>
      <Directory>telcosec-network.directory</Directory>
      <Include>
        <Category>TelcoSec-Network</Category>
      </Include>
    </Menu>

    <!-- 11. VoIP & Messaging -->
    <Menu>
      <Name>VoIP &amp; Messaging</Name>
      <Directory>telcosec-voip.directory</Directory>
      <Include>
        <Category>TelcoSec-VoIP</Category>
      </Include>
    </Menu>

    <!-- 12. TETRA & PMR -->
    <Menu>
      <Name>TETRA &amp; PMR</Name>
      <Directory>telcosec-tetra.directory</Directory>
      <Include>
        <Category>TelcoSec-TETRA</Category>
      </Include>
    </Menu>

    <!-- 13. Wordlist Tools -->
    <Menu>
      <Name>Wordlist Tools</Name>
      <Directory>TelcoChisel.directory</Directory>
      <Include>
        <Category>TelcoSec-Tools</Category>
      </Include>
    </Menu>

</Menu>
```

- [ ] **Step 2: Delete the old XFCE menu file**

```bash
rm builder/menu/xfce-applications.menu
git add builder/menu/gnome-applications.menu
git rm builder/menu/xfce-applications.menu
```

- [ ] **Step 3: Update 08-system-optimization.sh to deploy gnome-applications.menu**

Find the block in `08-system-optimization.sh` that copies the menu file. The migration plan (Task 6) already removed the XFCE copy — confirm it now copies nothing for the `.menu` file. Add the GNOME deployment:

```bash
# Deploy GNOME applications menu (read by apps-menu GNOME Shell extension)
if [ -f /tmp/menu/gnome-applications.menu ]; then
  sudo mkdir -p /etc/xdg/menus
  sudo cp /tmp/menu/gnome-applications.menu /etc/xdg/menus/gnome-applications.menu
  sudo chmod 644 /etc/xdg/menus/gnome-applications.menu
fi
```

- [ ] **Step 4: Update build-iso.sh re-sync block**

The re-sync block at line ~168 of `build-iso.sh` already copies `builder/menu` to `$ROOTFS/tmp/menu`. Since we renamed the file inside `builder/menu/`, this is already handled — no change needed to `build-iso.sh`. Confirm:

```bash
grep "cp.*menu" build-iso.sh
```

Expected: `cp -r builder/menu "$ROOTFS/tmp/menu"` present in both blocks.

- [ ] **Step 5: Verify and commit**

```bash
bash -n builder/scripts/08-system-optimization.sh && echo "syntax OK"
ls builder/menu/gnome-applications.menu && echo "menu file present"
git add builder/menu/ builder/scripts/08-system-optimization.sh
git commit -m "feat: rename xfce menu → gnome-applications.menu with clean TelcoSec category hierarchy"
```

---

## Task 6: Security System-Level Hardening in Script 08

**Files:**
- Modify: `builder/scripts/08-system-optimization.sh`

The existing script already hardens the kernel (sysctl), UFW, and SCTP. Add: disable Bluetooth auto-power-on, disable unnecessary GNOME daemons, and set restrictive default umask.

- [ ] **Step 1: Add Bluetooth policy after the UFW section (near line 209)**

```bash
# Bluetooth: present for BLE/TETRA research but off by default
# Researchers enable it manually when needed via GNOME Settings
rfkill block bluetooth 2>/dev/null || true
# Restore on reboot via rfkill-restore unit if present; otherwise stays off
# until user re-enables in GNOME Settings → Bluetooth
```

- [ ] **Step 2: Add umask hardening**

```bash
# Set restrictive default umask: new files are 640, new dirs are 750.
# Security researchers should not inadvertently world-readable capture files.
echo 'umask 027' | sudo tee /etc/profile.d/telcosec_umask.sh
```

- [ ] **Step 3: Disable unnecessary GNOME background daemons**

```bash
# Disable GNOME color profile daemon (colord) — only needed for printers/monitors
# calibration; wastes resources and is a network-accessible D-Bus service.
sudo systemctl disable colord 2>/dev/null || true

# Disable GNOME remote login (gnome-remote-desktop)
sudo systemctl disable gnome-remote-desktop 2>/dev/null || true

# Disable Avahi mDNS — unwanted network advertisement on a pentest/research host
sudo systemctl disable avahi-daemon 2>/dev/null || true
sudo systemctl mask avahi-daemon 2>/dev/null || true
```

- [ ] **Step 4: Verify and commit**

```bash
bash -n builder/scripts/08-system-optimization.sh && echo "syntax OK"
git add builder/scripts/08-system-optimization.sh
git commit -m "feat: system hardening — Bluetooth off by default, umask 027, disable colord/avahi/gnome-remote-desktop"
```

---

## Task 7: Final dconf compile and static verification

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh`

- [ ] **Step 1: Confirm dconf update runs at the end of the security + design additions**

The `dconf update` call in the migration plan's Task 4 runs after `02-telcosec-terminal`. Confirm it is positioned AFTER all four new dconf files (`03-telcosec-security`, `04-telcosec-design`, and the gdm.d database):

```bash
grep -n "dconf update" builder/scripts/05-desktop-customization.sh
```

If `dconf update` appears before the new security/design sections, move it to after all dconf db writes. The final sequence in the script should be:
1. Write `00-telcosec` (migration plan)
2. Write `01-telcosec-appfolders` (migration plan)
3. Write `02-telcosec-terminal` (migration plan)
4. Write `03-telcosec-security` (this plan, Task 2)
5. Write `04-telcosec-design` (this plan, Task 3)
6. Write `/etc/dconf/db/gdm.d/00-telcosec-login` + `/etc/dconf/profile/gdm` (this plan, Task 4)
7. `sudo dconf update` ← must be last

- [ ] **Step 2: Run static verification**

```bash
# Syntax checks
for f in builder/scripts/00-install-all-packages.sh \
          builder/scripts/05-desktop-customization.sh \
          builder/scripts/08-system-optimization.sh; do
  bash -n "$f" && echo "OK: $f" || echo "FAIL: $f"
done

# No XFCE menu file remains
ls builder/menu/xfce-applications.menu 2>/dev/null && echo "STALE FILE - remove it" || echo "Clean"

# New GNOME menu file present
ls builder/menu/gnome-applications.menu && echo "OK"

# dconf files present
grep -l "telcosec" builder/scripts/05-desktop-customization.sh && echo "dconf sections: OK"

# Packages present
grep "yaru-theme-gtk\|papirus-icon\|gnome-shell-extensions\|appindicator" \
  builder/scripts/00-install-all-packages.sh | wc -l
# Expected: ≥ 4 lines
```

- [ ] **Step 3: Final commit**

```bash
git add -A
git status  # should be clean if tasks committed individually
```

---

## Verification (Post-Build)

After booting the ISO:

1. **Login screen**: GDM3 shows the TelcoSec wallpaper as background, dark theme, and the security banner text `TelcoChisel — Telecom Security Research Platform / Default credentials: telcosec / telcosec`. No user list visible.

2. **Desktop**: GNOME 46 loads with Yaru-teal-dark theme (teal accents in top bar, window borders). Icons are Papirus-Dark. Wallpaper is the TelcoSec background.

3. **Top bar — Applications menu**: Clicking "Applications" in the top-left shows a dropdown with 13 categories: SDR & Spectrum, GSM/2G, UMTS/3G, LTE/4G, 5G NR, Baseband & Firmware, SIM & eSIM, Core Signaling, Device Tools, Network Analysis, VoIP & Messaging, TETRA & PMR, Wordlist Tools.

4. **Top bar — Places menu**: Clicking "Places" shows bookmarks including "Telecom Wordlists", "TelcoSec Tools", "TelcoSec Docs".

5. **App grid**: Activities → App Grid shows 12 category folders (SDR, GSM, LTE, 5G NR, etc.) as folder icons.

6. **Privacy check**: `gsettings get org.gnome.desktop.privacy report-technical-problems` → `false`. `gsettings get org.gnome.desktop.media-handling automount` → `false`.

7. **USB plug test**: Insert a USB drive — it should NOT auto-mount or open Nautilus. Must be mounted manually from the Places menu.

8. **Theme check**: GNOME Tweaks → Appearance shows GTK = `Yaru-teal-dark`, Icons = `Papirus-Dark`, Shell = `Yaru-teal-dark`.

9. **Bluetooth**: `rfkill list bluetooth` → soft blocked. Researchers can unblock in GNOME Settings → Bluetooth when needed.

10. **Apport**: `systemctl status apport` → masked/disabled.
