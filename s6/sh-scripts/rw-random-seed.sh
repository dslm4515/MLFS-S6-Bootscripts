#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh

BYTES=$(cat /proc/sys/kernel/random/poolsize)

if [ "$1" = "up" ]; then
	msg "Initializing random seed... \n"
	if [ -f /var/lib/random-seed ]; then
		 cp /var/lib/random-seed /dev/urandom
	fi
	umask 077; dd if=/dev/urandom of=/var/lib/random-seed count=1 bs=$BYTES
fi

if [ "$1" = "down" ]; then
	msg "Saving random seed... \n"
	umask 077; dd if=/dev/urandom of=/var/lib/random-seed count=1 bs=$BYTES
fi
