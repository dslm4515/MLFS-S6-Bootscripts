#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh
. /etc/s6/s6.conf

case $1 in

	up ) msg "Setting system clock from real-time clock \n"
        if [ "$HARDWARECLOCK" = "UTC" ]
        then
	    dbg "Using UTC for hardware clock. \n"
	    hwclock --systz --utc --noadjfile
        fi

        if [ "$HARDWARECLOCK" = "localtime" ]
        then
	    dbg "Using localtime for hardware clock. \n"
  	    hwclock --systz --localtime --noadjfile
        fi
	;;
        down ) msg "Saving sytem clock to real-time clock \n"
	if [ "$HARDWARECLOCK" = "UTC" ]
	then
	    dbg "Using UTC for hardware clock. \n"
            hwclock --systohc --utc --noadjfile
	fi

        if [ "$HARDWARECLOCK" = "localtime" ]
	then
	    dbg "Using localtime for hardware clock. \n"
            hwclock --systohc --localtime --noadjfile
	fi
	;;
esac	
