# GNOME 46 Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the XFCE + LightDM desktop stack with GNOME 46 + GDM3, set GNOME Terminal as the system default with 5 preconfigured profiles (General/Monitor/Analysis/Network/Console), and wire all 47 tool launchers into GNOME's app-grid folder system organized by telecom category.

**Architecture:** All desktop configuration moves from XFCE XML files (`/etc/skel/.config/xfce4/`) and LightDM conf to system-wide dconf db files (`/etc/dconf/db/local.d/`) compiled via `dconf update` inside the chroot. GNOME Terminal profiles are stored as dconf keys. App-grid folders use `org.gnome.desktop.app-folders` with `categories=` matching the existing `TelcoSec-*` categories already on every `.desktop` launcher — so the 47 launchers need no category changes, only a terminal invocation syntax change.

**Tech Stack:** Ubuntu 24.04 (GNOME 46), GDM3, GNOME Terminal, dconf, gsettings, Calamares.

---

## File Map

| File | Change |
|---|---|
| `builder/scripts/00-install-all-packages.sh` | Swap `xfce4 xfce4-goodies lightdm lightdm-gtk-greeter` → GNOME packages |
| `builder/scripts/01-install-base.sh` | `systemctl enable lightdm` → `gdm3` |
| `builder/scripts/05-desktop-customization.sh` | Major rewrite: remove ~400 lines of XFCE XML/LightDM; add GDM3 config + dconf db files |
| `builder/scripts/08-system-optimization.sh` | Skip XFCE `.menu` file deployment; keep `.desktop`/`.directory` deployment |
| `builder/menu/applications/*.desktop` (all 47) | `Exec=terminator` → `Exec=gnome-terminal` with GNOME Terminal flag syntax |
| `builder/calamares/modules/displaymanager.conf` | `lightdm` → `gdm3`; `startxfce4` → `gnome-session`; `xfce.desktop` → `gnome.desktop` |
| `builder/calamares/modules/services-systemd.conf` | `lightdm` → `gdm3` |

---

## Task 1: Swap Desktop Packages

**Files:**
- Modify: `builder/scripts/00-install-all-packages.sh`

- [ ] **Step 1: Open the file and find the desktop package line**

Line ~125 reads:
```
xfce4 xfce4-goodies lightdm lightdm-gtk-greeter \
```

- [ ] **Step 2: Replace XFCE/LightDM packages with GNOME/GDM3**

Change that line to:
```
gnome-shell gnome-session gnome-control-center \
gdm3 nautilus gnome-tweaks dconf-cli \
```

Also find the line `terminator firefox \` (near line 125) — restore `gnome-terminal` since it is now the primary terminal:
```
gnome-terminal terminator firefox \
```
*(terminator is kept as a fallback but gnome-terminal becomes the default)*

Verify the edit:
```bash
grep -n "gnome-shell\|gdm3\|gnome-terminal\|xfce4\|lightdm" builder/scripts/00-install-all-packages.sh
```
Expected: `xfce4`, `lightdm`, `lightdm-gtk-greeter` absent; new GNOME packages present.

- [ ] **Step 3: Commit**

```bash
git add builder/scripts/00-install-all-packages.sh
git commit -m "feat: swap XFCE/LightDM packages for GNOME 46/GDM3"
```

---

## Task 2: Update Service Enablement

**Files:**
- Modify: `builder/scripts/01-install-base.sh`

- [ ] **Step 1: Find the service enablement line**

Line ~44 reads:
```bash
sudo systemctl enable lightdm
```

- [ ] **Step 2: Replace with GDM3**

```bash
sudo systemctl enable gdm3
```

- [ ] **Step 3: Find and update standalone fallback package list**

In the same file, the standalone fallback apt line (~line 28) references `terminator gnome-terminal firefox` — ensure it matches the new package set. Change:
```bash
    terminator firefox \
```
to:
```bash
    gnome-terminal terminator firefox \
```
(if `gnome-terminal` is not already there after Task 1 restored it)

- [ ] **Step 4: Verify and commit**

```bash
bash -n builder/scripts/01-install-base.sh && echo "syntax OK"
git add builder/scripts/01-install-base.sh
git commit -m "feat: enable gdm3 instead of lightdm"
```

---

## Task 3: Rewrite Desktop Customization — GDM3 + dconf Core GNOME Settings

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh`

