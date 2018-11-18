#! /bin/bash

# Configuration files are read from directories in
# /usr/lib/modules-load.d, /run/modules-load.d, and /etc/modules-load.d,
# in order of precedence

MODULES_PATH=( "/etc/modules-load.d" "/run/modules-load.d" "/usr/lib/modules-load.d" )
MODULES_NAME=""
MODULES_RESULT=""

check_elements(){
        for e in "${@:2}"; do [[ $e == $1 ]] && return 0; done; return 1;
}
check_file(){
        local tidy_loop conf

        for tidy_loop in ${MODULES_PATH[@]}; do
                if [[ -d "${tidy_loop}" ]]; then
                        for conf in "${tidy_loop}"/*.conf ; do
                                check_elements ${conf##*/} ${MODULES_NAME[@]}
                                if (( $? )); then
                                        MODULES_NAME+=("${conf##*/}")
                                fi
                        done
                fi
        done

        unset tidy_loop conf
}
check_path(){
        local path tidy_loop
        for path in ${MODULES_PATH[@]}; do
                for tidy_loop in ${MODULES_NAME[@]}; do
                        if [[ -f "${path}/${tidy_loop}" ]]; then
                                check_elements "${tidy_loop}" ${MODULES_RESULT[@]##*/}
                                if (( $? ));then
                                        MODULES_RESULT+=("${path}/${tidy_loop}")
                                fi
                        fi
                done
        done
}

check_file
if [[ -n ${MODULES_NAME[@]} ]]; then
        check_path
else
        echo "rofs-modules :: Nothing to do"
        exit 0
fi
for mod in ${MODULES_RESULT[@]}; do
        while read line; do
                if [[ "${line:0:1}" == "#" ]] || [[ -z "${line}" ]];then
                        continue
                fi
                for check in ${line};do
                        modprobe -b "${check}" -v | sed 's:insmod [^ ]*/:Load modules :g; s:\.ko\(\.gz\)\? ::g'
                done
        done < "${mod}"
done

exit 0
