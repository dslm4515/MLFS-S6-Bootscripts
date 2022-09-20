#! /bin/sh

. /etc/s6/dash-scripts/common_funcs.sh

# Check for ifconfig.$ifname files in /etc/sysconfig
ls /etc/sysconfig/* 2>/dev/null | grep ifconfig 1>/dev/null; netconfigs=$?

if [ $netconfigs -eq 0 ]; then
	# Bring up/down those NIC's
	if [ "$1" = "up" ]; then
		# Bring up the NIC's
		msg "Bringing up network interface(s)...\n"
		export IN_BOOT=1
		for file in /etc/sysconfig/ifconfig.*
		do
			interface=${file##*/ifconfig.}
			# Skip if $file is * (because nothing was found)
			if [ "${interface}" = "*" ]
			then
				continue
			fi
			/sbin/ifup ${interface}
		done
		unset IN_BOOT
	fi
	if [ "$1" = "down" ]; then
		# Bring down the NIC's
		msg "Bringing down network interface(s)...\n"
		for file in  /etc/sysconfig/ifconfig.*
		do
			net_files="${file} ${net_files}"
		done
		for file in ${net_files}
		do
			interface=${file##*/ifconfig.}
			# Skip if $file is * (because nothing was found)
			if [ "${interface}" = "*" ]
			then
				continue
			fi
			/sbin/ifdown ${interface}
		done
	fi
else
	msg_warn "No network configuration(s) found. \n"
	dbg "Either missing or managed by NetworkManager \n"
fi
