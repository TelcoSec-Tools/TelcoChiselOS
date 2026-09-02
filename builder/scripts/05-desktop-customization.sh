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
sudo mkdir -p /etc/xdg/xfce4/xfconf/xfce-perchannel-xml /etc/skel/.config/xfce4/xfce4-perchannel-xml /etc/skel/.config/gtk-3.0

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xsettings" version="1.0">
  <property name="Net" type="empty">
    <property name="ThemeName" type="string" value="Yaru-bark-dark"/>
    <property name="IconThemeName" type="string" value="Papirus-Dark"/>
    <property name="EnableAnimations" type="bool" value="true"/>
  </property>
  <property name="Gtk" type="empty">
    <property name="FontName" type="string" value="Ubuntu 10"/>
    <property name="MonospaceFontName" type="string" value="IBM Plex Mono 11"/>
    <property name="MenuPopupDelay" type="int" value="0"/>
    <property name="ToolbarStyle" type="string" value="icons"/>
    <property name="ButtonImages" type="bool" value="true"/>
    <property name="MenuImages" type="bool" value="true"/>
  </property>
</channel>
EOF

cat << 'EOF' | sudo tee /etc/skel/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name = Yaru-bark-dark
gtk-icon-theme-name = Papirus-Dark
gtk-font-name = Ubuntu 10
gtk-monospace-font-name = IBM Plex Mono 11
gtk-menu-popup-delay = 0
gtk-enable-animations = 1
gtk-application-prefer-dark-theme = 1
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
        <property name="workspace1" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/telcosec/wallpaper.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
        <property name="workspace2" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/telcosec/wallpaper.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
        <property name="workspace3" type="empty">
          <property name="last-image" type="string" value="/usr/share/backgrounds/telcosec/wallpaper.jpg"/>
          <property name="image-style" type="int" value="5"/>
        </property>
      </property>
    </property>
  </property>
  <property name="desktop-icons" type="empty">
    <property name="style" type="int" value="2"/>
    <property name="file-icons" type="empty">
      <property name="show-filesystem" type="bool" value="false"/>
      <property name="show-home" type="bool" value="false"/>
      <property name="show-trash" type="bool" value="false"/>
      <property name="show-removable" type="bool" value="false"/>
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
    <property name="use_compositing" type="bool" value="true"/>
    <property name="unredirect_overlays" type="bool" value="true"/>
    <property name="cycle_preview" type="bool" value="true"/>
    <property name="cycle_tabwin_mode" type="int" value="1"/>
    <property name="zoom_desktop" type="bool" value="false"/>
    <property name="vblank_mode" type="string" value="auto"/>
    <property name="show_dock_shadow" type="bool" value="false"/>
    <property name="show_popup_shadow" type="bool" value="false"/>
    <property name="frame_opacity" type="int" value="100"/>
    <property name="inactive_opacity" type="int" value="100"/>
    <property name="snap_to_border" type="bool" value="true"/>
    <property name="snap_to_windows" type="bool" value="true"/>
    <property name="tile_on_move" type="bool" value="true"/>
    <property name="box_move" type="bool" value="false"/>
    <property name="box_resize" type="bool" value="false"/>
  </property>
</channel>
EOF

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="SaveOnExit" type="bool" value="false"/>
    <property name="PromptOnLogout" type="bool" value="true"/>
  </property>
  <property name="compat" type="empty">
    <property name="LaunchGNOME" type="bool" value="false"/>
    <property name="LaunchKDE" type="bool" value="false"/>
  </property>
  <property name="shutdown" type="empty">
    <property name="ShowHibernate" type="bool" value="false"/>
    <property name="ShowSuspend" type="bool" value="false"/>
  </property>
</channel>
EOF

cat << 'EOF' | sudo tee /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/thunar.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="thunar" version="1.0">
  <property name="last-view" type="string" value="ThunarDetailsView"/>
  <property name="misc-single-click" type="bool" value="false"/>
  <property name="misc-show-hidden" type="bool" value="false"/>
  <property name="misc-parallel-copy-mode" type="string" value="THUNAR_PARALLEL_COPY_MODE_NEVER"/>
  <property name="misc-date-style" type="string" value="THUNAR_DATE_STYLE_SHORT"/>
  <property name="misc-thumbnail-mode" type="string" value="THUNAR_THUMBNAIL_MODE_ONLY_LOCAL"/>
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

