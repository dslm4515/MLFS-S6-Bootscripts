#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh 
. /etc/s6/s6.conf

msg "Setting up ttys ... \n"

s6-mkdir /run/enabled-ttys
for t in $GETTYS 
do
	touch /run/enabled-ttys/$t
	dbg " enabling $t \n"
done
