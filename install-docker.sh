#!/bin/bash
set -e

echo "===== Updating system ====="
sudo apt update -y
sudo apt upgrade -y

echo "===== Installing prerequisites ====="
sudo apt install -y ca-certificates curl gnupg lsb-release

echo "===== Adding Docker GPG key ====="
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "===== Adding Docker repository ====="
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "===== Installing Docker ====="
sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "===== Enabling Docker service ====="
sudo systemctl enable --now docker

echo "===== Docker version ====="
docker --version

sudo usermod -aG docker jenkins
sudo systemctl restart docker
sudo systemctl restart jenkins

echo "===== Docker installation completed successfully ====="
