#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh

if [ -f /etc/sysctl.conf ] ; then
	msg "Setting kernel runtime parameters...\n"
	sysctl -q -p
fi
