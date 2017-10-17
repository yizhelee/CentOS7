#!/bin/bash

INTERFACE_NAME=wlp3s0
NETMASK=255.255.255.0
IPADDR=10.1.0.170

cat << EOF >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
DEVICE=$INTERFACE_NAME
BOOTPROTO=none
ONBOOT=yes
NETMASK=$NETMASK
IPADDR=$IPADDR
EOF

systemctl restart network.service
systemctl status network.service
