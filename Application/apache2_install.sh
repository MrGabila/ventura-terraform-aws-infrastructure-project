#!/bin/bash
# Run on Ubuntu 20.04
sudo su
apt update -y
apt install -y apache2
systemctl enable apache2
systemctl start apache2