This task replaces the LightDM config block (lines 10–31) and all XFCE XML config blocks (lines 44–360) with GDM3 autologin and a dconf db file for GNOME core settings. The DE-agnostic sections (casper.conf, MOTD, bash prompt, Firefox, NetworkManager, Wireshark, autostart) are retained.

- [ ] **Step 1: Delete the LightDM config section**

Remove lines from `# 1. Custom Wallpaper & LightDM Login Background` down through line 31 (the lightdm.conf.d heredoc). Replace with:

```bash
# 1. GDM3 Autologin + Wallpaper Directory
echo "Configuring GDM3 autologin..."
sudo mkdir -p /usr/share/backgrounds/telcosec
sudo mkdir -p /etc/gdm3

cat << 'EOF' | sudo tee /etc/gdm3/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=telcosec

[security]

[xdmcp]

[chooser]

[debug]
EOF
```

- [ ] **Step 2: Delete the XFCE session skeleton section**

Remove everything from the comment `# XFCE session skeleton` (line ~44) through to the block that copies the skeleton to `/home/telcosec/` (line ~357). This is the largest deletion — the entire `xfce4-session.xml`, `xsettings.xml`, `xfwm4.xml`, `xfce4-desktop.xml`, `xfce4-panel.xml`, `xfce4-power-manager.xml`, `xfce4-screensaver.xml`, `xfce4-keyboard-shortcuts.xml`, `thunar.xml`, `xfce4-notifyd.xml`, and `whiskermenu-1.rc` heredocs, plus the `cp -r /etc/skel/.config/xfce4 /home/telcosec/` lines.

In place of all that, insert the dconf core settings block:

```bash
# 2. GNOME system-wide dconf configuration
echo "Writing GNOME dconf configuration..."
sudo mkdir -p /etc/dconf/db/local.d

cat << 'EOF' | sudo tee /etc/dconf/db/local.d/00-telcosec
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/telcosec/wallpaper.png'
picture-uri-dark='file:///usr/share/backgrounds/telcosec/wallpaper.png'
picture-options='scaled'

[org/gnome/desktop/screensaver]
lock-enabled=false
idle-activation-enabled=false

[org/gnome/desktop/session]
idle-delay=uint32 0

[org/gnome/settings-daemon/plugins/power]
sleep-inactive-ac-type='nothing'
sleep-inactive-battery-type='nothing'
sleep-inactive-ac-timeout=0
sleep-inactive-battery-timeout=0
power-button-action='nothing'

[org/gnome/desktop/interface]
font-name='Sans 10'
monospace-font-name='IBM Plex Mono 11'
color-scheme='prefer-dark'
enable-animations=true

[org/gnome/desktop/wm/preferences]
button-layout=':minimize,maximize,close'
num-workspaces=4

[org/gnome/desktop/wm/keybindings]
switch-to-workspace-1=['<Super>1']
switch-to-workspace-2=['<Super>2']
switch-to-workspace-3=['<Super>3']
switch-to-workspace-4=['<Super>4']
maximize=['<Super>Up']
unmaximize=['<Super>Down']
tile-left=['<Super>Left']
tile-right=['<Super>Right']

[org/gnome/mutter]
edge-tiling=true

[org/gnome/shell]
favorite-apps=['org.gnome.Terminal.desktop', 'firefox.desktop', 'org.wireshark.Wireshark.desktop', 'org.gnome.Nautilus.desktop', 'gnuradio-companion.desktop', 'gqrx.desktop', 'open5gs-start.desktop', 'wireshark-mon.desktop']

[org/gnome/desktop/notifications]
show-banners=true
show-in-lock-screen=false
EOF
```

- [ ] **Step 3: Insert GNOME app-folder config (replaces Whisker Menu categories)**

Immediately after Step 2's heredoc, insert:

