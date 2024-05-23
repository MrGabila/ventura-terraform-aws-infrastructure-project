#!/bin/bash
sudo su
apt update -y
apt -y install apache2
systemctl start apache2
systemctl enable apache2
apt install wget -y
wget https://github.com/TheModeler99/simple_applications_for_practice_project/raw/master/streaming_App/jjtech-streaming-application-v2.zip
apt install unzip -y
unzip jjtech-streaming-application-v2.zip
rm -f /var/www/html/index.html
cp -rf jjtech-streaming-application-v2/* /var/www/html/