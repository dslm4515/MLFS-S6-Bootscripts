#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

msg "Remounting root filesystem as rw - "
s6-mount -o remount,rw / / && msg_ok
