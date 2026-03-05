#!/bin/bash
set -e

apt-get update -y
apt-get install -y \
  mysql-client \
  curl \
  wget \
  unzip \
  vim

# AWS CLI v2
curl -s "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip
unzip -q /tmp/awscliv2.zip -d /tmp
/tmp/aws/install
rm -rf /tmp/awscliv2.zip /tmp/aws

echo "bastion init done" >> /var/log/bastion-init.log
