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
mkdir -pv /etc/s6-linux-init
cp -rv ./{run-image,env,fs-env,rc,scripts} /etc/s6-linux-init/
cp -v ./{init,poweroff,reboot,s6.conf,rc.shutdown,rc.init,rc.tini} /etc/s6-linux-init/
ln -svf /etc/s6-linux-init/init /sbin/init
s6-rc-compile /etc/s6-linux-init/srvdb /etc/s6-linux-init/rc
```

## Layout

Directories:
  * env - environment variables used in services
  * fs-env - environment variables used in mounting filesystems
  * rc - source for the compiled service database
  * run-image - directory that is copied to /run by init
  * scripts - scripts used by services
  * srvdb - compiled service database (compiled from rc)

Scripts:
  * init - stage 1
  * poweroff
  * rc.init - stage 2
  * rc.tini - stage 3
  * reboot
  * s6.conf - settings to customize boot
