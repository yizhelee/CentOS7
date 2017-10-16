# CentOS7

## Make up CentOS 7 Bootable USB on MacOS System
* <span style="color:blue">Download **DVD** ISO</span> from https://www.centos.org/download/ 
* List USB device in MacOS : `diskutil list`
* Flash USB with downloaded ISO file using `dd` :
```
dd bs=512m if=/Users/yizli/Downloads/CentOS/CentOS-7-x86_64-DVD-1708.iso oflag=direct of=/dev/disk2; sync
```

## I've got the problem as PC is hanging on boot screen when first booting after CentOS 7 installation. This might be due to incorrect installation of Nvidia driver. 
**Solution** : reinstall nvidia using **`bumblebee`** 
* Press **`e`**, add **`3`** to the end of **line `linux64 .....`**, Then press **`ctrl+x`** to enter to command line
* Once you enter commandline interface, please login as root :

```
yum update

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
* Open and modify bumblebee config: `vi /etc/bumblebee/bumblebee.conf`
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

* Open & Modify nvidia settings : `vi /usr/share/applications/nvidia-settings.desktop` :
```
...
Exec=optirun nvidia-settings -c :8.0
...
```
* Then restart GDM(GNOME Display Manager)
```
systemctl restart gdm.service
```

