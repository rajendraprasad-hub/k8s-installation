#!/bin/bash
set -e

echo "===== Updating system ====="
sudo apt update -y
sudo apt upgrade -y

echo "===== Installing prerequisites ====="
sudo apt install -y openjdk-21-jdk unzip wget gnupg software-properties-common

echo "===== Creating SonarQube user ====="
sudo adduser --system --no-create-home --group --disabled-login sonarqube

echo "===== Downloading SonarQube ====="
SONAR_VERSION=10.5.1.90531
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-${SONAR_VERSION}.zip
unzip sonarqube-${SONAR_VERSION}.zip
sudo mv sonarqube-${SONAR_VERSION} /opt/sonarqube
sudo chown -R sonarqube:sonarqube /opt/sonarqube

echo "===== Configuring SonarQube service ====="
sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOF
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=simple
User=sonarqube
Group=sonarqube
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
Restart=always
LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

echo "===== Reloading systemd and starting SonarQube ====="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable sonarqube
sudo systemctl start sonarqube

echo "===== Checking SonarQube status ====="
sudo systemctl status sonarqube --no-pager

echo "===== SonarQube installation completed ====="
echo "Access SonarQube at: http://$(hostname -I | awk '{print $1}'):9000"
