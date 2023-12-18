#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

msg "Enabling tty(s)"
dbg "enabling tty2"
/sbin/agetty -L -8 tty2 115200
