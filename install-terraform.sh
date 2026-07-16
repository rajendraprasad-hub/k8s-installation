#!/bin/bash
set -e

echo "===== Updating system ====="
sudo apt update -y
sudo apt upgrade -y

echo "===== Installing prerequisites ====="
sudo apt install -y gnupg software-properties-common curl

echo "===== Adding HashiCorp GPG key ====="
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "===== Adding HashiCorp repository ====="
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list

echo "===== Installing Terraform ====="
sudo apt update -y
sudo apt install -y terraform

echo "===== Verifying Terraform installation ====="
terraform version
which terraform

echo "===== Terraform installation completed successfully ====="