```bash
cat << 'EOF' | sudo tee /etc/dconf/db/local.d/01-telcosec-appfolders
[org/gnome/desktop/app-folders]
folder-children=['SDR', 'GSM', 'LTE', 'NR5G', 'Baseband', 'SIM', 'Core', 'Device', 'Network', 'VoIP', 'TETRA']

[org/gnome/desktop/app-folders/folders/SDR]
name='SDR & Spectrum'
categories=['TelcoSec-SDR']

[org/gnome/desktop/app-folders/folders/GSM]
name='GSM / 2G'
categories=['TelcoSec-GSM']

[org/gnome/desktop/app-folders/folders/LTE]
name='LTE / 4G'
categories=['TelcoSec-LTE']

[org/gnome/desktop/app-folders/folders/NR5G]
name='5G NR'
categories=['TelcoSec-5GNR']

[org/gnome/desktop/app-folders/folders/Baseband]
name='Baseband & Firmware'
categories=['TelcoSec-Baseband']

[org/gnome/desktop/app-folders/folders/SIM]
name='SIM & eSIM'
categories=['TelcoSec-SIM', 'TelcoSec-Tools']

[org/gnome/desktop/app-folders/folders/Core]
name='Core Signaling'
categories=['TelcoSec-Core']

[org/gnome/desktop/app-folders/folders/Device]
name='Device Tools'
categories=['TelcoSec-Device']

[org/gnome/desktop/app-folders/folders/Network]
name='Network Analysis'
categories=['TelcoSec-Network']

[org/gnome/desktop/app-folders/folders/VoIP]
name='VoIP & Messaging'
categories=['TelcoSec-VoIP']

[org/gnome/desktop/app-folders/folders/TETRA]
name='TETRA & PMR'
categories=['TelcoSec-TETRA']
EOF
```

- [ ] **Step 4: Verify script syntax**

```bash
bash -n builder/scripts/05-desktop-customization.sh && echo "syntax OK"
```

- [ ] **Step 5: Commit**

```bash
git add builder/scripts/05-desktop-customization.sh
git commit -m "feat: replace XFCE/LightDM config with GDM3 + GNOME dconf core settings and app-folders"
```

---

## Task 4: GNOME Terminal Profiles via dconf

**Files:**
- Modify: `builder/scripts/05-desktop-customization.sh`

Replace the Terminator config section (old lines ~569–722: `# 6. Terminator`, `helpers.rc`, and the large Terminator `config` heredoc) with GNOME Terminal dconf profiles and a `mimeapps.list` for the default terminal.

- [ ] **Step 1: Delete the Terminator config section**

Remove from the `# 6. Terminator` comment block down through the copy of Terminator config to `/home/telcosec/.config/terminator/config` and the `update-alternatives --set x-terminal-emulator` line. Also remove the `helpers.rc` write block.

- [ ] **Step 2: Insert GNOME Terminal profiles dconf file**

