#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh 

msg "Checking for /sys mount point: \n"
if [ -d /sys ] 
then
	dbg "/sys found -"
	msg_ok
else
	msg_warn "/sys not present, creating... \n"
	s6-mkdir /sys
fi

msg "Mounting sys filesystem...\n"
mountpoint -q /sys  || s6-mount -t sysfs -o nosuid,noexec,nodev sys  /sys

# Check if the sys-filesystem did mount. If not, launch a shell:
mountpoint -q /sys; ec=$?

if [ $ec -ne 0 ] 
then
        msg_fail "Unable to mount /sys. \n"
        emergency_shell
else
        dbg "/sys mounted - "
        msg_ok
fi
