#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh 

msg "Booting with S6+S6rc ... \n"
dbg "using sh scripts \n"

msg "Checking for /proc mount point: \n"

if [ -d /proc ] 
then
	dbg "/proc found -"
	msg_ok
else
	msg_warn "/proc not present, creating..."
	s6-mkdir /proc
fi

msg "Mounting proc filesystem...\n"
mountpoint -q /proc || s6-mount -t proc  -o nosuid,noexec,nodev proc /proc

# Check if the proc-filesystem did mount. If not, launch a shell:
mountpoint -q /proc; ec=$?

if [ $ec -ne 0 ] 
then
        msg_fail "Unable to mount /proc."
        emergency_shell
else
        dbg "/proc mounted - "
        msg_ok
fi
