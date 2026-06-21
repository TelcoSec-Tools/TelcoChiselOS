#!/bin/bash
set -e

echo "=== Customizing Desktop Environment (XFCE) ==="

# 1. LightDM Autologin + Wallpaper Directory
echo "Configuring LightDM autologin..."
sudo mkdir -p /usr/share/backgrounds/telcosec
sudo mkdir -p /etc/lightdm/lightdm.conf.d

cat << 'EOF' | sudo tee /etc/lightdm/lightdm.conf.d/50-telcosec-autologin.conf
[Seat:*]
autologin-user=telcosec
autologin-user-timeout=0
user-session=xfce
EOF

# Tell casper which user is the live session user.
cat << 'EOF' | sudo tee /etc/casper.conf
export USERNAME=telcosec
export USERFULLNAME="TelcoSec Researcher"
export HOST=TelcoChisel
export BUILD_SYSTEM=Ubuntu
export FLAVOUR=ubuntu
EOF

# 2. XFCE defaults (Themes, Fonts, Wallpaper, Keybindings)
echo "Writing XFCE default configurations..."
sudo mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Yaru-teal-dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Ubuntu 10"/>
    <property name="MonospaceFontName" type="string" value="IBM Plex Mono 11"/>
  </property>
</channel>
EOF

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-desktop.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-desktop" version="1.0">
  <property name="backdrop" type="empty">
    <property name="screen0" type="empty">
      <property name="monitor0" type="empty">
        <property name="workspace0" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/telcosec/wallpaper.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
</channel>
EOF

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="theme" type="string" value="Yaru-teal-dark"/>
    <property name="button_layout" type="string" value="O|HMC"/>
    <property name="workspace_count" type="int" value="4"/>
  </property>
</channel>
EOF

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-power-manager" version="1.0">
  <property name="xfce4-power-manager" type="empty">
    <property name="power-button-action" type="uint" value="3"/>
    <property name="dpms-enabled" type="bool" value="false"/>
    <property name="blank-on-ac" type="int" value="0"/>
    <property name="blank-on-battery" type="int" value="0"/>
    <property name="dpms-on-ac-sleep" type="uint" value="0"/>
    <property name="dpms-on-ac-off" type="uint" value="0"/>
    <property name="dpms-on-battery-sleep" type="uint" value="0"/>
    <property name="dpms-on-battery-off" type="uint" value="0"/>
  </property>
</channel>
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

if ! grep -q "telcosec_prompt" /etc/bash.bashrc 2>/dev/null; then
  cat >> /etc/bash.bashrc << 'BASHRC'
# TelcoSec custom prompt (also loaded by /etc/profile.d/ for login shells)
if [ -f /etc/profile.d/telcosec_prompt.sh ]; then
    . /etc/profile.d/telcosec_prompt.sh
fi

# Enable fzf shell integration (Ctrl+r, Alt+c, etc.) if installed
if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
    . /usr/share/doc/fzf/examples/key-bindings.bash
fi
if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
    . /usr/share/doc/fzf/examples/completion.bash
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
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "CaptivePortal": false,
    "DNSOverHTTPS": {"Enabled": false},
    "OfferToSaveLogins": false,
    "PasswordManagerEnabled": false,
    "SearchSuggestEnabled": false,
    "OverrideFirstRunPage": "",
    "OverridePostUpdatePage": "",
    "Homepage": {
      "URL": "file:///usr/share/doc/telcosec/index.html",
      "Locked": false,
      "StartPage": "homepage"
    }
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

cat << 'EOF' | sudo tee /usr/local/bin/telcosec-mon-setup
#!/bin/bash
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

sudo mkdir -p /etc/skel/.config/wireshark
cat << 'EOF' | sudo tee /etc/skel/.config/wireshark/preferences
capture.default_interface: mon0
capture.prom_mode: TRUE
gui.expert_composite_eyecandy: TRUE
EOF
if [ -d /home/telcosec ]; then
  sudo mkdir -p /home/telcosec/.config/wireshark
  sudo cp /etc/skel/.config/wireshark/preferences /home/telcosec/.config/wireshark/preferences
  sudo chown -R telcosec:telcosec /home/telcosec/.config/wireshark
fi

# 6. xfce4-terminal configuration
echo "Configuring XFCE Terminal..."
sudo mkdir -p /etc/xdg/xfce4/terminal
cat << 'EOF' | sudo tee /etc/xdg/xfce4/terminal/terminalrc
[Configuration]
FontName=IBM Plex Mono 11
MiscAlwaysShowTabs=FALSE
MiscBell=FALSE
MiscBordersDefault=TRUE
MiscCursorBlinks=FALSE
MiscCursorShape=TERMINAL_CURSOR_SHAPE_BLOCK
MiscDefaultGeometry=80x24
MiscInheritGeometry=FALSE
MiscMenubarDefault=FALSE
MiscMouseAutohide=FALSE
MiscToolbarDefault=FALSE
MiscConfirmClose=TRUE
MiscCycleTabs=TRUE
MiscTabCloseButtons=TRUE
MiscTabCloseMiddleClick=TRUE
MiscTabPosition=GTK_POS_TOP
MiscHighlightUrls=TRUE
MiscMiddleClickOpensUri=FALSE
MiscCopyOnSelect=FALSE
MiscShowUnsafePasteDialog=TRUE
MiscSearchDialogOpacity=100
MiscShowRelaunchDialog=TRUE
MiscRewrapOnResize=TRUE
MiscUseShiftArrowsToScroll=FALSE
ColorForeground=#C9D1D9
ColorBackground=#0D1117
ColorCursor=#C9D1D9
TabActivityColor=#aa0000
ColorPalette=#0D1117;#FF6B6B;#98C379;#E5C07B;#61AFEF;#C678DD;#56B6C2;#ABB2BF;#5C6370;#FF7B7B;#A8D389;#F5D08B;#71BFFF;#D688E7;#66C6D2;#FFFFFF
EOF

