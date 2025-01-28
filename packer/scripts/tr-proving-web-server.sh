#!/bin/bash

sleep 60s

#Update CentOs7 base repo

  sudo rm -f /etc/yum.repos.d/CentOS-Base.repo
  sudo   mv /tmp/CentOSBase.repo /etc/yum.repos.d/

# Install required packages httpd(webserver) yum-cron(cron updates)

   sudo yum install -y httpd.x86_64
   sudo yum install -y yum-cron.noarch

# Open firewall port 80 for web server

   sudo yum install -y iptables-services.x86_64
 
   sudo systemctl enable iptables

   sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

   sudo service iptables save

# Set selinux to permissive mode

  sudo sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/selinux/config

# Apply yum updates on system start

  sudo sed -i 's/apply_updates = no/apply_updates = yes/g' /etc/yum/yum-cron.conf

  sudo sed -i 's/random_sleep = 360/random_sleep = 0/g'  /etc/yum/yum-cron.conf

# Format and mount data volume

  sudo mkdir  /data

  sudo mkfs -t xfs  /dev/xvdi

  sudo mount /dev/xvdi /data

# Mount data volume on reboot

  sudo cp /etc/fstab /etc/fstab_org

  sudo  blkid /dev/xvdi | awk '{print $2 " " ""  "/data  xfs  defaults,nofail  0  2"}' | sed 's/"//g' | sudo tee -a /etc/fstab

# Make http directories

  sudo mkdir -p /data/httpd/www/html

  sudo mkdir -p /data/httpd/www/cgi-bin

# Make script directories

  sudo mkdir -p /data/scripts

# Move over scripts

  sudo mv /tmp/get_public_ip.py /data/scripts/

  sudo mv /tmp/webserver_ip.sh /data/scripts/

# Start httpd and enable to start at server boot up

   sudo systemctl start httpd
   sudo systemctl enable httpd

# Copy over custom index.html file

  sudo mv /tmp/index.html /data/httpd/www/html/

# Point httpd to new index.html path

  sudo sed -i 's/\/var\/www\/html/\/data\/httpd\/www\/html/g' /etc/httpd/conf/httpd.conf

  sudo  sed -i 's/\/var\/www/\/data\/httpd\/www/g' /etc/httpd/conf/httpd.conf

# Start yum cron and enable to start on server boot

   sudo systemctl start yum-cron
   sudo systemctl enable yum-cron
   sleep 60s
  
