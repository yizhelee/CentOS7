#!/bin/bash

INTERFACE_NAME=wlp3s0
NETMASK=255.255.255.0
IPADDR=10.1.0.170

TYPE=`nmcli dev status | grep wlp3s0 | awk '{ print $2 }'`
if [ $TYPE != "wifi"];
then
  echo "$INTERFACE_NAME is $TYPE, but not a wireless interface"
  exit
fi

cat << EOF >> /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
DEVICE=$INTERFACE_NAME
BOOTPROTO=none
ONBOOT=yes
NETMASK=$NETMASK
IPADDR=$IPADDR
EOF

echo "New IP Address is $IPADDR"

systemctl restart network.service
systemctl status network.service
