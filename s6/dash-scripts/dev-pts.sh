#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh 

msg "Mounting devpts.. \n"
if [ -d /dev/pts ]
then
	dbg "/dev/pts found - "
	msg_ok
else
	msg_warn "/dev/pts not found, creating... \n"
	s6-mkdir /dev/pts
fi

mountpoint -q /dev/pts  || s6-mount -t devpts -o mode=0620,gid=5,nosuid,noexec devpts /dev/pts

mountpoint -q /dev/pts; ec=$?

if [ $ec -ne 0 ] 
then
        msg_fail "Unable to mount /dev/pts. \n"
        emergency_shell
else
        dbg "/dev/pts mounted - "
        msg_ok
fi
