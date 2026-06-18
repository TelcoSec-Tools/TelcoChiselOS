#!/bin/bash
set -e

echo "=== Customizing Desktop Environment ==="

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

# Tell casper which user is the live session user.
# Without this, casper's 10adduser hook doesn't configure LightDM autologin
# on first boot and the session never starts.
cat << 'EOF' | sudo tee /etc/casper.conf
export USERNAME=telcosec
export USERFULLNAME="TelcoSec Researcher"
export HOST=TelcoChisel
export BUILD_SYSTEM=Ubuntu
export FLAVOUR=ubuntu
EOF

# 2. GNOME system-wide dconf configuration
echo "Writing GNOME dconf configuration..."
sudo mkdir -p /etc/dconf/db/local.d

cat << 'EOF' | sudo tee /etc/dconf/db/local.d/00-telcosec
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/telcosec/wallpaper.jpg'
picture-uri-dark='file:///usr/share/backgrounds/telcosec/wallpaper.jpg'
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

cat << 'EOF' | sudo tee /etc/dconf/db/local.d/01-telcosec-appfolders
[org/gnome/desktop/app-folders]
folder-children=['SDR', 'GSM', 'LTE', 'NR5G', 'Baseband', 'SIM', 'Core', 'Device', 'Network', 'VoIP']

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
EOF

# 2. Message of the Day (MOTD)
echo "Configuring MOTD..."
# Remove default Ubuntu dynamic MOTD scripts for a cleaner look
sudo rm -f /etc/update-motd.d/10-help-text /etc/update-motd.d/50-motd-news

# Create a custom TelcoSec ASCII Art MOTD
cat << 'EOF' | sudo tee /etc/update-motd.d/05-telcosec-logo
#!/bin/sh
echo "  _______    __           _____           "
echo " |__   __|  | |          / ____|          "
echo "    | | ___ | | ___ ___ | (___   ___  ___ "
echo "    | |/ _ \| |/ __/ _ \ \___ \ / _ \/ __|"
echo "    | |  __/| | (_| (_) |____) |  __/ (__ "
echo "    |_|\___||_|\___\___/|_____/ \___|\___|"
echo "                                          "
echo "      --- Telecom Security Platform ---   "
echo ""
EOF
sudo chmod +x /etc/update-motd.d/05-telcosec-logo

# 3. Custom Rich Bash Prompt (Optimized, Simple, Zero-Lag, Single-Line Style)
echo "Configuring Global Bash Prompt..."
cat << 'PROMPTEOF' | sudo tee /etc/profile.d/telcosec_prompt.sh
# TelcoSec simple prompt: user@host:dir $
__telcosec_ps1() {
  local EXIT="$?"
  
  # Colors mapped to ANSI standards
  local CY='\[\e[0;36m\]'      # user@host (ANSI Cyan)
  local W='\[\e[1;37m\]'       # path/directory (ANSI White)
  local R='\[\e[0m\]'          # reset
  local RED='\[\e[0;31m\]'     # error indicator (ANSI Red)
  
  # Exit status indicator for the prompt symbol ($ for user, # for root)
  local p_symbol="\$"
  if [ "$EXIT" -ne 0 ]; then
    p_symbol="${RED}${p_symbol}"
  else
    p_symbol="${CY}${p_symbol}"
  fi

  PS1="${CY}\u@\h${R}:${W}\w${R} ${p_symbol}${R} "
}
export PROMPT_COMMAND=__telcosec_ps1
PROMPTEOF
sudo chmod +x /etc/profile.d/telcosec_prompt.sh

# gnome-terminal (and most graphical terminals) open non-login interactive
# bash, which sources /etc/bash.bashrc but NOT /etc/profile.d/*.sh — so the
# function is never defined and PROMPT_COMMAND fires "__telcosec_ps1: command
# not found" every keystroke. Source the prompt file from bash.bashrc to cover
# both login and non-login shells.
if ! grep -q "telcosec_prompt" /etc/bash.bashrc 2>/dev/null; then
  cat >> /etc/bash.bashrc << 'BASHRC'
# TelcoSec custom prompt (also loaded by /etc/profile.d/ for login shells)
if [ -f /etc/profile.d/telcosec_prompt.sh ]; then
    . /etc/profile.d/telcosec_prompt.sh
fi
BASHRC
fi

# 4. Deploy Local Documentation & Configure Firefox Policies
echo "Deploying local documentation..."
sudo mkdir -p /usr/share/doc/telcosec/
if [ -d /tmp/docs ]; then
  sudo cp -rf /tmp/docs/. /usr/share/doc/telcosec/
  sudo find /usr/share/doc/telcosec/ -type f -exec chmod 644 {} +
fi

