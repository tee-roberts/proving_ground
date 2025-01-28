#!/bin/bash

sudo  yum install -y awscli.noarch

sudo aws configure set region us-east-2

mkdir /data/cron

mkdir /data/scripts

echo "0 0 * * * /data/scripts/webserver_ip.sh" > /data/cron/client_cron

cd /data/cron

sudo crontab client_cron

chmod 700 /data/scripts/webserver_ip.sh

rm /data/scripts/get_public_ip.py


