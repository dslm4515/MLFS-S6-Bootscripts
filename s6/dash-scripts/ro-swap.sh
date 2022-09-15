#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

case $1 in

	up )  msg "Activating swap file/partitions \n"
		/usr/sbin/swapon -a
	;;
        down ) msg "Turning off swap file/partitions \n"
		/usr/sbin/swapoff -a
	;;
esac	
