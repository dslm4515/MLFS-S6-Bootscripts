#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh 

msg "Mounting devshm... \n"
if [ -d /dev/shm ]
then
	dbg "/dev/shm found - "
	msg_ok
else
	msg_warn "/dev/shm not found, creating...\n"
	s6-mkdir /dev/shm
fi

mountpoint -q /dev/shm  || s6-mount -t tmpfs -o mode=1777,nosuid,nodev shm /dev/shm

mountpoint -q /dev/shm; ec=$?

if [ $ec -ne 0 ] 
then
	msg_fail "Unable to mount /dev/shm. \n"
	emergency_shell
else
	dbg "/dev/shm mounted - "
        msg_ok
fi
