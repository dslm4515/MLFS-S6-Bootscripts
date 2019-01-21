# Musl-LFS-s6-Bootscripts
Bootscripts for Musl-LFS (MLFS) using S6

This is based on the works of Obarun Linux (http://web.obarun.org/), Skarnet (https://skarnet.org/), and ideas from reddit user VerbosePineMarten.

The aim of this project is to create the scripts and files to boot a MLFS/LFS system with S6 and S6-rc. This will replace the LFS bootscripts that LFS uses (to boot a LFS system with SysVinit or systemD).

## Requirements

The following can be found at Skarnet (https://skarnet.org/)
  * skalibs
  * execline
  * s6
  * s6-linux-utils
  * s6-portable-utils
  * s6-rc
  * s6-linux-init

## Directions

Copy boot directories and scripts. Do not just copy entire git directory, as it will copy unneeded dot files:
```
# Enter chroot for target system first, otherwise adjust paths accordingly
cp -ar s6 /etc/
# Compile the 'basic' database.
s6-rc-compile /etc/s6/db/basic /etc/s6/db-src/basic
# Create link database to use for boot
ln -sv /etc/s6/db/basic /etc/s6/db/current
# Create link for Kernel to find init script
ln -sv /etc/s6/init /sbin/init
# Create links for poweroff and reboot
ln -sv /usr/bin/s6-reboot /sbin/reboot
ln -sv /usr/bin/s6-poweroff /sbin/poweroff
```

For logging services, create the log user as root:
```
groupadd -g 19 log &&
useradd -c "S6 Log User" -d /var/log/aux-serv \
        -u 19 -g log -s /bin/false log
# Create the directory
install -m0755 -o 19 -g 19 -d /var/log/aux-serv
```

Bootscripts require system boot with a initramfs image. It's unlcear why boot scripts work without an initramfs loaded at boot. You may use thses scripts from BLFS to build one. Script requires cpio installed.
```
# Copy the script to /sbin:
cp -v mkinitrd/mkinitramfs /sbin
chmod 0755 /sbin/mkinitramfs
# Copy the configuration:
mkdir -p /usr/share/mkinitramfs 
cp -v  mkinitrd/init.in /usr/share/mkinitramfs/ 
# To use, use the kernel version. For example if:
uname -r
# Outputs: 4.19.0-AMD64-RADEON-STABLE
# then:
mkinitramfs 4.19.0-AMD64-RADEON-STABLE

```

## Layout

Directories in s6:
  * auxdb - Compiled service databases
  * auxdb-src - Sources to compile service database
  * env - environment variables used in services
  * env-fs - environment variables used in mounting filesystems
  * db - Compiled boot databases (compiled from a database source in db-src)
  * db-src- Sources to compile boot database via "s6-rc-compile"
  * run-image - directory that is copied to /run by init
  * scripts - scripts used by services

## Scripts:
  * init - stage 1
  * stage2- stage 2
  * stage2.tini - shutdown script
  * stage3 - stage 3
  * aux-services - Launches [auxillary]  services that are not required for boot.

## Databases:
  * Basic - Basic bootup to get machine to a command propmt with root filesystem in read-write mode, udev started and swap turned on
  * default - Normal boot with services: acpid, consolekit, dbus, usbmuxd (for use with libimobiledevice) and setup network interfaces (i.e. wpa_supplicant and dhcpd). This loads the boot database and services database.

## mkinitrd:
  * mkinitramfs - Script to make a basic initramfs
  * init.in - Configuration for script.

## Setting up Networking at Boot:
```
# install net-services:
mkdir -v /lib/services
cp -vr net-services/* /lib/services/
# install helper scripts to bring up and down interfaces:
cp -v if* /sbin/
```
Each interface should have configuration files in /etc/sysconfig. For example:
```
/etc/sysconfig/ifconfig.wlan0              # config for a wifi card
/etc/sysconfig/wpa_supplicant-wlan0.conf   # config for wpa_supplicant for same wifi card
```

Examples are in net-configs

