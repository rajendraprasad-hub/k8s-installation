#!/bin/bash

# ===============================
# Dynamic Kubernetes Cluster Setup
# ===============================

set -e

if [[ $EUID -ne 0 ]]; then
   echo "Run with sudo or as root"
   exit 1
fi

echo "===== Kubernetes Cluster Setup ====="

# Ask node role
echo "Select this node role:"
echo "1) Master"
echo "2) Worker"
read -p "Enter choice (1/2): " ROLE_CHOICE

# Ask worker number if this is worker
if [[ "$ROLE_CHOICE" == "2" ]]; then
    read -p "Enter Worker number (example: 1,2,3...): " WORKER_NUM
    NODE_HOSTNAME="worker${WORKER_NUM}.example.net"
elif [[ "$ROLE_CHOICE" == "1" ]]; then
    NODE_HOSTNAME="master.example.net"
else
    echo "Invalid choice"
    exit 1
fi

# Set hostname
echo "Setting hostname to $NODE_HOSTNAME ..."
hostnamectl set-hostname "$NODE_HOSTNAME"

# Ask cluster size
read -p "Enter total number of worker nodes: " TOTAL_WORKERS
read -p "Enter Master IP address: " MASTER_IP

# Remove old cluster entries safely
sed -i '/master.example.net/d' /etc/hosts
sed -i '/worker[0-9].example.net/d' /etc/hosts

# Add master entry
echo "$MASTER_IP master.example.net" >> /etc/hosts

# Add worker entries dynamically
for (( i=1; i<=TOTAL_WORKERS; i++ ))
do
    read -p "Enter IP for worker$i: " WORKER_IP
    echo "$WORKER_IP worker$i.example.net" >> /etc/hosts
done

echo "====================================="
echo "Hostname set to: $(hostname)"
echo "/etc/hosts updated successfully!"
echo "====================================="

exec bash
