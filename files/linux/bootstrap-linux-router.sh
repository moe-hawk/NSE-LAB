#!/usr/bin/env bash
set -euo pipefail
# === EDIT THESE IF YOUR NIC NAMES DIFFER ===
WAN_IF="ens3"   # DHCP / Internet 
LAN1_IF="ens4"  # 10.200.1.254/24 
LAN2_IF="ens5"  # 10.200.2.254/24 
LAN4_IF="ens6"  # 10.200.3.254/24 
LAN5_IF="ens7"  # 10.200.4.254/24 
echo "[1/6] Installing packages..."
sudo apt-get update -y
sudo apt-get install -y iptables-persistent netfilter-persistent
echo "[2/6] Writing netplan config..."
sudo tee /etc/netplan/01-lab-router.yaml >/dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    ${WAN_IF}:
      dhcp4: true
    ${LAN1_IF}:
      dhcp4: false
      addresses: [10.200.1.254/24]
    ${LAN2_IF}:
      dhcp4: false
      addresses: [10.200.2.254/24]
    ${LAN4_IF}:
      dhcp4: false
      addresses: [10.200.3.254/24]
    ${LAN5_IF}:
      dhcp4: false
      addresses: [10.200.4.254/24]
EOF
echo "[3/6] Applying netplan..."
sudo netplan apply
echo "[4/6] Enabling IPv4 forwarding..."
sudo tee /etc/sysctl.d/99-lab-router.conf >/dev/null <<EOF
net.ipv4.ip_forward=1
EOF
sudo sysctl --system >/dev/null
echo "[5/6] Configuring NAT (MASQUERADE out WAN)..."
sudo iptables -t nat -F
sudo iptables -F FORWARD
sudo iptables -t nat -A POSTROUTING -o "${WAN_IF}" -j MASQUERADE
sudo iptables -A FORWARD -i "${WAN_IF}" -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo iptables -A FORWARD -o "${WAN_IF}" -j ACCEPT
echo "[6/6] Saving firewall rules persistently..."
sudo netfilter-persistent save
sudo netfilter-persistent reload
echo "Done."
echo "Quick checks:"
echo "  ip -br addr"
echo "  sysctl net.ipv4.ip_forward"
echo "  sudo iptables -t nat -S"