grep -q '^TERMINAL=' /etc/environment 2>/dev/null && \
  sudo sed -i 's/^TERMINAL=.*/TERMINAL=xfce4-terminal/' /etc/environment || \
  echo 'TERMINAL=xfce4-terminal' | sudo tee -a /etc/environment

sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal 2>/dev/null || true

sudo mkdir -p /etc/skel/.config
cat << 'EOF' | sudo tee /etc/skel/.config/mimeapps.list
[Default Applications]
x-scheme-handler/terminal=xfce4-terminal.desktop
EOF
if [ -d /home/telcosec ]; then
  sudo cp /etc/skel/.config/mimeapps.list /home/telcosec/.config/mimeapps.list
  sudo chown telcosec:telcosec /home/telcosec/.config/mimeapps.list
fi

# Thunar bookmarks
sudo mkdir -p /etc/skel/.config/gtk-3.0
cat << 'EOF' | sudo tee /etc/skel/.config/gtk-3.0/bookmarks
file:///usr/share/wordlists/telecom Telecom Wordlists
file:///opt/telcosec TelcoSec Tools
file:///usr/share/doc/telcosec TelcoSec Docs
EOF

# Disable Ubuntu crash reporter
sudo systemctl disable apport 2>/dev/null || true
sudo systemctl mask apport 2>/dev/null || true
sudo rm -f /etc/apport/crashdb.conf 2>/dev/null || true

# 7. tmux configuration
echo "Configuring tmux status and defaults..."
cat << 'EOF' | sudo tee /etc/skel/.tmux.conf
set -g default-terminal "screen-256color"
set-option -sa terminal-overrides ",xterm-256color:RGB"
set -g mouse on
set -g history-limit 50000
set -g prefix C-b
set -g prefix2 C-a
bind C-a send-prefix
set -g base-index 1
setw -g pane-base-index 1
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
set -g status-style bg='#0D1117',fg='#C9D1D9'
set -g status-left-length 20
set -g status-left '#[bg=#00FFD5,fg=#0D1117,bold] ⚡ #S #[bg=default,fg=default] '
set -g status-right '#[fg=#00FFD5,bold] @#h #[fg=#ABB2BF] %Y-%m-%d %H:%M '
set -g status-justify left
setw -g window-status-current-style bg='#00FFD5',fg='#0D1117',bold
setw -g window-status-current-format ' #I:#W '
setw -g window-status-style bg=default,fg='#8B949E'
setw -g window-status-format ' #I:#W '
set -g pane-border-style fg='#30363D'
set -g pane-active-border-style fg='#00FFD5'
set -g bell-action none
set -g visual-bell off
EOF

if [ -d /home/telcosec ]; then
    sudo cp /etc/skel/.tmux.conf /home/telcosec/.tmux.conf
    sudo chown telcosec:telcosec /home/telcosec/.tmux.conf
fi

# 8. LightDM GTK Greeter configuration
echo "Branding LightDM login screen..."
sudo mkdir -p /etc/lightdm
cat << 'EOF' | sudo tee /etc/lightdm/lightdm-gtk-greeter.conf
[greeter]
background=/usr/share/backgrounds/telcosec/wallpaper.jpg
theme-name=Yaru-teal-dark
icon-theme-name=Papirus-Dark
font-name=Ubuntu 11
xft-antialias=true
xft-dpi=96
xft-hintstyle=hintslight
xft-rgba=rgb
indicators=~host;~spacer;~clock;~spacer;~session;~language;~power
clock-format=%d %b, %H:%M
hide-user-image=true
EOF

# 9. Autostart Terminal
sudo mkdir -p /etc/xdg/autostart
cat << 'EOF' | sudo tee /etc/xdg/autostart/telcosec-terminal.desktop
[Desktop Entry]
Type=Application
Name=TelcoSec Terminal
Comment=Open XFCE Terminal with tmux general session on login
Exec=xfce4-terminal --title "TelcoSec Terminal" -e "bash -c 'tmux new-session -A -s general; exec bash'"
Icon=utilities-terminal
Terminal=false
Categories=System;TerminalEmulator;
X-GNOME-Autostart-enabled=true
EOF

# Fix permissions on skel and home
if [ -d /home/telcosec ]; then
    sudo chown -R telcosec:telcosec /home/telcosec/.config || true
fi
