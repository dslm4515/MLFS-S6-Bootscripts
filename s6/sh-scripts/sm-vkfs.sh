#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh 

msg "Booting with S6+S6rc in ...\n"
dbg " S A F E - M O D E \n"

msg "Checking mount points for pseudo-filesystems...\n"
for d in proc sys dev
do
	if [ -d "/$d" ]
	then
		dbg "/$d found. "
		msg_ok
	else
		msg_warn "/$d not present. Creating... \n"
		s6-mkdir /$d
	fi
done

for d in shm pts
do
	if [ -d "/dev/$d" ]
	then
		dbg "/dev/$d found, "
		msg_ok
	else
		msg_warn "/dev/$d not present. Creating... \n"
		s6-mkdir /dev/$d
	fi
done

msg "Mounting pseudo-filesystems...\n"
mountpoint -q /proc || s6-mount -t proc  -o nosuid,noexec,nodev proc /proc
mountpoint -q /sys  || s6-mount -t sysfs -o nosuid,noexec,nodev sys  /sys

mountpoint -q /dev/pts  || s6-mount -t devpts -o mode=0620,gid=5,nosuid,noexec devpts /dev/pts
mountpoint -q /dev/shm  || s6-mount -t tmpfs  -o mode=1777,nosuid,nodev        shm    /dev/shm

# Check if booting in UEFI or non-UEFI mode
if [ -d /sys/firmware/efi ]
then
	msg "Booting in UEFI mode. \n"
	mountpoint -q /sys/firmware/efi/efivars ||  mount -n -t efivarfs -o ro efivarfs /sys/firmware/efi/efivars
fi

# Check if kernel has SecurityFS
if [ -d /sys/kernel ] 
then
	msg "Mounting securityfs.. \n"
	mountpoint -q /sys/kernel/security ||  mount -n -t securityfs securityfs /sys/kernel/security
fi

# Check if the pseudo-filesystems did mount. If not, launch a shell:
mountpoint -q /proc || emergency_shell
mountpoint -q /sys  || emergency_shell
mountpoint -q /dev/shm || emergency_shell
mountpoint -q /dev/pts || emergency_shell