```bash
# 6. GNOME Terminal profiles
echo "Configuring GNOME Terminal profiles..."
cat << 'EOF' | sudo tee /etc/dconf/db/local.d/02-telcosec-terminal
[org/gnome/terminal/legacy]
theme-variant='dark'
default-show-menubar=false

[org/gnome/terminal/legacy/profiles:]
list=['b1dcc9dd-5262-4d8d-a863-c897e6d979b9', 'a47c8e1d-7b3f-4a5e-9c21-f83d4e2b1a90', 'c8f2d903-5a1b-4c8d-b7e3-29a1f4d0e5c7', 'd1b4a7e2-8c3d-4f9a-a6b1-3c2e0f5a7b8d', 'e5c6b891-2d4a-4e7f-8c10-b4f3a1e9d027']
default='b1dcc9dd-5262-4d8d-a863-c897e6d979b9'

[org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9]
visible-name='General'
font='IBM Plex Mono 11'
use-system-font=false
use-custom-command=true
custom-command='tmux new-session -A -s general'
background-color='#0D1117'
foreground-color='#C9D1D9'
palette=['#0D1117', '#FF6B6B', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#FF7B7B', '#A8D389', '#F5D08B', '#71BFFF', '#D688E7', '#66C6D2', '#FFFFFF']
use-theme-colors=false
background-transparency-percent=5
use-transparent-background=true
scrollback-unlimited=true
cursor-shape='block'
cursor-blink-mode='on'
audible-bell=false

[org/gnome/terminal/legacy/profiles:/:a47c8e1d-7b3f-4a5e-9c21-f83d4e2b1a90]
visible-name='Monitor'
font='IBM Plex Mono 11'
use-system-font=false
use-custom-command=true
custom-command='tmux new-session -A -s monitor'
background-color='#050C18'
foreground-color='#00BFFF'
palette=['#050C18', '#FF6B6B', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#FF7B7B', '#A8D389', '#F5D08B', '#71BFFF', '#D688E7', '#66C6D2', '#FFFFFF']
use-theme-colors=false
background-transparency-percent=5
use-transparent-background=true
scrollback-unlimited=true
cursor-shape='underline'
cursor-blink-mode='on'
audible-bell=false

[org/gnome/terminal/legacy/profiles:/:c8f2d903-5a1b-4c8d-b7e3-29a1f4d0e5c7]
visible-name='Analysis'
font='IBM Plex Mono 11'
use-system-font=false
use-custom-command=true
custom-command='tmux new-session -A -s analysis'
background-color='#0A1A0F'
foreground-color='#00FF7F'
palette=['#0A1A0F', '#FF6B6B', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#FF7B7B', '#A8D389', '#F5D08B', '#71BFFF', '#D688E7', '#66C6D2', '#FFFFFF']
use-theme-colors=false
background-transparency-percent=5
use-transparent-background=true
scrollback-unlimited=true
cursor-shape='block'
cursor-blink-mode='on'
audible-bell=false

[org/gnome/terminal/legacy/profiles:/:d1b4a7e2-8c3d-4f9a-a6b1-3c2e0f5a7b8d]
visible-name='Network'
font='IBM Plex Mono 11'
use-system-font=false
use-custom-command=true
custom-command='tmux new-session -A -s network'
background-color='#1A0808'
foreground-color='#FF4500'
palette=['#1A0808', '#FF6B6B', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#FF7B7B', '#A8D389', '#F5D08B', '#71BFFF', '#D688E7', '#66C6D2', '#FFFFFF']
use-theme-colors=false
background-transparency-percent=5
use-transparent-background=true
scrollback-unlimited=true
cursor-shape='block'
cursor-blink-mode='on'
audible-bell=false

[org/gnome/terminal/legacy/profiles:/:e5c6b891-2d4a-4e7f-8c10-b4f3a1e9d027]
visible-name='Console'
font='IBM Plex Mono 11'
use-system-font=false
use-custom-command=false
background-color='#1C1C1C'
foreground-color='#DCDCDC'
palette=['#1C1C1C', '#FF6B6B', '#98C379', '#E5C07B', '#61AFEF', '#C678DD', '#56B6C2', '#ABB2BF', '#5C6370', '#FF7B7B', '#A8D389', '#F5D08B', '#71BFFF', '#D688E7', '#66C6D2', '#FFFFFF']
use-theme-colors=false
background-transparency-percent=2
use-transparent-background=true
scrollback-unlimited=true
cursor-shape='block'
cursor-blink-mode='on'
audible-bell=false
EOF

# Compile all dconf db files into the binary database
sudo dconf update
echo "dconf database compiled."
```

- [ ] **Step 3: Set GNOME Terminal as system default (replaces helpers.rc + update-alternatives)**

Find the `/etc/environment` append for `TERMINAL=terminator` (near the old helpers.rc block) and change it to:
```bash
# Set default terminal for scripts and launchers
grep -q '^TERMINAL=' /etc/environment && \
  sudo sed -i 's/^TERMINAL=.*/TERMINAL=gnome-terminal/' /etc/environment || \
  echo 'TERMINAL=gnome-terminal' | sudo tee -a /etc/environment

# Set system-wide x-terminal-emulator alternative
sudo update-alternatives --set x-terminal-emulator /usr/bin/gnome-terminal || true

# XDG default terminal via mimeapps (replaces XFCE helpers.rc)
sudo mkdir -p /etc/skel/.config
cat << 'EOF' | sudo tee /etc/skel/.config/mimeapps.list
[Default Applications]
x-scheme-handler/terminal=org.gnome.Terminal.desktop
EOF
sudo cp /etc/skel/.config/mimeapps.list /home/telcosec/.config/mimeapps.list
sudo chown telcosec:telcosec /home/telcosec/.config/mimeapps.list
```

- [ ] **Step 4: Update the autostart file (last block of script 05)**

Find the `/etc/xdg/autostart/telcosec-terminal.desktop` block (currently launches Terminator with `--layout=default`) and replace the `Exec=` line:

```bash
cat << 'EOF' | sudo tee /etc/xdg/autostart/telcosec-terminal.desktop
[Desktop Entry]
Type=Application
Name=TelcoSec Terminal
Comment=Open GNOME Terminal with tmux general session on login
Exec=gnome-terminal --title "TelcoSec Terminal" -- bash -c "tmux new-session -A -s general; exec bash"
Icon=org.gnome.Terminal
X-GNOME-Autostart-enabled=true
EOF
```

- [ ] **Step 5: Verify and commit**

