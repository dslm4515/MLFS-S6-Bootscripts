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
cp -ar s6-rc /etc/
```

## Layout

Directories in s6-rc:
  * env - environment variables used in services
  * env-fs - environment variables used in mounting filesystems
  * db - Compiled service databases (compiled from a db in db-src)
  * db-src- Sources for the compiled service database
  * run-image - directory that is copied to /run by init
  * scripts - scripts used by services

Scripts:
  * init - stage 1
  * poweroff
  * stage2- stage 2
  * stage2.tini - stage 3
  * reboot
