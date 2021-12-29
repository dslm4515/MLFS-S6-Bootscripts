# Musl-LFS-S6-Bootscripts
Bootscripts for Musl-LFS (MLFS) using S6 & S6-rc

This is based on the works of Artix Linux (http://www.artixlinux.org/), Skarnet (https://skarnet.org), Adelie Linux (www.adelielinux.org)and ideas from reddit user VerbosePineMarten.

The aim of this project is to create the scripts and files to boot a MLFS/LFS system with S6 and S6-rc. This will replace the LFS bootscripts that LFS uses (to boot a LFS system with SysVinit).

## Requirements

The following can be found at Skarnet (https://skarnet.org/).
  * skalibs 2.11.1.x (required by execline)
  * execline 2.8.2.x (required by s6-rc)
  * s6 2.1.0.x (required by s6-rc)
  * s6-linux-utils
  * s6-portable-utils (statically built)
  * s6-rc 0.5.3.x (New service format)
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
cp -r /etc/s6/scripts /etc/s6/base/scripts

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
  * base/scripts - Scripts to shutdown and start system via s6-linux-init
  * base/env - Enviromental varibles to set at boot
  * db - Compiled databases for boot
  * db/current - Compiled database to use for boot
  * skel - Default startup/shutdown scripts
  * sv - Source definitions for databases and services
  * scripts - Small scripts used by services compiled from sv

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

To disable/enable services, modify the contents of `/etc/s6/sv/services/contents.d`. Then compile a new database to use for the next boot.

For example, to enable dbus service:
```
# Install dbus service scripts (dbus-srv, dbus-log) to /etc/s6/sv/

# Add dbus script to list of services to start at boot:
touch /etc/s6/sv/services/contents.d/dbus-srv

# Compile a new database for boot
s6-rc-compile /etc/s6/db/${new_db} /etc/s6/sv

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

## Changelog since 4.x.x

<ul>
<li>Updated service format: Bundles now use a contents.d directory instead of a contents file</li>
<li>Improved service dependacies: Previous format had issues some services starting before required service(s) executed</li>
<li>/tmp directory now cleaned during boot and during shutdown </li>
<li>System clock now set from hardware clock </li>
<li>Most commands in service scripts use commands from s6-linux-utils or s6-portable-utils </li>
<li>Cleaned up boot messages that are logged in /run/uncaught-logs/current </li>

</ul>
