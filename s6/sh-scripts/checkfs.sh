#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh
. /etc/s6/s6.conf

msg "Check file systems? \n"

if [ "$FORCECHECK" = "yes" ]
then
	dbg "Check of filesystem was asked, please wait... \n"
	fsck -A -T -a -f noopts=_netdev
else
	dbg "No check was asked."
	msg_ok
fi
