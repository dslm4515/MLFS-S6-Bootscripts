#!/bin/sh

# Uncomment to list kernel modules to load. List delimited by spaces
# Will move this to s6.conf in the future.
#export MODULES=""

if [ -n "$MODULES" ]; then
    msg "Loading kernel modules: ${MODULES} ...\n"
    modprobe -ab ${MODULES}
fi

