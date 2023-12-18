#! /bin/sh

. /etc/s6/sh-scripts/common_funcs.sh

msg "Setting up ttys 1 & 2 to unicode mode...\n"
unicode_start < /dev/tty1 || emergency_shell
unicode_start < /dev/tty2 || emergency_shell
setfont ter-i12n -C /dev/tty1 || emergency_shell
setfont ter-i12n -C /dev/tty2 || emergency_shell
