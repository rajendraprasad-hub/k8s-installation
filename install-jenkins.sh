#!/bin/bash
set -e

echo "===== Updating system ====="
sudo apt update -y
sudo apt upgrade -y

echo "===== Installing Java (OpenJDK 21) ====="
sudo apt install -y openjdk-21-jdk
java -version

echo "===== Adding Jenkins repository ====="
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "===== Installing Jenkins ====="
sudo apt update -y
sudo apt install -y jenkins

echo "===== Starting Jenkins service ====="
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo "===== Jenkins status ====="
sudo systemctl status jenkins --no-pager

echo "===== Initial Admin Password ====="
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
