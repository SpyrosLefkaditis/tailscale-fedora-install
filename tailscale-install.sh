#!/bin/bash

set -e

echo "Starting Tailscale installation..."

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root or use sudo"
   exit 1
fi

# Detect Fedora version and arch
FEDORA_VER=$(rpm -E %fedora)
ARCH=$(uname -m)
echo "Fedora version: $FEDORA_VER"
echo "Architecture: $ARCH"

# Install dnf plugins if not present
echo "Installing dnf-plugins-core..."
dnf install -y dnf-plugins-core

# Create tailscale repo file
echo "Adding Tailscale repository..."
cat >/etc/yum.repos.d/tailscale.repo <<EOL
[tailscale]
name=Tailscale Stable Repository
baseurl=https://pkgs.tailscale.com/stable/fedora/$FEDORA_VER/$ARCH
enabled=1
gpgcheck=1
gpgkey=https://pkgs.tailscale.com/stable/fedora/repo.gpg
EOL

# Refresh repo cache
echo "Refreshing dnf cache..."
dnf clean all
dnf makecache

# Install tailscale
echo "Installing tailscale..."
dnf install -y tailscale

# Enable and start tailscaled service
echo "Enabling and starting tailscaled service..."
systemctl enable --now tailscaled

echo "Tailscale installation completed."
echo "Run 'sudo tailscale up --hostname=your-hostname' to authenticate and start."

exit 0
