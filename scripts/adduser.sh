#!/bin/bash

# NEEDS MODIFICATION FOR MLFS

# This script is used to create a supervision tree for 
# root user. This file is started by the service adduser. 
# This is the last service started by the stage2. 00 is 
# the first, adduser is the last one

exec 2>&1
exec 1>/var/log/master.log

log(){
	printf "%s %s %s\n" "$(date +"%Y-%m-%d %H:%M:%S")" "${FUNCNAME[1]} ::" "${@}"
}

ENV="/etc/s6/env"
DEST=$(<${ENV}/DEST) #/run/boot

if ! source /etc/obarun/s6opts.conf; then
	out_error "/etc/obarun/s6opts.conf not found, existing"
	exit 1
else
	SOURCE="/etc/obarun/s6opts.conf"
fi
GEN_NAME=$(<${ENV}/MASTER)
DEST_USER=$(<${ENV}/DEST)
LIVE_CLASSIC_PATH=${DEST_USER}/service
LIVE_RC_PATH=${DEST_USER}
LIST_SERV=$(ls ${CLASSIC_ENABLED})

add_env() {
	local -a list_env=$(printenv)
	local var value line list
	
	log "mkdir ${DEST}/env"
	mkdir -p -m 0755 ${DEST}/env
	
	while read line;do
	
		if [[ "${line:0:1}" == "#" ]] || [[ -z "${line}" ]];then
			continue
		fi
				
		var=$(awk -F"=" '{print $1}' <<< "${line}")
		value=${!var}
		
		log "create new file ${var} with ${value} at ${DEST}/env/"
		touch ${DEST}/env/"${var}"
		echo "${value}" > ${DEST}/env/"${var}"

	done < "${SOURCE}"
	
		
	# need improvement
	for list in ${list_env[@]};do
		
		while read line;do
			
			var=$(awk -F"=" '{print $1}' <<< "${line}")
			value=${!var}
			
			case "${var}" in
				_|?|PWD|G_DEBUG) continue
					;;
				*)
					log "create new file ${var} with ${value} at ${DEST}/env/"
					touch ${DEST}/env/"${var}"
					echo "${value}" > ${DEST}/env/"${var}"
					;;
			esac
		done <<< "${list}"
				
	done
	for tidy_loop in GEN_NAME DEST_USER LIVE_CLASSIC_PATH LIVE_RC_PATH;do
		var=${!tidy_loop}
		log "create new file ${tidy_loop} with ${var} at ${DEST}/env"
		touch ${DEST}/env/"${tidy_loop}"
		echo "${var}" > ${DEST}/env/"${tidy_loop}"
	done
	
	unset list_env var value line list
}


# copy daemon enabled by USER
enabled_daemon() {
	for serv in ${LIST_SERV[@]};do
		log "enable ${serv} daemon"
		ln -sfT ${CLASSIC_ENABLED}/${serv} ${LIVE_CLASSIC_PATH}/${serv} 
	done
}

start_database() {
	log "init s6-rc database with -l ${LIVE_RC_PATH}/${GEN_NAME} -c ${RC_DATABASE_COMPILED}/current ${LIVE_CLASSIC_PATH}"
	s6-rc-init -l ${LIVE_RC_PATH}/${GEN_NAME} -c ${RC_DATABASE_COMPILED}/current -p ${GEN_NAME} ${LIVE_CLASSIC_PATH}
	s6-rc -v 3 -l ${LIVE_RC_PATH}/${GEN_NAME} -u change All
}

start() {
		
	#add_env || exit 1
	
	enabled_daemon || exit 1
	
	svscanctl -an "${LIVE_CLASSIC_PATH}" 2>/dev/null 
		
	start_database || exit 1

}

start
