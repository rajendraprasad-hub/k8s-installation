#!/bin/bash

set -e

echo "===== Disable Swap ====="
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

echo "===== Enable Kernel Modules ====="
sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

sudo sysctl --system

echo "===== Install Required Packages ====="
sudo apt update
sudo apt install -y curl gnupg software-properties-common apt-transport-https ca-certificates

echo "===== Install Containerd ====="
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/containerd.gpg

sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y containerd.io

sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null

sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' \
/etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "===== Install Kubernetes Components ====="
sudo mkdir -p /etc/apt/keyrings

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | \
sudo gpg --dearmor -o /etc/apt/keyrings/k8s.gpg

echo "deb [signed-by=/etc/apt/keyrings/k8s.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | \
sudo tee /etc/apt/sources.list.d/k8s.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubeadm kubelet kubectl

echo "===== Initialize Kubernetes Cluster ====="
sudo kubeadm init \
--control-plane-endpoint=master.example.net \
--pod-network-cidr=192.168.0.0/16

echo "===== Configure kubectl for Current User ====="
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "===== Master Node Preparation Completed ====="

