# Musl-LFS-S6-Bootscripts
Bootscripts for Musl-LFS (MLFS) using S6 & S6-rc

This is based on the works of Artix Linux (http://www.artixlinux.org/), Skarnet (https://skarnet.org), Adelie Linux (www.adelielinux.org)and ideas from reddit user VerbosePineMarten.

The aim of this project is to create the scripts and files to boot a MLFS/LFS system with S6 and S6-rc. This will replace the LFS bootscripts that LFS uses (to boot a LFS system with SysVinit).

The bootscripts were rewritten from excline to sh, to be executed by dash.

## Requirements

The following can be found at Skarnet (https://skarnet.org/).
  * skalibs 2.11.1.x (required by execline)
  * execline 2.8.2.x (required by s6-rc)
  * s6 2.1.0.x (required by s6-rc)
  * s6-linux-utils
  * s6-portable-utils (statically built)
  * s6-rc 0.5.3.x (New service format)
  * s6-linux-init (1.x.x.x)
  * utmps (optional for musl, not needed for Glibc).

## Features

  * Parallel boot - Boot scripts are executed in parallel with a dependacy hierarchy.

  * Safe Mode - System can now be booted with minimal scripts for troubleshooting. To use, set the kernel parameter `init=/sbin/init` to `init=/sbin/init-safemode`

  * zRAM Support  - If kernel supports zRAM, a single zRAM device can be initialized at boot.


## Directions

Copy boot directories and scripts. Do not just copy entire git directory, as it will copy unneeded dot files:
```
# Enter chroot for target system first, otherwise adjust paths accordingly
cp -ar s6 /etc/

# Compile a basic database for boot
s6-rc-compile /etc/s6/db/basic /etc/s6/dbsrc 
ln -sv /etc/s6/db/basic /etc/s6/db/current

# Make sure the skeleton scripts are adjusted to boot s6 & s6-rc... or copy over with these:
cp -v rc.init rc.shutdown runlevel /etc/s6-linux-init/skel/

# Re-initialize s6 init base (with utmps installed)
rm -rf /etc/s6/base
s6-linux-init-maker -1 -f /etc/s6-linux-init/skel -p "/bin:/sbin:/usr/bin:/usr/sbin"    \
                    -D default -G "/sbin/agetty -L -8 tty1 115200" \
                    -c /etc/s6/base -t 2 -L -u root -U utmp /etc/s6/base

# Re-initialize s6 init base (without utmps installed)
rm -rf /etc/s6/base
s6-linux-init-maker -1 -f /etc/s6-linux-init/skel -p "/bin:/sbin:/usr/bin:/usr/sbin"    \
                    -D default -G "/sbin/agetty -L -8 tty1 115200" \
                    -c /etc/s6/base -t 2 -L -u root  /etc/s6/base

# Copy or link necessary scripts to boot, reboot, and poweroff system
ln -sv /etc/s6/base/bin/halt       /usr/sbin/
ln -sv /etc/s6/base/bin/poweroff   /usr/sbin/
ln -sv /etc/s6/base/bin/reboot     /usr/sbin/
ln -sv /etc/s6/base/bin/shutdown   /usr/sbin/
cp -v  /etc/s6/base/bin/init       /usr/sbin/

# Create the safemode init script:
cp -v  /etc/s6/base/bin/init       /usr/sbin/init-safemode
sed -i 's/default/safemode/g'      /usr/sbin/init-safemode 

# If not using NetworkManager:
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
Make sure the directory for dmesg logging is owned by the log user
```
mkdir -pv /var/log/dmesg
chown -v s6log:s6log /var/log/
```

For utmps, create a utmp user:
```
useradd -c "utmps user" -d /run/utmps \
        -u 984 -g utmp -s /bin/false utmp
```

Make sure the directory for wtmp is owned by utmp user:
```
mkdir -pv /var/log/utmps
mv -v /var/log/wtmp /var/log/utmps/
chown -vR utmp:utmp /var/log/utmps
ln -sv utmps/wtmp /var/log/wtmp
```

Bootscripts no longer require system boot with a initramfs image. But kernel parameters should boot with root filesystem as read-only for checking root filesystem at boot (i.e. linux root=/dev/sda2 ro) You may use scripts from BLFS or Musl-LFS to build one. Script requires cpio installed.
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
  * base/env - Enviromental varibles to set at boot
  * db - Compiled databases for boot
  * db/current - Compiled database to use for boot
  * dbsrc - Source definitions for databases and services
  * dash-scripts - Boot scripts used in the compiled databases
  * doc/mock-boot-tree - Use command tree to see how the layout of sv

## Boot Configuration:
  * s6.conf - Global configuration of s6-rc services
  * zram.conf - Configuration for setting up a zram device

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

To disable/enable services, modify the contents of `/etc/s6/dbsrc/services/contents.d`. Then compile a new database to use for the next boot.

For example, to enable dbus service:
```
# Install dbus service scripts (dbus-srv, dbus-log) to /etc/s6/dbsrc/

# Add dbus script to list of services to start at boot:
touch /etc/s6/dbsrc/services/contents.d/dbus-srv

# Compile a new database for boot
s6-rc-compile /etc/s6/db/${new_db} /etc/s6/dbsrc

# Link new database to boot
mv -v /etc/s6/db/current /etc/s6/db/previous
ln -sv /etc/s6/db/${new_db} /etc/s6/db/current
```

Services an be enabled or disabled after boot:
```
# Enable a service that was not enabled at boot
sudo s6-rc -u change ${service_name}

# Disable a service
sudo s6-rc -d change ${service_name}

# To see the list of services to enable/disable:
ls /run/service/*

```

## Changelog since 5.x.x

<ul>
<li>Redesigned boot database</li>
<li>Updated instructions to check s6-linux-init skeleton scripts</li>
<li>Added zRAM support</li>
<li>Renamed /etc/s6/sv to dbsrc</li>
<li>Converted oneshot boot scripts from execline to sh. Longrun scripts still need to be in execline</li>
<li>Added safemode bundle for troubleshooting</li>
</ul>
