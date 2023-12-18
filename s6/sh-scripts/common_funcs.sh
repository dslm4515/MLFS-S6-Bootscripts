#! /bin/sh

PATH=/usr/bin:/usr/sbin:/sbin/bin

# This will setup a sulogin shell just in case any part of the boot process suddenly stops
# for whatever reason.
emergency_shell() {
    echo "Cannot continue due to errors above, starting emergency shell."
    echo "When ready type exit to continue booting."
    /bin/sh -l
}

dbg() {
   printf " |- $@"
}

msg() {
    # bold
    printf "\033[1m(o) $@\033[m"
}

msg_ok() {
    # bold/green
    printf "\033[1m\033[32m OK\033[m\n"
}

msg_fail() {
    # bold/red
    printf "\033[1m\033[31m FAIL\033[m\n"
}

msg_warn() {
    # bold/yellow
    printf "\033[1m\033[33mWARNING: $@\033[m"
}
