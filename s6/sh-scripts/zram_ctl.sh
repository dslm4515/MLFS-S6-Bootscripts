#! /bin/sh

# A script to create and remove a zram device
#
# USAGE: zram_ctl start | stop
#

. /etc/s6/dash-scripts/common_funcs.sh 
. /etc/s6/zram.conf

if [ "$1" = "start" ]; then
	# Check if zram is enabled in /etc/s6/zram.conf
	if [ $ZRAM_ENABLE = 1 ]; then
		msg "Turning on zRAM. \n"
		 # Create zram device ...
		 modprobe zram num_devices=1
		 echo $ZRAM_ALGO  > /sys/block/zram0/comp_algorithm
		 echo $ZRAM_SIZE  > /sys/block/zram0/disksize
		 mkswap --label    $ZRAM_LBL /dev/zram0
		 swapon --priority 32767     /dev/zram0
		 dbg "zRAM is $ZRAM_SIZE with $ZRAM_ALGO compression. \n"
	 else
		 msg "Skipping zRAM initialization. \n"
	fi
fi

if [ "$1" = "stop" ]; then
	# Remove zram device if present
	if [ -f /dev/zram0 ] ; then
		msg "Turning off zRAM. \n"
		swapoff /dev/zram0 && \
		echo 1 > /sys/block/zram0/reset && \
		modprobe -r zram
	else
		msg "No zRAM devices found. \n"
	        dbg "zRAM may not have been enabled"
	fi
fi

