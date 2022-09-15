#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

msg "Setting hostname... \n"

if [ -f /etc/hostname ]
then
	HOSTNAME=$(cat /etc/hostname)
else
	HOSTNAME=$(cat /proc/sys/kernel/hostname)
fi

dbg "hostname set to $HOSTNAME \n"
