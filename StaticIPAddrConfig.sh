#!/bin/bash

HELP=false
VERBOSE=false
INTERFACE_NAME=
IP_ADDR=""
NETMASK=""

# Help information
show_help() {
cat << EOF
Usage: ${0##*/} [-hv] [-i|--interface INTERFACE_NAME] -a|--address IP_ADDRESS -m|--netmask NETMASK
Configure static ip address
  -h, --help		Display this help and exit
  -v, --verbose		Verbose mode. Can be used multiple times for 
                        increased verbosity.
  -i, --interface	Network interface name
  -a, --address		ipv4 address
  -m, --mask		Netmask
EOF
}

# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0" -o hvi:a:m: --long "help,verbose,interface:,address:,netmask:" -- "$@")

# Bad arguments, something has gone wrong with the getopt command.
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

# Get options with arguments
#echo "$PARSED_OPTIONS"
eval set -- "$PARSED_OPTIONS"

while true; do
  case "$1" in
    -h | -\? | --help )          HELP=true; shift ;;
    -v | --verbose )          VERBOSE=true; shift ;;
    -i | --interface ) INTERFACE_NAME="$2"; shift; shift ;;
    -a | --address )          IP_ADDR="$2"; shift; shift ;;
    -m | --netmask )          NETMASK="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ -z $IP_ADDR ] || [ -z $NETMASK ] || [[ "$HELP" = true ]]
then
  show_help
  exit
fi

iter=2
if [ -z $INTERFACE_NAME ]
then
  echo "Please choose the network interface to configure :"
  while [ ${#lines[@]} -le 1 ] && [ $iter -gt 0 ]
  do 
    readarray -t lines < <(nmcli dev status | { head -1; grep connected; })
    (( iter-- ))
  done
  [ ${#lines[@]} -le 1 ] && echo "No network interface is connected" && exit
  printf '%s\n' "${lines[@]}" 
  read INTERFACE_NAME
fi

# NM_CONTROLLED=no indicates that this interface will be set up using this configuration file, 
#                  instead of being managed by Network Manager service. 
# ONBOOT=yes tells the system to bring up the interface during boot.

# Add static IP Address configuration to the given network interface
add() {
  sed -i.bak "s|BOOTPROTO=.*|BOOTPROTO=static|g" /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  sed -i.bak "/BOOTPROTO=.*/a IPADDR=$IP_ADDR\nNETMASK=$NETMASK\nNM_CONTROLLED=no" /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  sed -i.bak "s|ONBOOT=.*|ONBOOT=yes|g" /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  rm -f /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME.bak
}

# Change static IP Address
change() {
  sed -i.bak "s|BOOTPROTO=.*|BOOTPROTO=static|g"      /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  sed -i.bak "s|IPADDR=.*|IPADDR=$IP_ADDR|g"          /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  sed -i.bak "s|NETMASK=.*|NETMASK=$NETMASK|g"        /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  sed -i.bak "s|NM_CONTROLLED=.*|NM_CONTROLLED=no|g" /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  sed -i.bak "s|ONBOOT=.*|ONBOOT=yes|g"               /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME
  rm -f /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME.bak
}

grep IPADDR /etc/sysconfig/network-scripts/ifcfg-$INTERFACE_NAME > /dev/null
if [ $? -eq 0 ];
then
  change
else
  add
fi

echo "New IP Address : $IP_ADDR"
systemctl restart network.service
ip add
systemctl status network.service


#sudo xcodebuild -license accept
#sshpass -p "yli" scp ./staticIP.sh root@10.1.0.153:/root

