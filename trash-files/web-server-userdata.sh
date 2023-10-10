#!/bin/bash

# Update the system
sudo yum update -y

# Install Apache/Nginx
sudo yum install nginx -y
sudo systemctl start nginx
sudo systemctl enable nginx
sudo firewall-cmd --permanent --zone=public --add-service=http
sudo firewall-cmd --reload

# Install Tenable
# (Replace with the appropriate installation steps for Tenable)

# Install Shorewall
sudo yum install shorewall -y
# Configure Shorewall as needed
# (This involves editing Shorewall configuration files)

# Install CloudStrike
# (Replace with the appropriate installation steps for CrowdStrike)

# Install CloudWatch Agent
# (Replace with the appropriate installation steps for CloudWatch Agent)

# Join Active Directory
#sudo yum install realmd sssd oddjob oddjob-mkhomedir adcli samba-common-tools -y

# (Replace with the appropriate steps for joining AD)

# Disable SELinux
sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sudo setenforce 0

# Reboot to apply changes (if needed)
# sudo reboot
