#!/bin/bash

# $1 - IP

# TODO(asilenlov): we need to refactor this script

# Install Calico on master
mkdir -p /opt/cni/bin
wget -N -P /opt/cni/bin https://github.com/projectcalico/cni-plugin/releases/download/v1.8.3/calico
wget -N -P /opt/cni/bin https://github.com/projectcalico/cni-plugin/releases/download/v1.8.3/calico-ipam
chmod +x /opt/cni/bin/calico /opt/cni/bin/calico-ipam
wget -N -P /usr/bin  https://github.com/projectcalico/calicoctl/releases/download/v1.2.1/calicoctl
chmod +x /usr/bin/calicoctl
wget https://github.com/containernetworking/cni/releases/download/v0.3.0/cni-v0.3.0.tgz
tar -zxvf cni-v0.3.0.tgz
cp loopback /opt/cni/bin/

sed -i.bak "s/%%MASTER_IP%%/$1/g" environ/network-environment
sed -i.bak "s/%%IP%%/$1/g" environ/network-environment
cp -f environ/network-environment /etc

sed -i.bak "s/%%IP%%/$1/g" systemd/calico-node.service
cp -f systemd/calico-node.service /etc/systemd/system/
systemctl enable calico-node.service

mkdir -p /etc/cni/net.d
sed -i.bak "s/%%MASTER_IP%%/$1/g" 10-calico.conf
sed -i.bak "s/%%IP%%/$1/g" 10-calico.conf
cp -f 10-calico.conf /etc/cni/net.d

systemctl start calico-node
