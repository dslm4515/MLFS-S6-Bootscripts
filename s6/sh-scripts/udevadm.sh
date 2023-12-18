#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh 

msg "Started udev. \n"
dbg "waiting for devices to settle... \n"

/usr/sbin/udevadm trigger --action=add --type=subsystems || emergency_shell
/usr/sbin/udevadm trigger --action=add --type=devices    || emergency_shell
/usr/sbin/udevadm settle || emergency_shell
