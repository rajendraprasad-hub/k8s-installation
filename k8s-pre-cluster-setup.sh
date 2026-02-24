#!/bin/bash

# ===============================
# Kubernetes Cluster Node Setup
# ===============================

set -e

# Must run as root
if [[ $EUID -ne 0 ]]; then
   echo "Please run as root or with sudo"
   exit 1
fi

echo "===== Kubernetes Cluster Setup ====="

# Ask which node this is
echo "Select this node type:"
echo "1) Master"
echo "2) Worker1"
echo "3) Worker2"
read -p "Enter choice (1/2/3): " NODE_CHOICE

case $NODE_CHOICE in
  1)
    NODE_HOSTNAME="master.example.net"
    ;;
  2)
    NODE_HOSTNAME="worker1.example.net"
    ;;
  3)
    NODE_HOSTNAME="worker2.example.net"
    ;;
  *)
    echo "Invalid choice!"
    exit 1
    ;;
esac

# Set hostname
echo "Setting hostname to $NODE_HOSTNAME ..."
hostnamectl set-hostname "$NODE_HOSTNAME"

# Cluster entries
MASTER_IP="172.31.35.217"
WORKER1_IP="172.31.37.183"
WORKER2_IP="172.31.44.138"

# Remove old entries if exist
sed -i '/master.example.net/d' /etc/hosts
sed -i '/worker1.example.net/d' /etc/hosts
sed -i '/worker2.example.net/d' /etc/hosts

# Add fresh entries
cat <<EOF >> /etc/hosts
$MASTER_IP master.example.net
$WORKER1_IP worker1.example.net
$WORKER2_IP worker2.example.net
EOF

echo "Updated /etc/hosts with all cluster nodes."

echo "====================================="
echo "Hostname: $(hostname)"
echo "Hosts file configured successfully!"
echo "====================================="

exec bash
