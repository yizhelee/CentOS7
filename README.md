# CentOS7

## Installation
<span style="color:blue">Download *DVD* ISO</span>

Make bootable USB from ISO file : 
dd bs=512m if=/Users/yizli/Downloads/CentOS/CentOS-7-x86_64-DVD-1708.iso of=/dev/disk2; sync

List USB device in MacOS : 
diskutil list

## Install NVidia :
* Press 'e', add ' 3 ' to the end of line "linux64 .....", Then press ctrl+x to enter to command line
* After enter commandline 
```
login as root
sudo -i

yum update

Systemctl restart gdm.service




lspci -nn | grep -i nvidia

rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-2.el7.elrepo.noarch.rpm

yum install -y nvidia-detect
yum install -y $(nvidia-detect)
yum install -y bumblebee
yum install -y kmod-bbswitch
yum install -y libbsd
yum install -y VirtualGL

usermod -a -G bumblebee yli
```
vi /etc/bumblebee/bumblebee.conf
```
[bumblebeed]
VirtualDisplay=:8
KeepUnusedXServer=false
ServerGroup=bumblebee
TurnCardOffAtExit=false
NoEcoModeOverride=false
Driver=nvidia
XorgConfDir=/etc/bumblebee/xorg.conf.d

[optirun]
Bridge=auto
VGLTransport=proxy
PrimusLibraryPath=/usr/lib/primus:/usr/lib32/primus
AllowFallbackToIGC=false

[driver-nvidia]
KernelDriver=nvidia
PMMethod=bbswitch
LibraryPath=/usr/lib64/nvidia:/usr/lib64/vdpau:/usr/lib/nvidia:/usr/lib/vdpau
XorgModulePath=/usr/lib64/xorg/modules/extensions/nvidia,/usr/lib64/xorg/modules/drivers,/usr/lib64/xorg/modules

XorgConfFile=/etc/bumblebee/xorg.conf.nvidia

[driver-nouveau]
KernelDriver=nouveau
PMMethod=auto
XorgConfFile=/etc/bumblebee/xorg.conf.nouveau

```

vi /usr/share/applications/nvidia-settings.desktop :
```
...
Exec=optirun nvidia-settings -c :8.0
...
```
```
systemctl restart gdm.service
```










