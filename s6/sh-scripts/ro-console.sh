#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh
. /etc/s6/s6.conf

ETTYS="$GETTYS tty2 tty1"

msg "Set font & unicode mode for $ETTYS ...\n"

# Enable unicode mode
for t in $ETTYS
do
	unicode_start   < /dev/$t
done

# Set console font
if [ $CFONT != "0" ]; then
	for t in $ETTYS
	do
		setfont $CFONT -C /dev/$t
	done
else
	msg "Using default console font.\n"
fi
msg_ok