# Single top panel: Whisker Menu on the left, Terminator quick launcher next to it,
# window list with middle-click close filling the middle, workspace switcher + tray + clock on the right.
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
        <value type="int" value="6"/>
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
    <property name="plugin-6" type="string" value="launcher">
      <property name="items" type="array">
        <value type="string" value="net.tenshu.Terminator.desktop"/>
      </property>
    </property>
    <property name="plugin-2" type="string" value="tasklist">
      <property name="expand" type="bool" value="true"/>
      <property name="grouping" type="uint" value="1"/>
      <property name="middle-click" type="uint" value="3"/>
      <property name="flat-buttons" type="bool" value="true"/>
      <property name="show-labels" type="bool" value="true"/>
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
      <property name="&lt;Primary&gt;&lt;Alt&gt;t" type="string" value="terminator"/>
      <property name="&lt;Super&gt;e" type="string" value="thunar"/>
      <property name="&lt;Super&gt;l" type="string" value="xflock4"/>
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

# Pre-configure Whisker Menu favorites, layout dimensions, and panel properties
sudo mkdir -p /etc/skel/.config/xfce4/panel/launcher-6
cat << 'EOF' | sudo tee /etc/skel/.config/xfce4/panel/whiskermenu-1.rc
favorites=net.tenshu.Terminator.desktop,wireshark-mon.desktop,gqrx.desktop,pysim-shell.desktop,sigploit.desktop,firmwire.desktop,diafuzzer.desktop,ueransim-gnb.desktop,5ghoul-fuzzer.desktop,telcosec-docs.desktop
button-title=TelcoSec
button-icon=utilities-terminal
show-button-title=true
show-button-icon=true
category-icon-size=1
item-icon-size=2
menu-width=520
menu-height=600
menu-opacity=95
position-search-alternate=true
stay-on-focus-out=false
EOF

# Deploy Terminator launcher for top panel plugin-6
cat << 'EOF' | sudo tee /etc/skel/.config/xfce4/panel/launcher-6/net.tenshu.Terminator.desktop
[Desktop Entry]
Name=Terminator
Comment=Multiple terminals in one window
TryExec=terminator
Exec=terminator
Icon=terminator
Type=Application
Categories=GNOME;GTK;Utility;TerminalEmulator;System;
StartupNotify=true
X-Ubuntu-Gettext-Domain=terminator
EOF
sudo cp /etc/skel/.config/xfce4/panel/launcher-6/net.tenshu.Terminator.desktop /etc/skel/.config/xfce4/panel/launcher-6/1.desktop

# Deploy Terminator shortcut to Desktop
echo "Deploying Terminator desktop shortcut..."
sudo mkdir -p /etc/skel/Desktop
sudo cp /etc/skel/.config/xfce4/panel/launcher-6/net.tenshu.Terminator.desktop /etc/skel/Desktop/terminator.desktop
sudo chmod +x /etc/skel/Desktop/terminator.desktop

# Pre-configure Terminator Developer Palette & Behavior
sudo mkdir -p /etc/skel/.config/terminator
cat << 'EOF' | sudo tee /etc/skel/.config/terminator/config
[global_config]
  title_transmit_fg_color = "#e8921e"
  title_transmit_bg_color = "#181a1b"
  title_receive_fg_color = "#ffffff"
  title_receive_bg_color = "#222222"
  title_inactive_fg_color = "#888888"
  title_inactive_bg_color = "#181a1b"
  suppress_multiple_term_dialog = True
  copy_on_selection = True
[keybindings]
  split_horiz = <Primary><Shift>e
  split_vert = <Primary><Shift>o
[profiles]
  [[default]]
    background_color = "#121417"
    foreground_color = "#e0e6ed"
    cursor_color = "#e8921e"
    font = IBM Plex Mono 11
    use_system_font = False
    scrollback_infinite = True
    palette = "#0d1117:#ff5555:#50fa7b:#e8921e:#58a6ff:#ff79c6:#00ffd5:#e0e6ed:#484f58:#ff6e6e:#69ff94:#f5aa35:#79c0ff:#ff92df:#56f4e6:#ffffff"
    show_titlebar = False
[layouts]
  [[default]]
    [[[window0]]]
      type = Window
      parent = ""
      size = 900, 600
    [[[child1]]]
      type = Terminal
      parent = window0
      profile = default
[plugins]
EOF

# Optimize Tumbler Thumbnailer (Prevent USB I/O lockups on large dumps and captures)
sudo mkdir -p /etc/xdg/tumbler
cat << 'EOF' | sudo tee /etc/xdg/tumbler/tumbler.rc
[JPEGThumbnailer]
Disabled=false
Priority=1
Locations=
MaxFileSize=52428800

