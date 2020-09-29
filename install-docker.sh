#!/bin/bash
if [ x$1 = x"precustomization" ]; then
echo "Started doing pre-customization steps..."
echo "Finished doing pre-customization steps."
elif [ x$1 = x"postcustomization" ]; then
echo "Started doing post-customization steps..."
yum update
yum config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.10-3.2.el7.x86_64.rpm -y
yum install docker-ce docker-ce-cli -y
systemctl stop firewalld
systemctl disable firewalld
systemctl enable docker
systemctl start docker
curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mkdir /root/.ssh
echo ssh-ed25519 mycertificateopenkeygoeshere mltrn@rocks >> /root/.ssh/authorized_keys
chmod 700 /root/.ssh 
chmod 600 /root/.ssh/authorized_keys
echo "Finished doing post-customization steps."
fi