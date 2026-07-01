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

# NOTE: /etc/casper.conf is NOT written here. build-iso.sh writes it once,
# after all provisioning scripts run, as the single source of truth (it used
# to be written in both places, with build-iso.sh's copy silently winning
# since it runs last — that duplicate authority has been removed).

# 2. XFCE defaults (Themes, Fonts, Wallpaper, Keybindings)
# Theme is Yaru-bark-dark — the previous "Yaru-teal-dark" does not exist in
# Ubuntu 24.04's yaru-theme-gtk package at all (verified against the real
# noble package file listing: only bark/blue/magenta/olive/prussiangreen/
# purple/red/sage/viridian variants ship, each with a -dark suffix — no
# "teal"). GTK/xfwm4/lightdm-gtk-greeter would have silently fallen back to
# plain Yaru/Adwaita instead of the intended branded look. Yaru doesn't ship
# an amber/orange variant; "bark" (warm brown/tan) is the closest available
# match to the brand's amber accent (#e8921e), completing the harmonization
# already done for Calamares/tmux/docs.
echo "Writing XFCE default configurations..."
sudo mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Yaru-bark-dark"/>
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
    <property name="theme" type="string" value="Yaru-bark-dark"/>
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

# Panel, keyboard shortcuts, and notification daemon configs are per-user
# xfconf state, not system-wide defaults like the ones above — XFCE reads
# these from ~/.config/xfce4/xfce4-panel.xml etc, not /etc/xdg/xfce4/. Deploy
# via /etc/skel/ (new users, and Calamares-installed users via users.conf's
# skel copy) and directly into the live session's home, matching the pattern
# already used below for .tmux.conf and mimeapps.list.
sudo mkdir -p /etc/skel/.config/xfce4/xfce4-perchannel-xml

# Single top panel: Whisker Menu (searches the categorized tool menu built in
# builder/menu/) on the left, window list filling the middle, workspace
# switcher + system tray + clock on the right. No second panel, no desktop
# icons — kept to one deliberate row so the 76-tool catalog is one click away
# without adding visual clutter.
cat << 'EOF' | sudo tee /etc/skel/.config/xfce4/xfce4-perchannel-xml/xfce4-panel.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-panel" version="1.0">
  <property name="configver" type="int" value="2"/>
  <property name="panels" type="array">
    <value type="int" value="1"/>
    <property name="panel-1" type="empty">
      <property name="position" type="string" value="p=6;x=0;y=0"/>
      <property name="length" type="uint" value="100"/>
      <property name="length-adjust" type="bool" value="true"/>
      <property name="position-locked" type="bool" value="true"/>
      <property name="size" type="uint" value="30"/>
      <property name="plugin-ids" type="array">
        <value type="int" value="1"/>
        <value type="int" value="2"/>
        <value type="int" value="3"/>
        <value type="int" value="4"/>
        <value type="int" value="5"/>
      </property>
    </property>
  </property>
  <property name="plugins" type="empty">
    <property name="plugin-1" type="string" value="whiskermenu">
      <property name="button-title" type="string" value="TelcoSec"/>
      <property name="button-icon" type="string" value="utilities-terminal"/>
      <property name="show-button-title" type="bool" value="true"/>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="expand" type="bool" value="true"/>
      <property name="grouping" type="uint" value="1"/>
    </property>
    <property name="plugin-3" type="string" value="pager">
      <property name="rows" type="uint" value="1"/>
    </property>
    <property name="plugin-4" type="string" value="systray"/>
    <property name="plugin-5" type="string" value="clock">
      <property name="digital-layout" type="uint" value="2"/>
      <property name="digital-time-format" type="string" value="%H:%M"/>
      <property name="digital-date-format" type="string" value="%d %b"/>
    </property>
  </property>
</channel>
EOF

# Keyboard shortcuts: only additions beyond XFCE's own stock defaults (which
# already cover Alt+Tab, Ctrl+Alt+Left/Right workspace switching, etc.) —
# Super key for one-key Whisker Menu access, and Super+Arrow for basic
# window tiling, neither of which XFCE binds out of the box.
cat << 'EOF' | sudo tee /etc/skel/.config/xfce4/xfce4-perchannel-xml/xfce4-keyboard-shortcuts.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-keyboard-shortcuts" version="1.0">
  <property name="commands" type="empty">
    <property name="custom" type="empty">
      <property name="Super_L" type="string" value="xfce4-popup-whiskermenu"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="xfce4-terminal"/>
    </property>
  </property>
  <property name="xfwm4" type="empty">
    <property name="custom" type="empty">
      <property name="&lt;Primary&gt;&lt;Alt&gt;Left" type="string" value="left_workspace_key"/>
      <property name="&lt;Primary&gt;&lt;Alt&gt;Right" type="string" value="right_workspace_key"/>
      <property name="&lt;Super&gt;Left" type="string" value="tile_left_key"/>
      <property name="&lt;Super&gt;Right" type="string" value="tile_right_key"/>
      <property name="&lt;Super&gt;Up" type="string" value="tile_up_key"/>
      <property name="&lt;Super&gt;Down" type="string" value="tile_down_key"/>
    </property>
  </property>
</channel>
EOF

# Notification daemon: quiet defaults for a research workstation — short
# display time, top-right position (below the panel), no persistent history
# clutter.
cat << 'EOF' | sudo tee /etc/skel/.config/xfce4/xfce4-perchannel-xml/xfce4-notifyd.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-notifyd" version="1.0">
  <property name="theme" type="string" value="Default"/>
  <property name="notify-location" type="int" value="2"/>
  <property name="expire-timeout" type="int" value="4"/>
  <property name="do-fadeout" type="bool" value="true"/>
  <property name="do-slideout" type="bool" value="true"/>
  <property name="log-level" type="int" value="0"/>
</channel>
EOF

if [ -d /home/telcosec ]; then
  sudo mkdir -p /home/telcosec/.config/xfce4/xfce4-perchannel-xml
  sudo cp /etc/skel/.config/xfce4/xfce4-perchannel-xml/xfce4-panel.xml \
          /etc/skel/.config/xfce4/xfce4-perchannel-xml/xfce4-keyboard-shortcuts.xml \
          /etc/skel/.config/xfce4/xfce4-perchannel-xml/xfce4-notifyd.xml \
          /home/telcosec/.config/xfce4/xfce4-perchannel-xml/
  sudo chown -R telcosec:telcosec /home/telcosec/.config/xfce4
fi

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
# Status bar accent uses the brand's amber phosphor color (#e8921e, matching
# docs/assets/main.css --amber) rather than the previous cyan/teal (#00FFD5),
# to stay consistent with the rest of the TelcoSec visual identity.
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
set -g status-left '#[bg=#e8921e,fg=#0D1117,bold] ⚡ #S #[bg=default,fg=default] '
set -g status-right '#[fg=#e8921e,bold] @#h #[fg=#ABB2BF] %Y-%m-%d %H:%M '
set -g status-justify left
setw -g window-status-current-style bg='#e8921e',fg='#0D1117',bold
setw -g window-status-current-format ' #I:#W '
setw -g window-status-style bg=default,fg='#8B949E'
setw -g window-status-format ' #I:#W '
set -g pane-border-style fg='#30363D'
set -g pane-active-border-style fg='#e8921e'
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
theme-name=Yaru-bark-dark
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
