#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

msg "Setting hostname... \n"

if [ -f /etc/hostname ]
then
	hostname $(cat /etc/hostname)
else
	hostname $(cat /proc/sys/kernel/hostname)
fi

dbg "hostname set to $HOSTNAME \n"
