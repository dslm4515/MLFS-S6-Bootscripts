#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

msg "Setting up network loopback device... \n"

ip link set up dev lo
