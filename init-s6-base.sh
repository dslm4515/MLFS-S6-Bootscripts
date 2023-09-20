#! /bin/bash

echo "Reinitializing init base..."
rm -rf /etc/s6/base &&
s6-linux-init-maker -1 -f /etc/s6/skel -p "/bin:/sbin:/usr/bin"    \
	            -D default -G "/sbin/agetty -L -8 tty1 115200" \
		    -c /etc/s6/base -t 2 -L -u root -U utmp /etc/s6/base
rm -rf /etc/s6/base/scripts
cp -r /etc/s6/scripts /etc/s6/base/scripts