```bash
bash -n builder/scripts/05-desktop-customization.sh && echo "syntax OK"
grep -n "xfce\|lightdm\|terminator" builder/scripts/05-desktop-customization.sh | grep -iv "comment\|#" || echo "Clean: no XFCE/LightDM/terminator references"
git add builder/scripts/05-desktop-customization.sh
git commit -m "feat: add GNOME Terminal dconf profiles, app-folder menu, and autostart"
```

---

## Task 5: Update All 47 Tool Launchers — terminator → gnome-terminal

**Files:**
- Modify: `builder/menu/applications/*.desktop` (all 47 files)

All launchers currently use `Exec=terminator [-e|-e "bash -c ..."]`. GNOME Terminal uses `-- bash -c "..."` syntax instead of `-e "..."`.

- [ ] **Step 1: Run the bulk conversion**

```bash
cd builder/menu/applications

# Step A: replace 'terminator' binary name with 'gnome-terminal'
sed -i 's/^Exec=terminator /Exec=gnome-terminal /g' *.desktop

# Step B: replace '-e ' (terminator run flag) with '-- bash -c '
# This handles both: -e "CMD" and -e "bash -c '...'"
sed -i 's/ -e "/ -- bash -c "/g' *.desktop

cd - > /dev/null
```

- [ ] **Step 2: Verify no terminator references remain in Exec lines**

```bash
grep "^Exec=terminator" builder/menu/applications/*.desktop && echo "FOUND - fix needed" || echo "Clean"
```

Expected: `Clean`

- [ ] **Step 3: Spot-check 3 launchers manually**

```bash
grep "^Exec=" builder/menu/applications/kismet.desktop
grep "^Exec=" builder/menu/applications/5ghoul-fuzzer.desktop
grep "^Exec=" builder/menu/applications/gqrx.desktop
```

Expected output pattern (kismet example):
```
Exec=gnome-terminal -- bash -c "sudo kismet -c mon0"
```

- [ ] **Step 4: Commit**

```bash
git add builder/menu/applications/
git commit -m "feat: migrate all tool launchers from terminator to gnome-terminal"
```

---

## Task 6: Update 08-system-optimization.sh — Skip XFCE Menu File

**Files:**
- Modify: `builder/scripts/08-system-optimization.sh`

Script 08 currently deploys `xfce-applications.menu` to `/etc/xdg/menus/xfce-applications.menu`, which is only read by XFCE's panel. GNOME uses `org.gnome.desktop.app-folders` (already configured via dconf in Task 3). The `.desktop` and `.directory` file deployment in the same block is still needed by GNOME for app-grid and search.

- [ ] **Step 1: Find the menu deployment block**

Lines ~26–43 read:
```bash
echo "Deploying custom XFCE tool menus and categories..."
...
if [ -f /tmp/menu/xfce-applications.menu ]; then
  sudo cp /tmp/menu/xfce-applications.menu /etc/xdg/menus/xfce-applications.menu
  sudo chmod 644 /etc/xdg/menus/xfce-applications.menu
fi
```

- [ ] **Step 2: Update the echo message and remove the xfce-applications.menu copy**

Replace that block with:
```bash
echo "Deploying TelcoSec tool application launchers and categories..."

# .directory category metadata (used by GNOME app-grid folder names)
sudo mkdir -p /usr/share/desktop-directories/
if [ -d /tmp/menu/directories ]; then
  sudo cp -rf /tmp/menu/directories/. /usr/share/desktop-directories/
fi

# .desktop launchers (used by GNOME app search and app-folder category matching)
sudo mkdir -p /usr/share/applications/
if [ -d /tmp/menu/applications ]; then
  sudo cp -rf /tmp/menu/applications/. /usr/share/applications/
  sudo chmod 644 /usr/share/applications/*.desktop || true
fi
```

(The `xfce-applications.menu` copy block is simply removed — GNOME does not read it.)

- [ ] **Step 3: Verify and commit**

```bash
bash -n builder/scripts/08-system-optimization.sh && echo "syntax OK"
grep "xfce-applications.menu" builder/scripts/08-system-optimization.sh && echo "FOUND - fix needed" || echo "Clean"
git add builder/scripts/08-system-optimization.sh
git commit -m "feat: update menu deployment for GNOME (drop xfce menu file, keep desktop launchers)"
```

---

## Task 7: Update Calamares Installer Config

**Files:**
- Modify: `builder/calamares/modules/displaymanager.conf`
- Modify: `builder/calamares/modules/services-systemd.conf`

