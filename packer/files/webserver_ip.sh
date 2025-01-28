#!/bin/bash

cd /data

aws s3 cp s3://proving-web-server-1/public_ip.txt .

awk '{print $3}' /data/public_ip.txt > /data/webserver_ip.txt

rm /data/public_ip.txt
