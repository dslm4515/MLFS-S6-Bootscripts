#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh
. /etc/s6/s6.conf

GETTYS="$GETTYS tty2 tty1"

msg "Set font & unicode mode for $GETTYS ...\n"

for t in $GETTYS
do
	unicode_start   < /dev/$t
	setfont $CFONT -C /dev/$t
done
msg_ok