These files tell Calamares how to configure the installed system's display manager and which services to enable.

- [ ] **Step 1: Update displaymanager.conf**

Current content (relevant section):
```yaml
displaymanagers:
    - lightdm

defaultDesktopEnvironment:
    executable: startxfce4
    desktopFile: xfce.desktop
```

Replace with:
```yaml
displaymanagers:
    - gdm3

defaultDesktopEnvironment:
    executable: gnome-session
    desktopFile: gnome.desktop
```

- [ ] **Step 2: Update services-systemd.conf**

Current:
```yaml
services:
    - name: lightdm
      enabled: true
```

Change `lightdm` to `gdm3`:
```yaml
services:
    - name: gdm3
      enabled: true
```

- [ ] **Step 3: Verify and commit**

```bash
grep -n "lightdm\|xfce\|startxfce4" builder/calamares/modules/displaymanager.conf builder/calamares/modules/services-systemd.conf && echo "FOUND - fix needed" || echo "Clean"
git add builder/calamares/modules/displaymanager.conf builder/calamares/modules/services-systemd.conf
git commit -m "feat: update Calamares to install with GDM3 and GNOME session"
```

---

## Task 8: Static Verification Pass

- [ ] **Step 1: Bash syntax check all modified scripts**

```bash
for f in builder/scripts/00-install-all-packages.sh \
          builder/scripts/01-install-base.sh \
          builder/scripts/05-desktop-customization.sh \
          builder/scripts/08-system-optimization.sh; do
  bash -n "$f" && echo "OK: $f" || echo "FAIL: $f"
done
```

Expected: all `OK`.

- [ ] **Step 2: Check no XFCE packages remain**

```bash
grep -n "xfce4\b\|xfce4-goodies\|lightdm\b\|lightdm-gtk" \
  builder/scripts/00-install-all-packages.sh \
  builder/scripts/01-install-base.sh
```

Expected: no output.

- [ ] **Step 3: Check no terminator Exec lines remain in launchers**

```bash
grep -l "^Exec=terminator" builder/menu/applications/*.desktop && echo "FOUND" || echo "Clean"
```

Expected: `Clean`.

- [ ] **Step 4: Confirm GNOME Terminal Exec lines look correct**

```bash
grep "^Exec=" builder/menu/applications/kismet.desktop \
             builder/menu/applications/gqrx.desktop \
             builder/menu/applications/open5gs-start.desktop
```

Expected pattern: `Exec=gnome-terminal [--title "..."] -- bash -c "..."`

- [ ] **Step 5: Confirm dconf files will be written by script 05**

```bash
grep -n "dconf\|/etc/dconf\|00-telcosec\|01-telcosec\|02-telcosec" \
  builder/scripts/05-desktop-customization.sh
```

Expected: lines for `/etc/dconf/db/local.d/00-telcosec`, `01-telcosec-appfolders`, `02-telcosec-terminal`, and `dconf update`.

- [ ] **Step 6: Confirm Calamares is clean**

```bash
grep -n "lightdm\|xfce\|startxfce4" \
  builder/calamares/modules/displaymanager.conf \
  builder/calamares/modules/services-systemd.conf && echo "FOUND" || echo "Clean"
```

Expected: `Clean`.

- [ ] **Step 7: Final commit**

```bash
git add -A
git status  # review — should be clean if all tasks committed incrementally
```

---

## Verification (Post-Build)

After running `wsl -d kali-linux -u root -- bash -c "cd //mnt//m//TelcoChisel && SQUASHFS_LEVEL=3 ./build-iso.sh"`:

1. Boot the ISO (or mount squashfs). The GDM3 login screen should appear briefly then auto-login to GNOME 46 as `telcosec`.

2. Activities → App Grid should show 11 category folders (SDR, GSM, LTE, 5G NR, Baseband, SIM, Core, Network, VoIP, TETRA, Device). Each folder opens to list the matching tools.

3. Right-click any desktop folder → "Open Terminal" should open GNOME Terminal. The `General` profile should auto-attach to a tmux session named `general`.

4. In GNOME Terminal: Right-click tab bar → "New Terminal with Profile" should show all 5 profiles (General/Monitor/Analysis/Network/Console) with distinct background colors.

5. `echo $TERMINAL` → `gnome-terminal`

6. Calamares installer (run from live desktop) → "Install TelcoChisel" should proceed without errors and produce a system that boots into GNOME with GDM3.
