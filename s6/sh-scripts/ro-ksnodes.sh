#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh 

msg "Setting up Kernel Static Node(s)... \n"
if [ -d /run/tmpfiles.d ] ; then
	s6-mkdir  /run/tmpfiles.d
fi

kmod static-nodes --format=tmpfiles --output=/run/tmpfiles.d/kmod.conf