echo "Configuring Firefox enterprise policies..."
sudo mkdir -p /etc/firefox/policies/
cat << 'EOF' | sudo tee /etc/firefox/policies/policies.json
{
  "policies": {
    "DisableAppUpdate": true,
    "Certificates": {
      "Install": [
        "/usr/local/share/ca-certificates/telcosec-ca.crt",
        "/usr/local/share/ca-certificates/cloudflare_origin_ecc.crt",
        "/usr/local/share/ca-certificates/cloudflare_origin_rsa.crt"
      ]
    },
    "Homepage": {
      "URL": "file:///usr/share/doc/telcosec/index.html",
      "Locked": false,
      "StartPage": "homepage"
    },
    "Bookmarks": [
      {
        "Title": "TelcoSec Local Docs",
        "URL": "file:///usr/share/doc/telcosec/index.html",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec Community Hub",
        "URL": "https://community.telcosec.cloud/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec Academy",
        "URL": "https://app.telcosec.net/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec Blog",
        "URL": "https://blog.telcosec.cloud/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec Tools",
        "URL": "https://tools.telcosec.cloud/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec Calculators",
        "URL": "https://calculators.telcosec.cloud/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec CTF Portal",
        "URL": "https://ctf.telcosec.cloud/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec 3GPP Tracker",
        "URL": "https://3gpp.telcosec.cloud/",
        "Placement": "toolbar"
      },
      {
        "Title": "TelcoSec Discord Chat",
        "URL": "https://discord.gg/RykzXTQFXF",
        "Placement": "toolbar"
      }
    ]
  }
}
EOF

# 5. Network: DHCP default + dedicated monitoring interface
echo "Configuring network defaults..."
sudo mkdir -p /etc/NetworkManager/conf.d
cat << 'EOF' | sudo tee /etc/NetworkManager/conf.d/telcosec.conf
[main]
dhcp=internal

[device]
wifi.scan-rand-mac-address=no
carrier-wait-timeout=2000

[connection]
ipv4.dhcp-timeout=10
ipv6.dhcp-timeout=10
ipv4.may-fail=yes
ipv6.may-fail=yes
EOF

# Configure LAN interface ens160 to use DHCP via Netplan (Ubuntu 24.04 defaults)
sudo mkdir -p /etc/netplan
cat << 'EOF' | sudo tee /etc/netplan/90-telcosec-ens160.yaml
network:
  version: 2
  renderer: NetworkManager
  ethernets:
    ens160:
      dhcp4: true
      dhcp6: true
      optional: true
EOF

# Monitoring interface setup script (creates mon0 from first available wlan)
cat << 'EOF' | sudo tee /usr/local/bin/telcosec-mon-setup
#!/bin/bash
# Bring up a monitor-mode interface (mon0) from the first wireless adapter.
# Called at boot via telcosec-mon.service.
WLAN=$(iw dev 2>/dev/null | awk '/Interface/{print $2}' | grep -v '^mon' | head -1)
if [ -z "$WLAN" ]; then
  echo "telcosec-mon-setup: no wireless interface found, skipping mon0 creation"
  exit 0
fi
if ip link show mon0 &>/dev/null; then
  echo "telcosec-mon-setup: mon0 already exists"
  exit 0
fi
echo "telcosec-mon-setup: creating mon0 from ${WLAN}"
ip link set "$WLAN" down
iw dev "$WLAN" interface add mon0 type monitor 2>/dev/null || \
  airmon-ng start "$WLAN" 2>/dev/null || true
ip link set mon0 up 2>/dev/null || true
ip link set "$WLAN" up 2>/dev/null || true
EOF
sudo chmod +x /usr/local/bin/telcosec-mon-setup

# Systemd service to start mon0 at boot
cat << 'EOF' | sudo tee /etc/systemd/system/telcosec-mon.service
[Unit]
Description=TelcoSec Monitoring Interface (mon0)
After=network.target
Wants=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/telcosec-mon-setup
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable telcosec-mon.service 2>/dev/null || true

# Wireshark default capture interface → mon0
sudo mkdir -p /etc/skel/.config/wireshark
cat << 'EOF' | sudo tee /etc/skel/.config/wireshark/preferences
# TelcoSec default: capture on monitoring interface
capture.default_interface: mon0
capture.prom_mode: TRUE
gui.expert_composite_eyecandy: TRUE
EOF
if [ -d /home/telcosec ]; then
  sudo mkdir -p /home/telcosec/.config/wireshark
  sudo cp /etc/skel/.config/wireshark/preferences /home/telcosec/.config/wireshark/preferences
  sudo chown -R telcosec:telcosec /home/telcosec/.config/wireshark
fi

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

# Set GNOME Terminal as default terminal
grep -q '^TERMINAL=' /etc/environment 2>/dev/null && \
  sudo sed -i 's/^TERMINAL=.*/TERMINAL=gnome-terminal/' /etc/environment || \
  echo 'TERMINAL=gnome-terminal' | sudo tee -a /etc/environment

sudo update-alternatives --set x-terminal-emulator /usr/bin/gnome-terminal 2>/dev/null || true

