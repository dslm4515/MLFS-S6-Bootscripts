#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh 

# Check if booting in UEFI or non-UEFI mode
if [ -d /sys/firmware/efi ]
then
	msg "Booting in UEFI mode. \n"
	mountpoint -q /sys/firmware/efi/efivars ||  mount -n -t efivarfs -o ro efivarfs /sys/firmware/efi/efivars
else
	msg "Booting in non-UEFI mode. \n"
fi
