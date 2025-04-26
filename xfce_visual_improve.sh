#!/bin/bash

# Script to improve font rendering and visual appearance of XFCE in EndeavourOS

# Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "This script requires root privileges."
  echo "Please run with sudo: sudo $0"
  exit 1
fi

echo "=== Improving XFCE visual appearance in EndeavourOS ==="
echo "This script will install additional fonts and optimize display settings."

# Install required packages
echo -e "\n[1/5] Installing additional fonts..."
pacman -S --needed --noconfirm \
  ttf-ubuntu-font-family \
  ttf-roboto \
  ttf-fira-code \
  ttf-fira-sans \
  ttf-droid \
  ttf-opensans \
  ttf-hack \
  ttf-jetbrains-mono \
  adobe-source-code-pro-fonts \
  adobe-source-sans-fonts \
  cantarell-fonts \
  noto-fonts-emoji

# Configure Freetype for better font rendering
echo -e "\n[2/5] Configuring Freetype for font smoothing..."
cat > /etc/fonts/local.conf << 'EOL'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit name="antialias" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hinting" mode="assign">
      <bool>true</bool>
    </edit>
    <edit name="hintstyle" mode="assign">
      <const>hintslight</const>
    </edit>
    <edit name="rgba" mode="assign">
      <const>rgb</const>
    </edit>
    <edit name="lcdfilter" mode="assign">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
EOL

# Install Papirus icon theme
echo -e "\n[3/5] Installing Papirus icon theme..."
pacman -S --needed --noconfirm papirus-icon-theme

# Install Arc GTK theme
echo -e "\n[4/5] Installing Arc GTK theme..."
pacman -S --needed --noconfirm arc-gtk-theme-eos

# Install additional XFCE utilities
echo -e "\n[5/5] Installing additional XFCE utilities..."
pacman -S --needed --noconfirm \
  xfce4-whiskermenu-plugin \
  xfce4-pulseaudio-plugin \
  xfce4-weather-plugin \
  xfce4-systemload-plugin \
  xfce4-notifyd \
  plank \
  redshift

# Get real username and home directory
REAL_USER=$(logname || echo $SUDO_USER)
USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# Create settings script to apply after login
echo -e "\nCreating user settings script..."
USER_SETTINGS_SCRIPT="$USER_HOME/apply_xfce_settings.sh"

cat > "$USER_SETTINGS_SCRIPT" << 'EOL'
#!/bin/bash

echo "Applying XFCE settings..."

# Configure XFCE parameters using xfconf-query
xfconf-query -c xsettings -p /Gtk/FontName -s "Ubuntu 11"
xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "JetBrains Mono 10"
xfconf-query -c xsettings -p /Gtk/CursorThemeName -s "Breeze_Snow"
xfconf-query -c xsettings -p /Net/ThemeName -s "Arc-Dark"
xfconf-query -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"

# Enable composite manager
xfconf-query -c xfwm4 -p /general/use_compositing -s true
xfconf-query -c xfwm4 -p /general/frame_opacity -s 85
xfconf-query -c xfwm4 -p /general/show_frame_shadow -s true
xfconf-query -c xfwm4 -p /general/show_popup_shadow -s true
xfconf-query -c xfwm4 -p /general/vblank_mode -s "glx"

# Configure XFCE fonts
xfconf-query -c xfwm4 -p /general/title_font -s "Ubuntu Bold 11"
xfconf-query -c xsettings -p /Xft/Antialias -s 1
xfconf-query -c xsettings -p /Xft/Hinting -s 1
xfconf-query -c xsettings -p /Xft/HintStyle -s "hintslight"
xfconf-query -c xsettings -p /Xft/RGBA -s "rgb"
xfconf-query -c xsettings -p /Xft/DPI -s -1

# Set window theme
xfconf-query -c xfwm4 -p /general/theme -s "Arc-Dark"

# Configure Plank autostart (dock panel)
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/plank.desktop << 'EOLPLANK'
[Desktop Entry]
Type=Application
Name=Plank
Comment=Dock panel
Exec=plank
Icon=plank
Terminal=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOLPLANK

# Configure Redshift (blue light filter)
mkdir -p ~/.config/redshift
cat > ~/.config/redshift/redshift.conf << 'EOLRS'
[redshift]
temp-day=6500
temp-night=4500
transition=1
gamma=0.8
location-provider=manual
adjustment-method=randr

[manual]
lat=50.0
lon=10.0
EOLRS

mkdir -p ~/.config/autostart
cat > ~/.config/autostart/redshift.desktop << 'EOLRSD'
[Desktop Entry]
Type=Application
Name=Redshift
Comment=Color temperature adjustment
Exec=redshift-gtk
Icon=redshift
Terminal=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOLRSD

# Restart XFCE panel
xfce4-panel -r &
xfwm4 --replace &

echo "XFCE settings successfully applied!"
EOL

# Make script executable and set correct owner
chmod +x "$USER_SETTINGS_SCRIPT"
chown "$REAL_USER:$REAL_USER" "$USER_SETTINGS_SCRIPT"

# Create autostart entry for executing the script at user login
AUTOSTART_DIR="$USER_HOME/.config/autostart"
mkdir -p "$AUTOSTART_DIR"
chown "$REAL_USER:$REAL_USER" "$AUTOSTART_DIR"

cat > "$AUTOSTART_DIR/xfce_settings.desktop" << EOL
[Desktop Entry]
Type=Application
Name=XFCE Settings Applier
Comment=Applies improved XFCE settings
Exec=$USER_SETTINGS_SCRIPT
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
EOL

chown "$REAL_USER:$REAL_USER" "$AUTOSTART_DIR/xfce_settings.desktop"

echo -e "\n=== Installation complete! ==="
echo "Packages and configuration files have been installed successfully."
echo "To apply the settings, log out and log back in, or run:"
echo -e "\n$USER_SETTINGS_SCRIPT\n"
echo "The settings script has also been added to startup applications"
echo "and will be automatically applied on your next login."
echo -e "\nEnjoy your improved XFCE experience!" 