[PDFThumbnailer]
Disabled=false
Priority=1
Locations=
MaxFileSize=52428800
EOF

if [ -d /home/telcosec ]; then
  sudo mkdir -p /home/telcosec/.config/xfce4/xfce4-perchannel-xml \
                /home/telcosec/.config/xfce4/panel/launcher-6 \
                /home/telcosec/.config/gtk-3.0 \
                /home/telcosec/.config/terminator \
                /home/telcosec/Desktop
  sudo cp /etc/skel/.config/xfce4/xfce4-perchannel-xml/*.xml \
          /home/telcosec/.config/xfce4/xfce4-perchannel-xml/ 2>/dev/null || true
  sudo cp /etc/skel/.config/xfce4/panel/whiskermenu-1.rc \
          /home/telcosec/.config/xfce4/panel/
  sudo cp /etc/skel/.config/xfce4/panel/launcher-6/* \
          /home/telcosec/.config/xfce4/panel/launcher-6/
  sudo cp /etc/skel/.config/gtk-3.0/settings.ini \
          /home/telcosec/.config/gtk-3.0/settings.ini 2>/dev/null || true
  sudo cp /etc/skel/.config/terminator/config \
          /home/telcosec/.config/terminator/config 2>/dev/null || true
  sudo cp /etc/skel/Desktop/terminator.desktop \
          /home/telcosec/Desktop/
  sudo chmod +x /home/telcosec/Desktop/*.desktop || true
  sudo chown -R telcosec:telcosec /home/telcosec/.config /home/telcosec/Desktop
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

# Note: Wireshark preferences (capture.default_interface=mon0, prom_mode, etc.)
# are written later by 08-system-optimization.sh from the canonical
# builder/wireshark/preferences file — not duplicated here.

grep -q '^TERMINAL=' /etc/environment 2>/dev/null && \
  sudo sed -i 's/^TERMINAL=.*/TERMINAL=terminator/' /etc/environment || \
  echo 'TERMINAL=terminator' | sudo tee -a /etc/environment

sudo update-alternatives --set x-terminal-emulator /usr/bin/terminator 2>/dev/null || true

sudo mkdir -p /etc/skel/.config
cat << 'EOF' | sudo tee /etc/skel/.config/mimeapps.list
[Default Applications]
x-scheme-handler/terminal=net.tenshu.Terminator.desktop
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

# 10. i3 Tiling Window Manager Configuration (Operational Mode)
echo "Configuring i3 Tiling Window Manager for Telecom Operations..."
sudo mkdir -p /etc/skel/.config/i3 /etc/skel/.config/i3status

cat << 'EOF' | sudo tee /etc/skel/.config/i3/config
# TelcoChisel i3 Configuration — Telecom Operational Mode
set $mod Mod4

font pango:Ubuntu, IBM Plex Mono 10

# Amber Phosphor Color Theme
client.focused          #e8921e #181a1b #ffffff #e8921e #e8921e
client.focused_inactive #333333 #181a1b #aaaaaa #181a1b #181a1b
client.unfocused        #222222 #181a1b #888888 #181a1b #181a1b
client.urgent           #ff5555 #ff5555 #ffffff #ff5555 #ff5555

# Windows & Floating Rules
floating_modifier $mod
default_border pixel 2
default_floating_border pixel 2
for_window [window_role="pop-up"] floating enable
for_window [class="Gqrx"] floating enable resize set 1024 700
for_window [class="Wireshark"] floating enable resize set 1280 800

# Operational Workspaces
set $ws1 "1: 📡 SDR & Spectrum"
set $ws2 "2: 📶 RAN & 5G Core"
set $ws3 "3: 💳 SIM & Baseband"
set $ws4 "4: ⚡ Core Signaling"
set $ws5 "5: 🔍 Network Analysis"
set $ws6 "6: 🌐 Dashboard & Portal"

# Switch Workspaces
bindsym $mod+1 workspace $ws1
bindsym $mod+2 workspace $ws2
bindsym $mod+3 workspace $ws3
bindsym $mod+4 workspace $ws4
bindsym $mod+5 workspace $ws5
bindsym $mod+6 workspace $ws6

# Move Containers to Workspaces
bindsym $mod+Shift+1 move container to workspace $ws1
bindsym $mod+Shift+2 move container to workspace $ws2
bindsym $mod+Shift+3 move container to workspace $ws3
bindsym $mod+Shift+4 move container to workspace $ws4
bindsym $mod+Shift+5 move container to workspace $ws5
bindsym $mod+Shift+6 move container to workspace $ws6

