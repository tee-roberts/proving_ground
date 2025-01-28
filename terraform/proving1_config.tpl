#!/bin/bash

sudo  yum install -y awscli.noarch

sudo  yum install -y python3.x86_64

pip3 install boto3

sudo aws configure set region us-east-2

curl http://169.254.169.254/latest/meta-data/instance-id > /data/instance_id

export INSTANCEID=`cat /data/instance_id`

sed -i "s/INSTANCE_ID/$INSTANCEID/g" /data/scripts/get_public_ip.py

chmod 700 /data/scripts/get_public_ip.py

cd /data

python3 /data/scripts/get_public_ip.py

rm /data/scripts/webserver_ip.sh
