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
s6-rc-compile /etc/s6/db/default /etc/s6/db-src/basic
# Create link database to use for boot
ln -sv /etc/s6/db/default /etc/s6/db/current
# Create link for Kernel to find init script
ln -sv /etc/s6/init /sbin/init
# Create links for poweroff and reboot
ln -sv /usr/bin/s6-reboot /sbin/reboot
ln -sv /usr/bin/s6-poweroff /sbin/poweroff
```

## Layout

Directories in s6:
  * env - environment variables used in services
  * env-fs - environment variables used in mounting filesystems
  * db - Compiled service databases (compiled from a database source in db-src)
  * db-src- Sources to compile service database via "s6-rc-compile"
  * run-image - directory that is copied to /run by init
  * scripts - scripts used by services

## Scripts:
  * init - stage 1
  * stage2- stage 2
  * stage2.tini - shutdown script
  * stage3 - stage 3

## Databases:
  * Basic - Basic bootup to get machine to a command propmt with root filesystem in read-write mode, udev started and swap turned on
  * default - Normal boot with service: acpid, consolekit, dbus, usbmuxd (for use with libimobiledevice) and setup network interfaces (i.e. wpa_supplicant and dhcpd)

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
/etc/sysconfig/wpa_supplicant-wlan0.conf   # config for wpa_supplicant for  same wifi card
```

Examples are in net-configs

