# Musl-LFS-S6-Bootscripts
Bootscripts for Musl-LFS (MLFS) using S6 & S6-rc

This is based on the works of Artix Linux (http://www.artixlinux.org/), Skarnet (https://skarnet.org), Adelie Linux (www.adelielinux.org)and ideas from reddit user VerbosePineMarten.

The aim of this project is to create the scripts and files to boot a MLFS/LFS system with S6 and S6-rc. This will replace the LFS bootscripts that LFS uses (to boot a LFS system with SysVinit).

## Requirements

The following can be found at Skarnet (https://skarnet.org/).
  * skalibs
  * execline
  * s6 (2.9.1.x)
  * s6-linux-utils
  * s6-portable-utils (statically built)
  * s6-rc (0.5.x.x)
  * s6-linux-init (1.x.x.x)
  * utmps

## Directions

Copy boot directories and scripts. Do not just copy entire git directory, as it will copy unneeded dot files:
```
# Enter chroot for target system first, otherwise adjust paths accordingly
cp -ar s6 /etc/
cp -av vconsole.conf /etc/
install -v -m755 modules-load /usr/bin/
install -v -m755 tmpfiles /bin/
# Compile a basic database for boot
s6-rc-compile /etc/s6/db/basic /etc/s6/sv 
ln -sv /etc/s6/db/basic /etc/s6/db/current
# Copy necessary scripts to boot, reboot, and poweroff system
install -v -m755 s6/base/bin/* /sbin/
mv /etc/s6/base/scripts /etc/s6/scripts
# Re-initialize s6 init base
rm -rf /etc/s6/base
s6-linux-init-maker -1 -f /etc/s6/skel -p "/bin:/sbin:/usr/bin"    \
                    -D default -G "/sbin/agetty -L -8 tty1 115200" \
                    -c /etc/s6/base -t 2 -L -u root -U utmp /etc/s6/base
rm -rf /etc/s6/base/scripts
# Copy scripts to bring NIC's up and down
install -v -m755 if* /sbin/
mkdir -pv /lib/services
install -v -m755 net-services/* /lib/services/
```

For logging services, create the log user as root:
```
groupadd -g 983 s6log &&
useradd -c "S6-Log User" -d / \
        -u 983 -g s6log -s /usr/bin/false s6log
```
For utmps, create a utmp user:
```
useradd -c "utmps user" -d /run/utmps \
        -u 984 -g utmp -s /bin/false utmp
```


Bootscripts require system boot with a initramfs image. It's unlcear why boot scripts work without an initramfs loaded at boot. You may use thses scripts from BLFS to build one. Script requires cpio installed.
```
# Copy the script to /sbin:
install -v -m755 mkinitrd/mkinitramfs /sbin/
# Copy the configuration:
mkdir -p /usr/share/mkinitramfs 
install -v -m644 mkinitrd/init.in /usr/share/mkinitramfs/ 
# To use, use the kernel version:
mkinitramfs $(uname -r)

```

## Layout

Directories in s6:
  * base - Base directory for s6-linux-init
  * base/run-image - Directory copied to /run at beginning of boot
  * base/scripts - Scripts to shutdown and start system via s6-linux-init
  * base/env - Enviromental varibles to set at boot
  * db - Compiled databases for boot
  * db/current - Compiled database to use for boot
  * skel - Default startup/shutdown scripts
  * sv - Source definitions for databases and services

## Scripts:
  * rc.local - Additional shell commands to execute on bootup
  * s6.conf - Global configuration of s6-rc services

## mkinitrd:
  * mkinitramfs - Script to make a basic initramfs
  * init.in - Configuration for script.

## Setting up Networking at Boot:
```
# install net-services:
mkdir -v /lib/services
install -v -m644 net-services/* /lib/services/
# install helper scripts to bring up and down interfaces:
install -v -m755 if* /sbin/
```
Each interface should have configuration files in /etc/sysconfig. For example:
```
/etc/sysconfig/ifconfig.wlan0              # config for a wifi card
/etc/sysconfig/wpa_supplicant-wlan0.conf   # config for wpa_supplicant for same wifi card
```

Examples are in net-configs

## Usage
To modify services for bootup:
```
# To add
s6-rc-bundle-update add    default service1 service2
# To remove
s6-rc-bundle-update delete default service1 service2
```

Other useful commands:
```
# Stop a service/bundle
s6-rc -d change service_name
# Start a service/bundle
s6-rc -u change service_name
# List all active services
s6-rc -a list
# List all services and bundles in the database
s6-rc-db list all
```
