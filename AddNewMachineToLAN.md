#!/bin/bash

HELP=false
IP_ADDR=""
HOSTNAME=""

# Help information
show_help() {
cat << EOF
Usage: ${0##*/} [-h] -a|--address IP_ADDRESS -n|--hostname HOSTNAME
Configure static ip address
  -h, --help		Display this help and exit
  -a, --address		ipv4 address
  -n, --hostname        Hostname
EOF
}

# Execute getopt on the arguments passed to this program, identified by the special character $@
PARSED_OPTIONS=$(getopt -n "$0" -o h:a:n: --long "help,address:,hostname:" -- "$@")

# Bad arguments, something has gone wrong with the getopt command.
if [ $? != 0 ] ; then echo "Failed parsing options." >&2 ; exit 1 ; fi

# Get options with arguments
#echo "$PARSED_OPTIONS"
eval set -- "$PARSED_OPTIONS"

while true; do
  case "$1" in
    -h | -\? | --help )          HELP=true; shift ;;
    -a | --address )          IP_ADDR="$2"; shift; shift ;;
    -n | --hostname )        HOSTNAME="$2"; shift; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

if [ -z $IP_ADDR ] || [ -z $HOSTNAME ] || [[ "$HELP" = true ]]
then
  show_help
  exit
fi

LAST=$(echo $IP_ADDR | cut  -d'.' -f4)

hostnamectl set-hostname $HOSTNAME.lab.local
hostnamectl status

# Login to master & update /var/named/forward.lab & /var/named/reverse.lab
sshpass -p "yli" ssh root@10.1.0.156 \
"echo '$HOSTNAME              IN       A       $IP_ADDR' >> /var/named/forward.lab          && \
 echo '$LAST       IN     PTR   $HOSTNAME.lab.local.' >> /var/named/reverse.lab             && \
 sed -i.bak '/^master.*/a $HOSTNAME       IN       A       $IP_ADDR' /var/named/reverse.lab && \
 rm -rf /var/named/reverse.lab.bak                                                          && \
 systemctl restart named.service"

# Update Static IP Addr
# For ethernet connection configure : ./StaticIPAddrConfig.sh -i enp0s25 -a $IP_ADDR -m 255.255.255.0
# For wireless interface  configure : ./

# Docker CE installation 
sudo yum remove docker docker-common docker-selinux docker-engine-selinux docker-engine docker-ce
sudo yum install -y yum-utils   device-mapper-persistent-data   lvm2
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable   docker-ce-edge
sudo yum-config-manager --enable   docker-ce-test
sudo yum install -y docker-ce
yum list docker-ce --showduplicates | sort -r
yum install -y docker-ce-17.09.0.ce
systemctl restart docker

docker run hello-world
sudo groupadd docker
sudo usermod -aG docker  $USER
echo $USER

