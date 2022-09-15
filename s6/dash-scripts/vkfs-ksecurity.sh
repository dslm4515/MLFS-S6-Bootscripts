#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh 

# Check if kernel has SecurityFS
if [ -d /sys/kernel ] 
then
     msg "Mounting securityfs.. \n"
     mountpoint -q /sys/kernel/security ||  mount -n -t securityfs securityfs /sys/kernel/security
fi