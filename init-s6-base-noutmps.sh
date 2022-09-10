#! /bin/bash

echo "Re-initializing init base..."
rm -rf /etc/s6/base &&
s6-linux-init-maker -1 -f /etc/s6-linux-init/skel -p "/bin:/sbin:/usr/bin:/usr/sbin"    \
	            -D default -G "/sbin/agetty -L -8 tty1 115200" \
		    -c /etc/s6/base -t 2 -L -u root /etc/s6/base