# XDG default terminal via mimeapps
sudo mkdir -p /etc/skel/.config
cat << 'EOF' | sudo tee /etc/skel/.config/mimeapps.list
[Default Applications]
x-scheme-handler/terminal=org.gnome.Terminal.desktop
EOF
if [ -d /home/telcosec ]; then
  sudo cp /etc/skel/.config/mimeapps.list /home/telcosec/.config/mimeapps.list
  sudo chown telcosec:telcosec /home/telcosec/.config/mimeapps.list
fi

# 7. GNOME Security & Privacy Hardening
echo "Applying GNOME security hardening..."
sudo mkdir -p /etc/dconf/db/local.d

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

# ── Media handling: no auto-mount ─────────────────────────────────────────────
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

# Disable Ubuntu crash reporter — no data should leave the research environment
sudo systemctl disable apport 2>/dev/null || true
sudo systemctl mask apport 2>/dev/null || true
sudo rm -f /etc/apport/crashdb.conf 2>/dev/null || true

# 8. TelcoSec Design — Yaru-teal-dark + Papirus-Dark + GNOME Shell extensions
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

# ── GNOME Shell extensions to enable ─────────────────────────────────────────
# apps-menu: traditional "Applications" dropdown in top bar reading
#   /etc/xdg/menus/gnome-applications.menu — telecom categories appear here.
# places-status-indicator: quick "Places" dropdown for bookmarks and mounts.
# window-list: classic taskbar at bottom showing open windows.
# appindicatorsupport: system tray icons (Wireshark, nm-applet, etc.).
[org/gnome/shell]
disable-user-extensions=false
enabled-extensions=['apps-menu@gnome-shell-extensions.gcampax.github.com', 'places-status-indicator@gnome-shell-extensions.gcampax.github.com', 'window-list@gnome-shell-extensions.gcampax.github.com', 'ubuntu-appindicators@ubuntu.com']
favorite-apps=['org.gnome.Terminal.desktop', 'firefox.desktop', 'org.wireshark.Wireshark.desktop', 'org.gnome.Nautilus.desktop', 'gnuradio-companion.desktop', 'gqrx.desktop', 'open5gs-start.desktop', 'wireshark-mon.desktop']

# ── Window list (bottom taskbar) behavior ─────────────────────────────────────
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
EOF

# Nautilus bookmarks — quick access to TelcoSec research paths
sudo mkdir -p /etc/skel/.config/gtk-3.0
cat << 'EOF' | sudo tee /etc/skel/.config/gtk-3.0/bookmarks
file:///usr/share/wordlists/telecom Telecom Wordlists
file:///opt/telcosec TelcoSec Tools
file:///usr/share/doc/telcosec TelcoSec Docs
EOF
if [ -d /home/telcosec ]; then
    sudo mkdir -p /home/telcosec/.config/gtk-3.0
    sudo cp /etc/skel/.config/gtk-3.0/bookmarks /home/telcosec/.config/gtk-3.0/bookmarks
    sudo chown -R telcosec:telcosec /home/telcosec/.config/gtk-3.0
fi

# 5. GDM3 Login Screen Branding
echo "Branding GDM3 login screen..."
sudo mkdir -p /etc/dconf/db/gdm.d/locks
sudo mkdir -p /etc/dconf/profile

# GDM dconf profile tells the login screen which databases to load
cat << 'EOF' | sudo tee /etc/dconf/profile/gdm
user-db:user
system-db:gdm
EOF

# Login screen settings: TelcoSec wallpaper, dark theme, security banner, no user list
cat << 'EOF' | sudo tee /etc/dconf/db/gdm.d/00-telcosec-login
[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/telcosec/wallpaper.jpg'
picture-uri-dark='file:///usr/share/backgrounds/telcosec/wallpaper.jpg'
picture-options='scaled'
color-shading-type='solid'
primary-color='#0A0E18'

[org/gnome/desktop/screensaver]
picture-uri='file:///usr/share/backgrounds/telcosec/wallpaper.jpg'
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

# Lock GDM background so extensions cannot override it
cat << 'EOF' | sudo tee /etc/dconf/db/gdm.d/locks/00-telcosec
/org/gnome/desktop/background/picture-uri
/org/gnome/desktop/background/picture-options
/org/gnome/login-screen/disable-user-list
/org/gnome/login-screen/banner-message-enable
/org/gnome/login-screen/banner-message-text
EOF

# Compile dconf database (must run after all local.d/ keyfiles are written)
sudo dconf update

# Autostart GNOME Terminal with tmux general session on desktop login
sudo mkdir -p /etc/xdg/autostart
cat << 'EOF' | sudo tee /etc/xdg/autostart/telcosec-terminal.desktop
[Desktop Entry]
Type=Application
Name=TelcoSec Terminal
Comment=Open GNOME Terminal with tmux general session on login
Exec=gnome-terminal --title "TelcoSec Terminal" -- bash -c "tmux new-session -A -s general; exec bash"
Icon=org.gnome.Terminal
Terminal=false
Categories=System;TerminalEmulator;
X-GNOME-Autostart-enabled=true
EOF

# Cleanup deferred to build-iso.sh central cleanup phase