# Core Navigation & Window Controls
bindsym $mod+Return exec terminator
bindsym $mod+d exec rofi -show drun -font "Ubuntu 11"
bindsym $mod+Shift+q kill
bindsym $mod+Shift+c reload
bindsym $mod+Shift+r restart
bindsym $mod+Shift+e exec xfce4-session-logout

# Window Focus (Vim keys & Arrows)
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right
bindsym $mod+Left focus left
bindsym $mod+Down focus down
bindsym $mod+Up focus up
bindsym $mod+Right focus right

# Move Focused Window
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Layout Controls
bindsym $mod+b split h
bindsym $mod+v split v
bindsym $mod+f fullscreen toggle
bindsym $mod+s layout stacking
bindsym $mod+w layout tabbed
bindsym $mod+e layout toggle split
bindsym $mod+Shift+space floating toggle
bindsym $mod+space focus mode_toggle

# Direct Tool Launch Shortcuts (Operational Mode)
bindsym $mod+Shift+w exec wireshark-mon
bindsym $mod+Shift+g exec gqrx
bindsym $mod+Shift+s exec pysim-shell
bindsym $mod+Shift+p exec sigploit
bindsym $mod+Shift+b exec firefox

# Operational Status Bar
bar {
    position top
    status_command i3status
    colors {
        background #181a1b
        statusline #e8921e
        separator  #e8921e
        focused_workspace  #e8921e #e8921e #181a1b
        active_workspace   #333333 #333333 #ffffff
        inactive_workspace #181a1b #181a1b #888888
        urgent_workspace   #ff5555 #ff5555 #ffffff
    }
}

# Autostart Programs
exec --no-startup-id feh --bg-fill /usr/share/backgrounds/telcosec/wallpaper.jpg
exec --no-startup-id picom -b --config /dev/null
exec --no-startup-id terminator -e "bash -c 'tmux new-session -A -s op-center; exec bash'"
EOF

cat << 'EOF' | sudo tee /etc/skel/.config/i3status/config
general {
    colors = true
    color_good = "#e8921e"
    color_degraded = "#f5aa35"
    color_bad = "#ff5555"
    interval = 2
}

order += "ethernet _first_"
order += "wireless _first_"
order += "tun0"
order += "load"
order += "memory"
order += "tztime local"

ethernet _first_ {
    format_up = "ETH: %ip (%speed)"
    format_down = "ETH: down"
}

wireless _first_ {
    format_up = "WLAN: %ip (%essid)"
    format_down = "WLAN: down"
}

tun0 {
    format_up = "VPN: %ip"
    format_down = "VPN: down"
}

load {
    format = "CPU: %1min"
}

memory {
    format = "RAM: %used / %total"
    threshold_degraded = "10%"
    format_degraded = "RAM LOW: %free"
}

tztime local {
    format = "📅 %Y-%m-%d  ⏰ %H:%M:%S"
}
EOF

# Deploy LightDM Session Selector Hook
cat << 'EOF' | sudo tee /usr/local/bin/telcosec-session-select > /dev/null
#!/bin/bash
# Selects desktop session based on kernel cmdline 'desktop=i3'
if grep -q "desktop=i3" /proc/cmdline 2>/dev/null; then
    mkdir -p /etc/lightdm/lightdm.conf.d
    cat > /etc/lightdm/lightdm.conf.d/50-telcosec-autologin.conf << 'LIGHTDM'
[Seat:*]
autologin-user=telcosec
autologin-user-timeout=0
user-session=i3
LIGHTDM
fi
EOF
sudo chmod +x /usr/local/bin/telcosec-session-select

# Add systemd oneshot to execute session selector before LightDM starts
cat << 'EOF' | sudo tee /etc/systemd/system/telcosec-session-select.service > /dev/null
[Unit]
Description=TelcoSec Boot Desktop Session Selector
Before=lightdm.service
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/usr/local/bin/telcosec-session-select

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl enable telcosec-session-select.service 2>/dev/null || true

# Copy i3 configs to home if exists
if [ -d /home/telcosec ]; then
    sudo mkdir -p /home/telcosec/.config/i3 /home/telcosec/.config/i3status
    sudo cp /etc/skel/.config/i3/config /home/telcosec/.config/i3/config
    sudo cp /etc/skel/.config/i3status/config /home/telcosec/.config/i3status/config
    sudo chown -R telcosec:telcosec /home/telcosec/.config || true
fi
