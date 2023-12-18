#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh

msg "Cleaning /tmp ... \n"
cd /tmp && find . -xdev -mindepth 1 ! -name lost+found -delete && \
	msg_ok
